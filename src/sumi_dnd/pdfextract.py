# Glossary
# crect         class rectangle, could be a stat card, could be a skill card
# nsc           non-stroking color
# cformat       char format
# cmformat      comment format

import pdfplumber
import math
import json
from pathlib import Path
from collections import defaultdict

# Measurements based on Blade Dancer 22 Aug 2026
EXPECTED_CRECT_WIDTH = 1439.99994
EXPECTED_CRECT_HEIGHT = 809.9999662499999
expected_crect_ratio = EXPECTED_CRECT_WIDTH / EXPECTED_CRECT_HEIGHT
CRECT_BUFFER_PCT = 0.05
CRECT_VSPLIT_OFFSET = 5 # Split some distance to the right of where Passive starts
CRECT_HEADER_CUTOFF = 52.54079888160038
CRECT_HEADER_BUFFER = 5 # Start the actual cutoff some distance below CRECT_HEADER_CUTOFF

# List all possible forms of the same functional marker
MARKERS_MAIN_STATS = ["Main Stat"]
MARKERS_SUB_STATS = ["Simplified", "Sub Stat"]
MARKERS_BONUS_ATTS = ["Bonus"]
MARKERS_SKILL_CARD = ["Class abilities"]
MARKERS_ITALICS = ["italic", "oblique"]
MARKERS_BOLD = ["bold", "bd", "heavy", "thick", "blk", "black", "medi"]

# We assume that all comments are roughly this color and italic.
CMFORMAT_NSC = (0.5725, 0.5725, 0.5725) # This assumes DeviceRGB.
CMFORMAT_NSC_BUFFER = 0.075

# For the left card we'll go by markers in the text itself.
# For the right card we'll assume only that subheaders are bold, and uniquely so.

repo_dir = Path(__file__).resolve().parents[2]
dm_dir = repo_dir / "dm"
pdf_path = dm_dir / "class_knight.pdf"

#-------------------------------------------------------------------------------------------------+
#   META ANALYSIS
#-------------------------------------------------------------------------------------------------+

def analyze_chars(page):
    # cformats structure:
    # {
    #      (size, is_italic, nsc): [char, char, char],
    #      (size, is_italic, nsc): [char, char, char]
    # }
    cformats = defaultdict(list)
    for char in page.chars:
        size = char["size"]
        fontname = char["fontname"]
        is_italic = confirm_any_marker_in_text(MARKERS_ITALICS, char["fontname"])
        nsc = char["non_stroking_color"]
        key = (size, fontname, is_italic, nsc)
        cformat = cformats[key]
        cformat.append(char)
    for (size, fontname, is_italic, nsc), chars in cformats.items():
        joined_chars = "".join(char["text"] for char in chars)
        print(size, fontname, "is_italic:" + str(is_italic), nsc, joined_chars)
    return cformats

def confirm_any_marker_in_text(markers, text, case_sensitive=False):
    for marker in markers:
        if case_sensitive:
            if marker in text:
                return True
        else:
            if marker.lower() in text.lower():
                return True
    return False

#-------------------------------------------------------------------------------------------------+
#   FORMAT MATCHING
#-------------------------------------------------------------------------------------------------+

def confirm_rect_is_crect(rect):
    rect_width = rect["width"]
    rect_height = rect["height"]
    rect_ratio = rect_width / rect_height
    ratio_diff = abs(rect_ratio - expected_crect_ratio)
    within_buffer = ratio_diff <= (expected_crect_ratio * CRECT_BUFFER_PCT)
    is_crect = within_buffer
    return is_crect

def confirm_char_matches_cmformat(char):
    color_dist = math.dist(char["non_stroking_color"], CMFORMAT_NSC)
    is_color_cmformat = color_dist <= CMFORMAT_NSC_BUFFER
    is_italic = confirm_any_marker_in_text(MARKERS_ITALICS, char["fontname"])
    is_cmformat = is_color_cmformat and is_italic
    return is_cmformat

#-------------------------------------------------------------------------------------------------+
#   CROP TO VIEW
#-------------------------------------------------------------------------------------------------+

def crop_to_rect(page, rect):
    box = (rect["x0"], rect["top"], rect["x1"], rect["bottom"])
    view = page.crop(box)
    return view

def crop_to_rect_vsplit(page, rect, split_x): # Can't get CroppedPage bounds it seems
    left_box = (rect["x0"], rect["top"], split_x, rect["bottom"])
    right_box = (split_x, rect["top"], rect["x1"], rect["bottom"])
    left_view = page.crop(left_box)
    right_view = page.crop(right_box)
    return left_view, right_view

#-------------------------------------------------------------------------------------------------+
#   FILTERS FOR PAGE.FILTER()
#-------------------------------------------------------------------------------------------------+

def filter_remove_comments(object):
    is_char = object["object_type"] == "char"
    if is_char:
        is_cmformat = confirm_char_matches_cmformat(object)
        if is_cmformat:
            # Do not include this object, as it is part of a comment
            return False
    return True

def filter_keep_subheaders(object): # If it's bold, it's a subheader
    is_char = object["object_type"] == "char"
    if is_char:
        is_bold = confirm_any_marker_in_text(MARKERS_BOLD, object["fontname"])
        if is_bold:
            return True
    return False

#-------------------------------------------------------------------------------------------------+
#   EXTRACTION
#-------------------------------------------------------------------------------------------------+

def extract_crects_from_page(page):
    rects = page.rects
    crects = [rect for rect in rects if confirm_rect_is_crect(rect)]
    return crects

def extract_subheader_markers_from_view(view):
    filtered_page = view.filter(filter_keep_subheaders)
    text = filtered_page.extract_text()
    markers = text.split("\n")
    return markers

def extract_stats_from_text(text):
    new_rpgclass = {
        "def": "",
        "main": [],
        "sub": [],
        "bonus_atts": []
    }
    new_rpgclass_name = None
    mode = "init"
    for key, line in enumerate(text.split("\n")):
        stripped_line = line.rstrip()
        stat = stripped_line.upper()
        extracting_main = confirm_any_marker_in_text(MARKERS_MAIN_STATS, line)
        extracting_sub = confirm_any_marker_in_text(MARKERS_SUB_STATS, line)
        extracting_bonus_atts = confirm_any_marker_in_text(MARKERS_BONUS_ATTS, line)
        if extracting_main:
            mode = "main"
            continue # Skip the subheader
        elif extracting_sub:
            mode = "sub"
            continue
        elif extracting_bonus_atts:
            mode = "bonus_atts"
            continue
        if mode == "init":
            if key == 0: new_rpgclass_name = stripped_line
            else: new_rpgclass["def"] += line # From here on out assume rpgclass exists
        elif mode == "main": new_rpgclass["main"].append(stat)
        elif mode == "sub": new_rpgclass["sub"].append(stat)
        elif mode == "bonus_atts": new_rpgclass["bonus_atts"].append(line)
    new_rpgclasses = {}
    new_rpgclasses[new_rpgclass_name] = new_rpgclass
    return new_rpgclasses

#-------------------------------------------------------------------------------------------------+
#   ORCHESTRATION
#-------------------------------------------------------------------------------------------------+

with pdfplumber.open(pdf_path) as pdf:
    all_rpgclasses = defaultdict(dict)
    for page in pdf.pages:
        hi = 0
        for rect in page.images:
            print("IsCrect:", confirm_rect_is_crect(rect), "Width:", round(rect["width"], 1), "Height:", round(rect["height"], 1), "Ratio:", round(rect["width"] / rect["height"], 1), f"\n")
            if round(rect["width"] / rect["height"], 1) == 1.4:
                hi += 1
        print(hi)
        for crect in extract_crects_from_page(page):
            current_view = crop_to_rect(page, crect)
            current_view = current_view.filter(filter_remove_comments)
            current_text = current_view.extract_text()
            is_skill_card = confirm_any_marker_in_text(MARKERS_SKILL_CARD, current_text)
            is_stat_card = not is_skill_card
            new_rpgclasses = {}
            if is_stat_card:
                new_rpgclasses = extract_stats_from_text(current_text)
            for new_rpgclass_name, new_rpgclass in new_rpgclasses.items():
                all_rpgclasses[new_rpgclass_name] |= new_rpgclass
    print(json.dumps(all_rpgclasses, indent=4))
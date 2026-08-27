# GLOSSARY
# card          refers to the background image used for all stat and skill cards
# view          a cropped page
# nsc           non-stroking color
# cformat       char format
# cmformat      comment format

# NAMING CONVENTIONS
# "Passives" and "abilities" are in plural when refering to their respective columns.

import pdfplumber
import math
import json
from pathlib import Path
from collections import defaultdict

# Measurements based on Blade Dancer 22 Aug 2026
TEMPLATE_CARD_WIDTH = 742.215545074351
TEMPLATE_CARD_HEIGHT = 521.997746250093
expected_card_ratio = TEMPLATE_CARD_WIDTH / TEMPLATE_CARD_HEIGHT
CARD_RATIO_BUFFER_PCT = 0.025
CARD_VSPLIT_OFFSET = 5 # Split some distance to the right of where Passive starts

# List all possible forms of the same functional marker
MARKERS_MAIN_STATS = ["Main"]
MARKERS_SUB_STATS = ["Simplified", "Sub"]
MARKERS_BONUS_ATTS = ["Simplified", "Bonus"]
MARKERS_SKILL_CARD = ["Class abilities"]
MARKER_PASSIVE_COLUMN = "passive" # Search the card for this term.
MARKERS_ITALICS = ["italic", "oblique"]
MARKERS_BOLD = ["bold", "bd", "heavy", "thick", "blk", "black", "medi"]

# We assume that all comments are roughly this color and italic.
CMFORMAT_NSC = (0.5725, 0.5725, 0.5725) # This assumes DeviceRGB.
CMFORMAT_NSC_BUFFER = 0.075

# A default is set for these values by pdfplumber.
EXTRACT_TEXT_X_TOLERANCE = 0.05
EXTRACT_TEXT_Y_TOLERANCE = 0.05

# Sometimes the abilities column bleeds into the passives column.
# This indent is expressed as a percentage of the width of the "Passive" subheader.
PASSIVE_COLUMN_INDENT_PCT = 0.2

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

def confirm_image_is_card(image):
    image_width = image["width"]
    image_height = image["height"]
    image_ratio = image_width / image_height
    ratio_diff = abs(image_ratio - expected_card_ratio)
    within_buffer = ratio_diff <= (expected_card_ratio * CARD_RATIO_BUFFER_PCT)
    is_card = within_buffer
    return is_card

def confirm_char_matches_cmformat(char):
    color_dist = math.dist(char["non_stroking_color"], CMFORMAT_NSC)
    is_color_cmformat = color_dist <= CMFORMAT_NSC_BUFFER
    is_italic = confirm_any_marker_in_text(MARKERS_ITALICS, char["fontname"])
    is_cmformat = is_color_cmformat and is_italic
    return is_cmformat

#-------------------------------------------------------------------------------------------------+
#   CROP TO VIEW
#-------------------------------------------------------------------------------------------------+

def clamp(x, v_min, v_max):
    return max(v_min, min(x, v_max))

def clamp_box_to_page(box, page):
    old_x0, old_y0, old_x1, old_y1 = box
    new_x0 = clamp(old_x0, 0, page.width)
    new_y0 = clamp(old_y0, 0, page.height)
    new_x1 = clamp(old_x1, 0, page.width)
    new_y1 = clamp(old_y1, 0, page.height)
    return (new_x0, new_y0, new_x1, new_y1)

def crop_to_image(page, image):
    box = (image["x0"], image["top"], image["x1"], image["bottom"])
    box = clamp_box_to_page(box, page)
    view = page.crop(box)
    return view

def crop_to_image_vsplit(page, image, split_x): # Can't get CroppedPage bounds it seems
    left_box = (image["x0"], image["top"], split_x, image["bottom"])
    right_box = (split_x, image["top"], image["x1"], image["bottom"])
    left_view = page.crop(left_box)
    right_view = page.crop(right_box)
    return left_view, right_view

def crop_to_abilities_and_passives_columns(page):
    # p: passives, a: abilities
    p_subheader = find_first_instance_of_word_in_page(MARKER_PASSIVE_COLUMN, page)
    p_subheader_width = p_subheader["x1"] - p_subheader["x0"]
    indent = p_subheader_width * PASSIVE_COLUMN_INDENT_PCT
    split_x = p_subheader["x0"] + indent
    # box: left, top, right, bottom
    box_a = (0, 0, split_x, page.height)
    box_p = (split_x, 0, page.width, page.height)
    view_a = page.crop(box_a, relative=True)
    view_p = page.crop(box_p, relative=True)
    return view_a, view_p

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
#   PAGE SEARCH
#-------------------------------------------------------------------------------------------------+

def find_first_instance_of_word_in_page(keyword, page, case_sensitive=False):
    words = page.extract_words(x_tolerance=EXTRACT_TEXT_X_TOLERANCE, y_tolerance=EXTRACT_TEXT_Y_TOLERANCE)
    for word in words:
        text = word["text"]
        if case_sensitive and (text == keyword):
            return word
        if (not case_sensitive) and (text.lower() == keyword.lower()):
            return word

#-------------------------------------------------------------------------------------------------+
#   EXTRACTION
#-------------------------------------------------------------------------------------------------+

def extract_cards_from_page(page):
    images = page.images
    cards = [image for image in images if confirm_image_is_card(image)]
    return cards

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
    step = 0 # 1:Init, 2:Main, 3:Sub, 4:Bonus
    # We're forcing an order here because sometimes "Simplified" can mean either sub stats or bonus attributes.
    for key, line in enumerate(text.split("\n")):
        stripped_line = line.rstrip()
        stat = stripped_line.upper()
        extracting_main = confirm_any_marker_in_text(MARKERS_MAIN_STATS, line)
        extracting_bonus_atts = confirm_any_marker_in_text(MARKERS_BONUS_ATTS, line)
        extracting_sub = confirm_any_marker_in_text(MARKERS_SUB_STATS, line)
        if extracting_main and (step == 0):
            step = 1
            continue # Skip the subheader
        elif extracting_sub and (step == 1):
            step = 2
            continue
        elif extracting_bonus_atts and (step == 2):
            step = 3
            continue
        if step == 0:
            if key == 0: new_rpgclass_name = stripped_line
            else: new_rpgclass["def"] += line # From here on out assume rpgclass exists
        elif step == 1: new_rpgclass["main"].append(stat)
        elif step == 2: new_rpgclass["sub"].append(stat)
        elif step == 3: new_rpgclass["bonus_atts"].append(line)
    new_rpgclasses = {}
    new_rpgclasses[new_rpgclass_name] = new_rpgclass
    return new_rpgclasses

def extract_abilities_from_text(text):
    print(text)

#-------------------------------------------------------------------------------------------------+
#   ORCHESTRATION
#-------------------------------------------------------------------------------------------------+

with pdfplumber.open(pdf_path) as pdf:
    all_rpgclasses = defaultdict(dict)
    for page in pdf.pages:
        for card in extract_cards_from_page(page):
            current_view = crop_to_image(page, card)
            current_view = current_view.filter(filter_remove_comments)
            current_text = current_view.extract_text(x_tolerance=EXTRACT_TEXT_X_TOLERANCE, y_tolerance=EXTRACT_TEXT_Y_TOLERANCE)
            is_skill_card = confirm_any_marker_in_text(MARKERS_SKILL_CARD, current_text)
            is_stat_card = not is_skill_card
            new_rpgclasses = {}
            if is_stat_card:
                new_rpgclasses = extract_stats_from_text(current_text)
            if is_skill_card:
                abilities_column, passives_column = crop_to_abilities_and_passives_columns(current_view)
                extract_abilities_from_text(abilities_column.extract_text())
            for new_rpgclass_name, new_rpgclass in new_rpgclasses.items():
                all_rpgclasses[new_rpgclass_name] |= new_rpgclass
    # print(json.dumps(all_rpgclasses, indent=4))
    # with open(r"C:\Users\tjames\Desktop\extracted_classes.json", "w", encoding="utf-8") as f:
        # json.dump(all_rpgclasses, f, indent=4, ensure_ascii=False)
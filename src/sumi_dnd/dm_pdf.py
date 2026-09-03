# GLOSSARY
# card          refers to the background image used for all stat and skill cards
# view          a cropped page
# nsc           non-stroking color
# cformat       char format
# cmformat      comment format
# def           definition
# skill         ability or passive

# NAMING CONVENTIONS
# "Passives" and "abilities" are in plural when refering to their respective columns.

import pdfplumber
import math
import re
from collections import defaultdict

# Measurements based on Blade Dancer 22 Aug 2026
TEMPLATE_CARD_WIDTH = 742.215545074351
TEMPLATE_CARD_HEIGHT = 521.997746250093
expected_card_ratio = TEMPLATE_CARD_WIDTH / TEMPLATE_CARD_HEIGHT
CARD_RATIO_BUFFER_PCT = 0.025
CARD_VSPLIT_OFFSET = 5 # Split some distance to the right of where Passive starts

# Split the stat card by whatever comes first.
SUBHEADERS_STAT_CARD = ["main", "main stat", "sub", "sub stat", "simplified", "bonus", "bonus attribute"]

# This tells us we're looking at a skill card.
MARKERS_SKILL_CARD = ["class abilities"]

# We split the skill card where these words appears.
MARKER_PASSIVE_COLUMN = "passive"
MARKER_SUBCLASS_FOOTER = "subclass"
SUBCLASS_FOOTER_BUFFER_PCT = 0.1

# Sometimes the abilities column bleeds into the passives column.
# This indent is expressed as a percentage of the width of the "Passive" subheader.
PASSIVE_COLUMN_INDENT_PCT = 0.2

MARKER_CD = "CD:"
MARKER_MP = "Cost:"

# These tell us what font we're looking at.
# Important for subheaders and comments.
MARKERS_ITALICS = ["italic", "oblique"]
MARKERS_BOLD = ["bold", "bd", "heavy", "thick", "blk", "black", "medi"]

# We assume that all comments are roughly this color and italic.
CMFORMAT_NSC = (0.5725, 0.5725, 0.5725) # This assumes DeviceRGB.
CMFORMAT_NSC_BUFFER = 0.075

# A default is set for these values by pdfplumber.
EXTRACT_TEXT_X_TOLERANCE = 0.05
EXTRACT_TEXT_Y_TOLERANCE = 0.05

# Crop headers starting from some space underneath the column header.
# "Passive" gets split due to the indent. It's noise, anyway.
COLUMN_HEADER_BUFFER_PCT = 0.5

# For the left card we'll go by markers in the text itself.
# For the right card we'll assume only that subheaders are bold, and uniquely so.

#-------------------------------------------------------------------------------------------------+
#   EXTRACT ALL
#-------------------------------------------------------------------------------------------------+

def extract_classes_from_pdf(pdf_path):
    with pdfplumber.open(pdf_path) as pdf:
        classes_by_name = {}
        for page in pdf.pages:
            for card in extract_cards_from_page(page):
                data_from_card = extract_data_from_card_on_page(card, page)
                class_name = data_from_card["name"]
                search_key = class_name.strip().lower()
                # We're actually using a key dict here but like, cleaner, I guess
                # We didn't want key dicts because json standards but we deal with it like so
                new_class = classes_by_name.setdefault(
                    search_key,
                    {"name": class_name, **make_class_template()}
                ) 
                for field in class_template_fields:
                    if field in data_from_card:
                        new_class[field].extend(data_from_card[field])
        # Isolate just the keys in a list
        all_classes = list(classes_by_name.values())
        return all_classes

def make_class_template():
    return {
        "main_stats": [],
        "sub_stats": [],
        "bonus_atts": [],
        "abilities": [],
        "passives": []
    }

class_template_fields = list(make_class_template())

#-------------------------------------------------------------------------------------------------+
#   ANY CARD
#-------------------------------------------------------------------------------------------------+

# Anything that involves cropping has to take both the card image and the whole page.
def extract_data_from_card_on_page(card, page):
    card_view = crop_page_to_image(page, card).filter(filter_remove_comments)
    card_text = custom_extract_text(card_view)
    is_skill_card = confirm_any_marker_in_text(MARKERS_SKILL_CARD, card_text)
    if is_skill_card:
        extracted_data = {
            "name": split_text_by_nearest_marker(card_text, MARKERS_SKILL_CARD)[0][:-1],
            "abilities": [],
            "passives": []
        }
        new_abilities, new_passives = extract_skills_from_card_on_page(card, page)
        extracted_data["abilities"].extend(new_abilities)
        extracted_data["passives"].extend(new_passives)
    else:
        extracted_data = extract_data_from_stat_card_text(card_text)
    return extracted_data

#-------------------------------------------------------------------------------------------------+
#   STAT CARDS
#-------------------------------------------------------------------------------------------------+

def extract_data_from_stat_card_text(text):
    body = split_text_by_nearest_marker(text, SUBHEADERS_STAT_CARD)
    extracted_data = {
        "name": body[0].split("\n")[0]
    }
    if body[1]:
        extracted_data["main_stats"] = body[1].split("\n")
    if body[2]:
        extracted_data["sub_stats"] = body[2].split("\n")
    if body[3]:
        extracted_data["bonus_atts"] = body[3].split("\n")
    return extracted_data

#-------------------------------------------------------------------------------------------------+
#   SKILL CARDS
#-------------------------------------------------------------------------------------------------+

def extract_skills_from_card_on_page(card, page):
    left_col, right_col = crop_whole_page_to_skill_column_views_on_card(page, card)
    new_abilities = extract_skills_from_column_view(left_col)
    new_passives = extract_skills_from_column_view(right_col)
    return new_abilities, new_passives

def extract_skills_from_column_view(view):
    skill_names = extract_subheaders_from_view(view)
    skill_text = custom_extract_text(view)
    skill_defs = split_text_by_nearest_marker(skill_text, skill_names)
    new_skills = []
    for key, skill_name in enumerate(skill_names):
        skill_def = skill_defs[key]
        new_skill = {
            "name": skill_name,
            "def": skill_def,
        }
        cd, mp_cost = extract_cd_and_cost_from_skill_text(skill_def)
        if cd is not None:
            new_skill["cd"] = cd
        if mp_cost is not None:
            new_skill["mp_cost"] = mp_cost
        new_skills.append(new_skill)
    return new_skills

def extract_subheaders_from_view(view):
    filtered_page = view.filter(filter_keep_subheaders)
    text = custom_extract_text(filtered_page)
    markers = text.split("\n")
    return markers

def extract_cd_and_cost_from_skill_text(text):
    # Assume all abilities contain text in format: "CD: 1 ..." or "CD: 1 Cost: 1 MP ..."
    cd_match = re.search(rf"{MARKER_CD}\s*(\d+)", text)
    cost_match = re.search(rf"{MARKER_MP}\s*(\d+)", text)
    cd = int(cd_match.group(1)) if cd_match else None
    cost = int(cost_match.group(1)) if cost_match else None
    return cd, cost

def find_first_instance_of_word_in_page_words(keyword, page_words, case_sensitive=False):
    for word in page_words:
        text = word["text"]
        if case_sensitive and (text == keyword):
            return word
        if (not case_sensitive) and (text.lower() == keyword.lower()):
            return word

#-------------------------------------------------------------------------------------------------+
#   TEXT ANALYSIS
#-------------------------------------------------------------------------------------------------+

def split_text_by_nearest_marker(text, markers):
    remaining_text = text.strip()
    remaining_markers = sorted(markers, key=len, reverse=True)

    no_markers_left = len(remaining_markers) == 0
    if no_markers_left:
        return [remaining_text]

    nearest_marker_found = None
    nearest_marker_spot = None
    for this_marker in remaining_markers:
        this_marker_spot = text.lower().find(this_marker.lower())
        no_marker_found = this_marker_spot == -1
        marker_found = not no_marker_found
        if marker_found:
            first_place_unclaimed = nearest_marker_spot is None
            if first_place_unclaimed:
                nearest_marker_spot = this_marker_spot
                nearest_marker_found = this_marker
            else:
                this_is_the_nearest_marker = this_marker_spot < nearest_marker_spot
                if this_is_the_nearest_marker:
                    nearest_marker_spot = this_marker_spot
                    nearest_marker_found = this_marker

    no_marker_found = nearest_marker_found is None
    if no_marker_found:
        return [remaining_text]
    else:
        split_spot = nearest_marker_spot + len(nearest_marker_found)
        eaten_text = text[:nearest_marker_spot].strip()
        later_text = text[split_spot:]

    remaining_markers = [marker for marker in remaining_markers if marker != nearest_marker_found]
    message_from_future = split_text_by_nearest_marker(later_text, remaining_markers)
    if eaten_text:
        return [eaten_text.strip()] + message_from_future
    else:
        return message_from_future

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
#   PDFPLUMBER: OBJECT
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

def custom_extract_text(page): # Not to be confused with page.extract_text()
    text = page.extract_text(x_tolerance=EXTRACT_TEXT_X_TOLERANCE, y_tolerance=EXTRACT_TEXT_Y_TOLERANCE)
    return text

def custom_extract_words(page): # Not to be confused with page.extract_words()
    words = page.extract_words(x_tolerance=EXTRACT_TEXT_X_TOLERANCE, y_tolerance=EXTRACT_TEXT_Y_TOLERANCE)
    return words

def extract_cards_from_page(page):
    images = page.images
    cards = [image for image in images if confirm_image_is_card(image)]
    return cards

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
#   PDFPLUMBER: CROP
#-------------------------------------------------------------------------------------------------+

def crop_whole_page_to_skill_column_views_on_card(page, card):
    card_view = crop_page_to_image(page, card)
    # cheader: column header
    page_words = custom_extract_words(card_view)
    cheader = find_first_instance_of_word_in_page_words(MARKER_PASSIVE_COLUMN, page_words) # The subheader at which to split.
    if cheader is None:
        return
    cheader_width = cheader["x1"] - cheader["x0"]
    cheader_height = cheader["bottom"] - cheader["top"]
    indent = cheader_width * PASSIVE_COLUMN_INDENT_PCT
    shave = cheader_height * COLUMN_HEADER_BUFFER_PCT
    split_x = cheader["x0"] + indent
    top = cheader["bottom"] + shave
    # Crop out the "subclasses" footer.
    footer = find_first_instance_of_word_in_page_words(MARKER_SUBCLASS_FOOTER, page_words)
    if footer:
        footer_height = footer["bottom"] - footer["top"]
        footer_buffer = footer_height * SUBCLASS_FOOTER_BUFFER_PCT
        box_bottom = footer["top"] - footer_buffer
    else:
        box_bottom = card["bottom"]
    # Crop the original page into the columns. I think it's easier that way.
    left_box = (card["x0"], top, split_x, box_bottom)
    right_box = (split_x, top, card["x1"], box_bottom)
    left_view = page.crop(left_box)
    right_view = page.crop(right_box)
    return left_view, right_view

def crop_page_to_image(page, image):
    box = (image["x0"], image["top"], image["x1"], image["bottom"])
    box = clamp_box_to_page(box, page)
    view = page.crop(box)
    return view

def clamp_box_to_page(box, page):
    old_x0, old_y0, old_x1, old_y1 = box
    new_x0 = clamp(old_x0, 0, page.width)
    new_y0 = clamp(old_y0, 0, page.height)
    new_x1 = clamp(old_x1, 0, page.width)
    new_y1 = clamp(old_y1, 0, page.height)
    return (new_x0, new_y0, new_x1, new_y1)

def clamp(x, v_min, v_max):
    return max(v_min, min(x, v_max))

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
#   TEST
#-------------------------------------------------------------------------------------------------+

from pathlib import Path
import json

repo_dir = Path(__file__).resolve().parents[2]
dm_dir = repo_dir / "dm"
pdf_path = dm_dir / "class_knight.pdf"
print(json.dumps(extract_classes_from_pdf(pdf_path), indent=4))
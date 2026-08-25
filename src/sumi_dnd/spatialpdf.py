# Glossary
# crect         class rect

import pdfplumber
from pathlib import Path

# Measurements based on Blade Dancer 22 Aug 2026
CRECT_WIDTH = 1439.99994
CRECT_HEIGHT = 809.9999662499999
CRECT_BUFFER = 50
CRECT_VSPLIT_OFFSET = 5 # Split some distance to the right of where Passive starts
CRECT_HEADER_CUTOFF = 52.54079888160038
CRECT_HEADER_BUFFER = 5 # Start the actual cutoff some distance below CRECT_HEADER_CUTOFF

# List all possible forms of the same functional marker
MARKERS_MAIN_STATS = ["Main Stat"]
MARKERS_SUB_STATS = ["Simplified", "Sub Stat"]
MARKERS_ABILITY_CARD = ["Class abilities"]


repo_dir = Path(__file__).resolve().parents[2]
dm_dir = repo_dir / "dm"
pdf_path = dm_dir / "class_template.pdf"

def is_crect(rect):
    rect_width = rect["width"]
    rect_height = rect["height"]
    width_diff = abs(rect_width - CRECT_WIDTH)
    height_diff = abs(rect_height - CRECT_HEIGHT)
    within_width = width_diff <= CRECT_BUFFER
    within_height = height_diff <= CRECT_BUFFER
    result = within_width and within_height
    return result

def get_crects(page):
    rects = page.rects
    crects = [rect for rect in rects if is_crect(rect)]
    return crects

def crop_to_rect(page, rect):
    box = (rect["x0"], rect["top"], rect["x1"], rect["bottom"])
    cropped_page = page.crop(box)
    return cropped_page

def crop_to_rect_vsplit(page, rect, split_x): # Can't get CroppedPage bounds
    left_box = (rect["x0"], rect["top"], split_x, rect["bottom"])
    right_box = (split_x, rect["top"], rect["x1"], rect["bottom"])
    left_crop = page.crop(left_box)
    right_crop = page.crop(right_box)
    page_crops = [left_crop, right_crop]
    return page_crops

def any_marker_in_text(markers, text, case_sensitive=False):
    for marker in markers:
        if case_sensitive:
            if marker in text:
                return True
        else:
            if marker.lower() in text.lower():
                return True
    return False

with pdfplumber.open(pdf_path) as pdf:
    for page_num, page in enumerate(pdf.pages, start=1):
        crects = get_crects(page)
        for crect_idx, crect in enumerate(crects, start=1):
            crect_crop = crop_to_rect(page, crect)
            words = crect_crop.extract_words()
            passive_word = next((w for w in words if "passive" in w["text"].lower()), None)
            print(f"\n==========================================")
            print(f" PAGE {page_num} - CARD {crect_idx}")
            print(f"==========================================")
            if passive_word: # crect is a right card including kits
                split_x = passive_word["x0"] + CRECT_VSPLIT_OFFSET
                page_crops = crop_to_rect_vsplit(page, crect, split_x)
                left_crop = page_crops[0]
                right_crop = page_crops[1]
                print("\n--- ABILITIES (LEFT COLUMN) ---")
                print(left_crop.extract_text())
                print("\n--- PASSIVES (RIGHT COLUMN) ---")
                print(right_crop.extract_text())
            else: # crect is a left card including stats
                print("\n--- CLASS INFO & STATS ---")
                print(crect_crop.extract_text())
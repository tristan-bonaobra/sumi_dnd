# Glossary
# char          pdfplumber character dict
# fgroup        format group; chars grouped based on size and non-stroking color; to group into an fgroup
# linegroup     chars grouped by top; to group into a linegroup

import pdfplumber
import math
from pathlib import Path

repo_dir = Path(__file__).resolve().parents[2]
dm_dir = repo_dir / "dm"
pdf_path = dm_dir / "class_knight.pdf"

def group_chars_into_words(sorted_chars, xboundpt=0.75, yboundpt=2):
    words = []
    word_dict = None
    for char in sorted_chars:
        if word_dict is None:
            word_dict = create_word(char)
            continue
        char_left = char["x0"]
        char_y = char["top"]
        word_right = word_dict["x1"]
        word_y = word_dict["top"]
        xdist = (char_left - word_right)
        ydist = abs(char_y - word_y)
        in_xbound = xdist <= xboundpt
        in_ybound = ydist <= yboundpt
        is_space = char["text"] == " "
        if in_ybound and in_xbound and (not is_space):
            word_dict["text"] += char["text"]
            word_dict["x1"] = char["x1"]
        else:
            words.append(word_dict)
            if is_space:
                word_dict = None
            else:
                word_dict = create_word(char)
    if word_dict is not None:
        words.append(word_dict)
    return words

def create_word(start_char):
    return {
        "text": start_char["text"],
        "x0": start_char["x0"],
        "x1": start_char["x1"],
        "top": start_char["top"],
        "bottom": start_char["bottom"],
    }

def sort_chars(chars):
    return sorted(chars, key=lambda c: (round(c["top"]), c["x0"]))

def fgroup_chars(chars):
    fgroups = []
    for char in chars:
        matching_fgroup = None
        for fgroup in fgroups:
            color_matches = char["non_stroking_color"] == fgroup["non_stroking_color"]
            size_matches = char["size"] == fgroup["size"]
            if color_matches and size_matches:
                matching_fgroup = fgroup
                break
        if matching_fgroup is not None:
            matching_fgroup["chars"].append(char)
        else:
            new_fgroup = {
                "non_stroking_color": char["non_stroking_color"],
                "size": char["size"],
                "chars": [char]
            }
            fgroups.append(new_fgroup)
    return fgroups

with pdfplumber.open(pdf_path) as pdf:
    page = pdf.pages[0]
    chars = page.chars
    fgroups = fgroup_chars(chars)
    for fgroup in fgroups:
        print(fgroup["non_stroking_color"], fgroup["size"], len(fgroup["chars"]))
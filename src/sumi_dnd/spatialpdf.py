# Glossary
# char          pdfplumber character dict
# fgroup        format group; chars grouped based on size and non-stroking color; to group into an fgroup
# linegroup     chars grouped by top; to group into a linegroup

import pdfplumber
import math
from pathlib import Path

repo_dir = Path(__file__).resolve().parents[2]
dm_dir = repo_dir / "dm"
pdf_path = dm_dir / "class_template.pdf"
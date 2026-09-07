from sumi_dnd import db_init
from sumi_dnd import pdf_insert

INSERT_FILES = ["class_knight.pdf", "class_warrior.pdf"]

db_init.reinitialize_database()
for file_name in INSERT_FILES:
    pdf_insert.insert_pdf(file_name)
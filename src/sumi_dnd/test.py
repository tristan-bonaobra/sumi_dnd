from sumi_dnd.db import reinitialize_database
from sumi_dnd.db import insert_pdf

INSERT_FILES = ["class_knight.pdf", "class_warrior.pdf"]

reinitialize_database()
for file_name in INSERT_FILES:
    insert_pdf(file_name)
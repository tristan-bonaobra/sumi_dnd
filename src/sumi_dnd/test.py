from sumi_dnd.db import reinitialize_database
from sumi_dnd.pdf import insert_pdf
from sumi_dnd.tag import seed_tags, insert_tags_for_skills

INSERT_FILES = ["class_knight.pdf", "class_warrior.pdf"]

reinitialize_database()
for file_name in INSERT_FILES: insert_pdf(file_name)
seed_tags()
insert_tags_for_skills(skill_type="ability")
insert_tags_for_skills(skill_type="passive")
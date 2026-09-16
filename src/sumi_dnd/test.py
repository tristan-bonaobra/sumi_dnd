from sumi_dnd.db import reinitialize_database
from sumi_dnd.pdf import insert_pdf, insert_keywords_for_skill_type
from sumi_dnd.tag import seed_tags, insert_tags_for_skills, nuke_database_and_generate_prompts

INSERT_FILES = ["class_knight.pdf", "class_warrior.pdf"]
SKILL_TYPES = ["ability", "passive"]

nuke_database_and_generate_prompts()
reinitialize_database()
for file_name in INSERT_FILES: insert_pdf(file_name)
for skill_type in SKILL_TYPES: insert_keywords_for_skill_type(skill_type)
seed_tags()
for skill_type in SKILL_TYPES: insert_tags_for_skills(skill_type)
from sumi_dnd import db_engine
from sumi_dnd import pdf_extract
from pathlib import Path
from sqlalchemy import text

# Make this a config

engine = db_engine.get_engine()
current_file = Path(__file__).resolve()
project_root = next(p for p in current_file.parents if (p / ".git").exists())
dm_dir = project_root / "dm"

def insert_pdf(file_name):
    with engine.begin() as conn:
        print(f"Importing {file_name}")
        import_path = dm_dir / file_name
        extracted_classes = pdf_extract.extract_classes_from_pdf(import_path)
        for current_class in extracted_classes:
            conn.execute(
                text("INSERT INTO class(name) VALUES(:class_name)"),
                {"class_name": current_class["name"]}
            )
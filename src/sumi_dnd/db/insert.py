from sumi_dnd.db import get_engine
from sumi_dnd.pdf import extract_classes_from_pdf
from pathlib import Path
from sqlalchemy import text

engine = get_engine()

current_file = Path(__file__).resolve()
project_root = next(p for p in current_file.parents if (p / "pyproject.toml").exists()) # Bold assumption

dm_dir = project_root / "dm"
sql_dir = project_root / "src" / "sumi_dnd" / "sql"
seed_source_path = sql_dir / "seed.sql"

def insert_pdf(file_name):
    with engine.begin() as conn:
        print(f"Importing {file_name}")
        import_path = dm_dir / file_name
        extracted_classes = extract_classes_from_pdf(import_path)
        
        for new_class in extracted_classes:
            # Add class name
            returned_class_id = conn.execute(
                text("INSERT INTO class(name) VALUES(:name) RETURNING id;"),
                {"name": new_class["name"]}
            ).scalar()
            
            # Add passives
            for new_passive in new_class["passives"]:
                returned_passive_id = conn.execute(
                    text("""
                        INSERT INTO passive(name, def) VALUES (:name, :def)
                        ON CONFLICT (name) DO UPDATE
                            SET name = EXCLUDED.name
                        RETURNING id;
                    """),
                    {
                        "name": new_passive.get("name"),
                        "def": new_passive.get("def")
                    }
                ).scalar()
                conn.execute(
                    text("INSERT INTO class_passive(class_id, passive_id) VALUES (:class_id, :passive_id);"),
                    {
                        "class_id": returned_class_id,
                        "passive_id": returned_passive_id
                    }
                )

            # Add abilities
            for new_ability in new_class["abilities"]:
                returned_ability_id = conn.execute(
                    text("""
                        INSERT INTO ability(name, def, cd, mp_cost) VALUES (:name, :def, :cd, :mp_cost)
                        ON CONFLICT (name) DO UPDATE
                            SET name = EXCLUDED.name
                        RETURNING id;
                    """),
                    {
                        "name": new_ability.get("name"),
                        "def": new_ability.get("def"),
                        "cd": new_ability.get("cd"),
                        "mp_cost": new_ability.get("mp_cost")
                    }
                ).scalar()
                conn.execute(
                    text("INSERT INTO class_ability(class_id, ability_id) VALUES (:class_id, :ability_id);"),
                    {
                        "class_id": returned_class_id,
                        "ability_id": returned_ability_id
                    }
                )

def insert_seed():
    with engine.begin() as conn:
        with open(seed_source_path, "r", encoding="utf-8") as file:
            conn.execute(text(file.read()))
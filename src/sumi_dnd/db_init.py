from sumi_dnd import db_engine
from sqlalchemy import text
from pathlib import Path

engine = db_engine.get_engine()
script_dir = Path(__file__).parent
schema_source_path = script_dir / "schema.sql"

def reinitialize_database():
    print("Pushing the big red button")
    nuke_schema()
    create_readonly_role()
    init_schema()

def nuke_schema():
    with engine.begin() as conn:
        conn.execute(text("""
            DROP SCHEMA IF EXISTS public CASCADE;
            CREATE SCHEMA public;
        """))

def create_readonly_role():
    with engine.connect() as conn:
        try:
            conn.execute(text("CREATE ROLE readonly;"))
            conn.commit()
        except Exception:
            conn.rollback()
        conn.execute(text("GRANT pg_read_all_data TO readonly;"))
        conn.commit()

def init_schema():
    with engine.begin() as conn:
        with open(schema_source_path, "r", encoding="utf-8") as file:
            conn.execute(text(file.read()))

reinitialize_database()
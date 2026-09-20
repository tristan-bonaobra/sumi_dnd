from dnd_ingest.db import get_engine
from dotenv import load_dotenv
from sqlalchemy import text
from pathlib import Path
import sys
import os

engine = get_engine()
dnd_ingest_dir = Path(__file__).resolve().parents[1]
script_dir = Path(__file__).parent
schema_source_path = script_dir / "sql" / "schema.sql"

def reinitialize_database():
    print("Nuking database")
    nuke_schema()
    print("Rebuilding database")
    create_readonly_role()
    init_schema()

def nuke_schema():
    with engine.begin() as conn:
        conn.execute(text("""
            DROP SCHEMA IF EXISTS public CASCADE;
            CREATE SCHEMA public;
        """))

def load_env():
    if getattr(sys, 'frozen', False):
        base_dir = Path(sys._MEIPASS)
    else:
        base_dir = Path(__file__).parent
    env_path = base_dir / ".env"
    load_dotenv(env_path)

def create_readonly_role():
    with engine.connect() as conn:
        try:
            conn.execute(text(f"CREATE ROLE readonly WITH LOGIN PASSWORD  '{os.getenv("READONLY_PASSWORD")}';"))
            conn.commit()
        except Exception:
            conn.rollback()
        conn.execute(text("GRANT pg_read_all_data TO readonly;"))
        conn.commit()

def init_schema():
    with engine.begin() as conn:
        with open(schema_source_path, "r", encoding="utf-8") as file:
            conn.execute(text(file.read()))

load_env()
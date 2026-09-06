from sumi_dnd import database
from sumi_dnd import pdf_extract
from sqlalchemy import text

engine = database.get_engine()

def update_database():
    print("Pushing the big red button")
    nuke_schema()
    create_readonly_role()

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

update_database()
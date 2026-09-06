from sumi_dnd import db_engine
from sqlalchemy import text

engine = db_engine.get_engine()

# Pressing the big red button
def reinitialize_database():
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

reinitialize_database()
from sumi_dnd import database
from sumi_dnd import pdf_extract
from sqlalchemy import text

engine = database.get_engine()

def update_database():
    print("Pushing the big red button")
    with engine.begin() as conn:
        init_sql_list = [
            "DROP SCHEMA IF EXISTS public CASCADE;",
            "CREATE SCHEMA public;",
            "DROP ROLE IF EXISTS readonly;"
            "CREATE ROLE readonly;",
            "GRANT pg_read_all_data TO readonly;"
        ]
        for init_sql in init_sql_list:
            print(init_sql)
            conn.execute(text(init_sql))

update_database()
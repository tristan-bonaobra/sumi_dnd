from sumi_dnd import db_connect
import pandas as pd
from sqlalchemy import text
import tabulate

pd.set_option('display.max_columns', None)
pd.set_option('display.width', None)
pd.set_option('display.max_colwidth', None)
pd.set_option('display.max_rows', None)

KEY_COLUMN = {
    # Universal
    "effect": "Effects",
    # skill_search
    "skill": "Skill",
    "target": "Target Type",
    "type": "Skill Type",
    "class": "Class",
    # keyword_search
    "keyword": "Keyword"
}

TABLE_COLUMNS = {
    "keyword_search": {"Effects", "Keyword"},
    "skill_search": {"Effects", "Skill", "Target Type", "Skill Type", "Class"}
}

engine = db_connect.get_engine()

def parse_cmd(cmd: str) -> dict:
    cmd_dict = {}
    for token in cmd.strip().split():
        if ":" in token:
            key, value = token.split(":", 1)
            cmd_dict[key.strip().lower()] = value.strip()
    return cmd_dict

def get_read_params_for_table(table_name: str, cmd_dict: dict) -> list[dict]:
    read_params = {}
    for key, value in cmd_dict.items():
        column = KEY_COLUMN.get(key)
        if (column is None) or (column not in TABLE_COLUMNS[table_name]): continue
        read_params[key] = f"%{value}%"
    return read_params

def get_query_for_table(table_name: str, cmd_dict: dict):
    query = f"SELECT * FROM {table_name} WHERE "
    clauses = []
    for key, value in cmd_dict.items():
        column = KEY_COLUMN.get(key)
        if (column is None) or (column not in TABLE_COLUMNS[table_name]): continue
        clauses.append(f'"{column}" ILIKE :{key}')
    query += " AND ".join(clauses) + ";"
    if clauses: return text(query)

def main():
    print(f"Welcome to sumi_dnd!\nExample cmd: 'effect:buff target:multi'")
    with engine.connect() as conn:
        while True:
            cmd = input("> ")
            cmd_dict = parse_cmd(cmd)
            for table_name in TABLE_COLUMNS:
                read_params = get_read_params_for_table(table_name, cmd_dict)
                query = get_query_for_table(table_name, cmd_dict)
                df = pd.read_sql(query, conn, params=read_params)
                if not df.empty:
                    print(f"\n{query}")
                    print(df.to_markdown(index=False, tablefmt="simple_grid"))

if __name__ == "__main__":
    main()
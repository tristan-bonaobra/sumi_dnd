from sumi_dnd import database
from sqlalchemy import text
import pandas as pd

engine = database.get_engine()

with engine.connect() as conn:
    query = "SELECT * FROM skill_search LIMIT 1;"
    df = pd.read_sql(query, conn)
    print(df.to_markdown(index=False))
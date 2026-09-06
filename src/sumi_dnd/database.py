import os
import sys
from pathlib import Path
from dotenv import load_dotenv, find_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

if getattr(sys, 'frozen', False):
    env_path = Path(sys.executable).parent / ".env"
    load_dotenv(dotenv_path=env_path)
else:
    load_dotenv(find_dotenv())

db_url = URL.create(
    drivername="postgresql+psycopg2",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST"),
    port=int(os.getenv("DB_PORT", 5432)),
    database=os.getenv("DB_NAME"),
)

engine = create_engine(db_url)

def get_engine():
    return engine
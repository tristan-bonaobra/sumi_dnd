import os
import sys
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine

script_dir = Path(__file__).parent

if getattr(sys, 'frozen', False):
    env_path = Path(sys.executable).parent / ".env"
else:
    env_path = Path(__file__).resolve().parent.parent.parent / ".env"

def get_engine():
    
    load_dotenv(dotenv_path=env_path)

    db_host = os.getenv("DB_HOST")
    db_port = os.getenv("DB_PORT")
    db_name = os.getenv("DB_NAME")
    db_user = os.getenv("DB_USER")
    db_password = os.getenv("DB_PASSWORD")

    return create_engine(f"postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}")
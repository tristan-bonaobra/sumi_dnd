import os
import sys
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine

# Finding .env depends on whether we're a .py file hiding in a subpackage or a .exe file sitting alone in dist/
if getattr(sys, 'frozen', False):
    base_dir = Path(sys._MEIPASS)
else:
    base_dir = Path(__file__).parent

env_path = base_dir / ".env"
load_dotenv(env_path)

engine = create_engine(os.getenv("DATABASE_URL"))

def get_engine():
    return engine
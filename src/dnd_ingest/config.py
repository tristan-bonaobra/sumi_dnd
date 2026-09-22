from pathlib import Path
import tomllib

PROJECT_ROOT = Path(__file__).resolve().parents[2]
CONFIG_FILE = PROJECT_ROOT / "config.toml"

def load_config():
    if not CONFIG_FILE.is_file():
        raise FileNotFoundError(f"config.toml not found: {CONFIG_FILE}")
    
    with open(CONFIG_FILE, "rb") as f:
        return tomllib.load(f)

CONFIG = load_config()
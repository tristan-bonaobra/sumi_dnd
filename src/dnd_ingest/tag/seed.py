from dnd_ingest.tag import TargetType, Effect
from dnd_ingest.db import get_engine
from sqlalchemy import text

engine = get_engine()

def seed_tags():
    print("Seeding tags")
    with engine.begin() as conn:
        for e in TargetType:
            conn.execute(
                text("INSERT INTO target_type(name) VALUES (:name) ON CONFLICT DO NOTHING;"),
                {"name": e.value}
            )

        for e in Effect:
            conn.execute(
                text("INSERT INTO effect(name) VALUES (:name) ON CONFLICT DO NOTHING;"),
                {"name": e.value}
            )
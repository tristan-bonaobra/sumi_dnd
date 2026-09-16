from .tag_class import TargetType, Effect
from sumi_dnd.db import get_engine
from sqlalchemy import text
from typing import Literal
from pathlib import Path
import ollama
import json

script_dir = Path(__file__).parent
engine = get_engine()
SkillType = Literal["ability", "passive"]

def insert_tags_for_skills(skill_type: SkillType):
    with open(script_dir / "generated_prompts" / f"{skill_type}.txt", "r") as file:
        system_prompt = file.read()

    with engine.begin() as conn:
        rows = conn.execute(text(f"SELECT * FROM {skill_type};")).fetchall()
        n_rows = len(rows)
        i = 0
        for row in rows:
            if i == 0:
                print(f"Reading system prompt ({len(system_prompt.encode("utf-8"))} characters)")

            bot_response = ollama.chat(
                model="llama3.2",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": getattr(row, "def")}
                ],
                format=get_response_format(),
                options={
                    "temperature": 0,
                    "seed": 0,
                },
            )
            bot_response = json.loads(bot_response.message.content)

            i += 1
            progress = round((i / round(n_rows)) * 100)
            print(f"Inserting tags for {skill_type} ({progress}%)\t", end="\r", flush=True)

            conn.execute(
                text(f"""
                    INSERT INTO {skill_type}_target_type ({skill_type}_id, type_id)
                    SELECT :skill_id, id 
                    FROM target_type 
                    WHERE target_type.name = :generated_target_type
                    ON CONFLICT ({skill_type}_id, type_id) DO NOTHING;
                """),
                {"skill_id": row.id, "generated_target_type": bot_response["target_type"]}
            )

            for generated_effect in bot_response["effects"]:
                conn.execute(
                    text(f"""
                        INSERT INTO {skill_type}_effect ({skill_type}_id, effect_id)
                        SELECT :skill_id, id 
                        FROM effect 
                        WHERE effect.name = :generated_effect
                        ON CONFLICT ({skill_type}_id, effect_id) DO NOTHING;
                    """),
                    {"skill_id": row.id, "generated_effect": generated_effect}
                )
    print()

def get_response_format():
    return {
        "type": "object",
        "properties": {
            "target_type": {
                "type": "string",
                "enum": [e.value for e in TargetType]
            },
            "effects": {
                "type": "array",
                "items": {
                    "type": "string",
                    "enum": [e.value for e in Effect]
                }
            }
        },
        "required": ["target_type", "effects"]
    }
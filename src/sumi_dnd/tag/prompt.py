from sumi_dnd.db import get_engine, reinitialize_database, insert_seed
from sqlalchemy import text
from pathlib import Path
from collections import defaultdict

script_dir = Path(__file__).parent
select_abilities_source_path = script_dir / "select_abilities.sql"

engine = get_engine()

def get_system_prompt_for_tags(for_passives=False) -> str:
    with engine.begin() as conn:
        with open(select_abilities_source_path, "r") as file:
            select_sql = file.read()
            if for_passives:
                select_sql = select_sql.replace("ability", "passive")
        selected_rows = conn.execute(text(select_sql))

    grouped_defs = defaultdict(list)
    for row in selected_rows:
        key = (row.target_type, row.effects)
        if len(grouped_defs[key]) < 2:
            selected_def = getattr(row, "def")
            grouped_defs[key].append(selected_def)

    examples = []
    for (target_type, effects), selected_defs in grouped_defs.items():
        for selected_def in selected_defs:
            example_lines = [
                f"Prompt: {selected_def}",
                f"Target type: {target_type}",
                f"Effects: {effects}"
            ]
            example = "\n".join(example_lines)
            examples.append(example)

    system_prompt_lines = [
        f"Choose one appropriate target type and at least one effect. Below are examples.\n",
        f"\n\n".join(examples),
        f"\nNotes:",
        "- Damage targets health. Debuffs are non-damaging effects that apply harmful status and multipliers.",
        "- DoT stands for damage over turns."
    ]
    system_prompt = "\n".join(system_prompt_lines)

    skill_type = "passive" if for_passives else "ability"
    with open(script_dir / "generated_prompts" / f"{skill_type}.txt", "w", encoding="utf-8") as file:
        file.write(system_prompt)

    return system_prompt

reinitialize_database()
insert_seed()
get_system_prompt_for_tags(for_passives=True)
get_system_prompt_for_tags(for_passives=False)
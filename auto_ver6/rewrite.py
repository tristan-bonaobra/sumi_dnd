import csv
from pathlib import Path

script_dir = Path(__file__).resolve().parent

##---------------------------------------------------------
## LOAD DATA
##---------------------------------------------------------

def read_csv(file_name: str):
    with open(script_dir / file_name, mode = "r", encoding = "utf-8") as file:
        reader = csv.reader(file)
        next(reader)
        return list(reader)

v5_ability = read_csv("ability.csv")
v5_passive = read_csv("passive.csv")
v5_class = read_csv("class.csv")
v5_class_stat = read_csv("class_stat.csv")
v5_class_ability = read_csv("class_ability.csv")
v5_class_passive = read_csv("class_passive.csv")

v5_stat_short = {
    1: "STR",
    2: "DEX",
    3: "CON",
    4: "INT",
    5: "WIS",
    6: "CHA"
}

##---------------------------------------------------------
## WRITE STATEMENTS
##---------------------------------------------------------

seed = ""

for rpgclass in v5_class:
    new_class_id = rpgclass[0]
    new_class_name = rpgclass[1]
    new_parent_id = rpgclass[2]

    seed += f"DO $$\n"
    seed += f"DECLARE\n"
    seed += f"    new_class_id INT;\n"
    seed += f"BEGIN\n"

    if new_parent_id == "":
        seed += f"    INSERT INTO class(name) VALUES('{new_class_name or "NULL"}') RETURNING id INTO new_class_id;\n"
    else:
        seed += f"    INSERT INTO class(name, parent_id) VALUES('{new_class_name or "NULL"}', {new_parent_id}) RETURNING id INTO new_class_id;\n"

    for class_stat in v5_class_stat:
        linked_class_id = class_stat[1]
        linked_stat_id = class_stat[2]
        linked_type_id = class_stat[3]
        if linked_class_id == new_class_id:
            seed += f"    PERFORM add_class_stat(new_class_id, '{v5_stat_short[int(linked_stat_id)]}', {linked_type_id});\n"

    for class_ability in v5_class_ability:
        linked_class_id = class_ability[1]
        linked_ability_id = class_ability[2]
        for candidate_ability in v5_ability:
            candidate_ability_id = candidate_ability[0]
            if candidate_ability_id == linked_ability_id:
                new_ability_name = candidate_ability[1]
                new_ability_def = candidate_ability[2]
                new_ability_cd = candidate_ability[3]
                new_ability_mp_cost = candidate_ability[4]
        if linked_class_id == new_class_id:
            seed += f"    PERFORM add_class_ability(new_class_id, '{new_ability_name or "NULL"}', '{new_ability_def or "NULL"}', {new_ability_cd or "NULL"}, {new_ability_mp_cost or "NULL"});\n"

    for class_passive in v5_class_passive:
            linked_class_id = class_passive[1]
            linked_passive_id = class_passive[2]
            for candidate_passive in v5_passive:
                candidate_passive_id = candidate_passive[0]
                if candidate_passive_id == linked_passive_id:
                    new_passive_name = candidate_passive[1]
                    new_passive_def = candidate_passive[2]
            if linked_class_id == new_class_id:
                seed += f"    PERFORM add_class_passive(new_class_id, '{new_passive_name or "NULL"}', '{new_passive_def or "NULL"}');\n"

    seed += f"END $$;\n"
    seed += f"\n"

with open(script_dir / "rewrite_result.txt", "w", encoding="utf-8") as file:
    file.write(seed)
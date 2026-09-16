from enum import Enum

class TargetType(str, Enum):
    SINGLE = "Single"
    MULTI = "Multi"
    SELF = "Self"
    RANDOM = "Random"
    REVENGE = "Revenge"
    AUTO = "Auto"
    SACRIFICE = "Sacrifice"
    FIELD = "Field"
    NOT_APPLICABLE = "<null>"

class Effect(str, Enum):
    DAMAGE = "Damage"
    DOT = "DoT"
    CC = "CC"
    BUFF = "Buff"
    DEBUFF = "Debuff"
    CLEANSE = "Cleanse"
    SUSTAIN = "Sustain"
    ANTIHEAL = "Antiheal"
    STEALTH = "Stealth"
    PERCEPTION = "Perception"
    RESOURCES = "Resources"
    SUMMON = "Summon"
    PERSUASION = "Persuasion"
    ANY = "Any"
    NOT_APPLICABLE = "<null>"
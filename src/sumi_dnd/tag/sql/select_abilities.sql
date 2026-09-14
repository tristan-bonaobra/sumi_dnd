SELECT
    ability.def AS def,
    target_type.name AS target_type,
    ARRAY_TO_STRING(ARRAY_AGG(DISTINCT effect.name), ', ') AS effects
FROM ability
LEFT JOIN ability_effect ON ability_effect.ability_id = ability.id
LEFT JOIN ability_target_type ON ability_target_type.ability_id = ability.id
LEFT JOIN effect ON effect.id = ability_effect.effect_id
LEFT JOIN target_type ON target_type.id = ability_target_type.type_id
GROUP BY def, target_type
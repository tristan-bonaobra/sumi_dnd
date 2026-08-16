WITH stats AS (
	SELECT
		class_to_stat.class_id as class_id,
		string_agg(stat.short || ' ' || stat_type.name, E'\n') as list
	FROM class_to_stat
	LEFT JOIN stat ON stat.id = class_to_stat.stat_id
	LEFT JOIN stat_type ON stat_type.id = class_to_stat.type_id
	GROUP BY class_id
), bonus_atts AS (
	SELECT
		class_to_bonus.class_id as class_id,
		string_agg(bonus_att.id || ' ' || bonus_att.name, E'\n') as list
	FROM class_to_bonus
	LEFT JOIN bonus_att ON bonus_att.id = class_to_bonus.bonus_id
	GROUP BY class_id
), abilities AS (
	SELECT
		class_to_ability.class_id as class_id,
		string_agg(ability.id || ' ' || ability.name, E'\n') as list
	FROM class_to_ability
	LEFT JOIN ability ON ability.id = class_to_ability.ability_id
	GROUP BY class_id
), passives AS (
	SELECT
		class_to_passive.class_id as class_id,
		string_agg(passive.id || ' ' || passive.name, E'\n') as list
	FROM class_to_passive
	LEFT JOIN passive ON passive.id = class_to_passive.passive_id
	GROUP BY class_id
), subclasses AS (
	SELECT
		class_to_subclass.class_id as class_id,
		string_agg(subclass.id || ' ' || subclass.name, E'\n') as list
	FROM class_to_subclass
	LEFT JOIN subclass ON subclass.id = class_to_subclass.subclass_id
	GROUP BY class_id
) SELECT
	class.id || ' ' || class.name AS class,
	stats.list AS stats,
	bonus_atts.list AS bonus_attributes,
	abilities.list AS abilities,
	passives.list AS passives,
	subclasses.list AS subclasses
FROM class
LEFT JOIN stats ON stats.class_id = class.id
LEFT JOIN bonus_atts ON bonus_atts.class_id = class.id
LEFT JOIN abilities ON abilities.class_id = class.id
LEFT JOIN passives ON passives.class_id = class.id
LEFT JOIN subclasses ON subclasses.class_id = class.id;
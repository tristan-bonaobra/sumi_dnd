CREATE TABLE class (
	id SERIAL PRIMARY KEY,
	name TEXT,
	parent_id INT REFERENCES class(id) ON DELETE CASCADE,
	UNIQUE(name)
);

CREATE TABLE stat (
	id SERIAL PRIMARY KEY,
	name TEXT,
	short CHAR(3),
	UNIQUE (name),
	UNIQUE (short)
);

CREATE TABLE stat_type (
	id SERIAL PRIMARY KEY,
	name TEXT,
	short VARCHAR(2),
	UNIQUE (name),
	UNIQUE (short)
);

CREATE TABLE ability (
	id SERIAL PRIMARY KEY,
	name TEXT,
	def TEXT,
	cd INT,
	mp_cost INT,
	UNIQUE (name)
);

CREATE TABLE passive (
	id SERIAL PRIMARY KEY,
	name TEXT UNIQUE,
	def TEXT,
	UNIQUE (name)
);

CREATE TABLE class_stat (
	id SERIAL PRIMARY KEY,
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	stat_id INT REFERENCES stat(id) ON DELETE CASCADE,
	type_id INT REFERENCES stat_type(id) ON DELETE CASCADE,
	UNIQUE (class_id, stat_id, type_id)
);

CREATE TABLE class_ability (
	id SERIAL PRIMARY KEY,
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	ability_id INT REFERENCES ability(id) ON DELETE CASCADE,
	UNIQUE (class_id, ability_id)
);

CREATE TABLE class_passive (
	id SERIAL PRIMARY KEY,
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	passive_id INT REFERENCES passive(id) ON DELETE CASCADE,
	UNIQUE (class_id, passive_id)
);

CREATE TABLE player (
	id SERIAL PRIMARY KEY,
	name TEXT,
	UNIQUE (name)
);

create TABLE rpchar (
	id SERIAL PRIMARY KEY,
	name TEXT,
	player_id INT REFERENCES player(id) ON DELETE CASCADE,
	UNIQUE (name, player_id)
);

-- Class per ability
CREATE VIEW v_ability_class AS SELECT
	ability.id as ability_id,
	string_agg(class.name, chr(10) ORDER BY class.name) AS list,
string_agg(class.name, ', ' ORDER BY class.name) AS inline
FROM ability
LEFT JOIN class_ability ON class_ability.ability_id = ability.id
LEFT JOIN class ON class.id = class_ability.class_id
GROUP BY ability.id;

-- Class per passive
CREATE VIEW v_passive_class AS SELECT
	passive.id as passive_id,
	string_agg(class.name, chr(10) ORDER BY class.name) AS list,
string_agg(class.name, ', ' ORDER BY class.name) AS inline
FROM passive
LEFT JOIN class_passive ON class_passive.passive_id = passive.id
LEFT JOIN class ON class.id = class_passive.class_id
GROUP BY passive.id;

-- Child per class
CREATE VIEW v_class_child AS SELECT
	class.id AS parent_id,
	string_agg(child.name, chr(10) ORDER BY child.id) AS list,
	string_agg(child.name, ', ' ORDER BY child.id) AS inline
FROM class
LEFT JOIN class AS child ON child.parent_id = class.id
GROUP BY class.id;

-- Main stat per class
CREATE VIEW v_class_stat_main AS SELECT
	class_stat.class_id AS class_id,
	string_agg(stat.short, chr(10) ORDER BY class_stat.id) AS list,
	string_agg(stat.short, ', ' ORDER BY class_stat.id) AS inline
FROM class_stat
LEFT JOIN stat ON stat.id = class_stat.stat_id
LEFT JOIN stat_type ON stat_type.id = class_stat.type_id
WHERE stat_type.id = 1
GROUP BY class_stat.class_id;

-- Other stat per class
CREATE VIEW v_class_stat_other AS SELECT
	class_stat.class_id AS class_id,
	string_agg(stat.short || ' (' || stat_type.short || ')', chr(10) ORDER BY class_stat.type_id, class_stat.id) AS list,
	string_agg(stat.short || ' (' || stat_type.short || ')', ', ' ORDER BY class_stat.type_id, class_stat.id) AS inline
FROM class_stat
LEFT JOIN stat ON stat.id = class_stat.stat_id
LEFT JOIN stat_type ON stat_type.id = class_stat.type_id
WHERE stat_type.id > 1
GROUP BY class_stat.class_id;

-- Ability per class
CREATE VIEW v_class_ability AS SELECT
	class_ability.class_id AS class_id,
	string_agg(ability.name, chr(10) ORDER BY ability.cd, ability.id) AS list,
	string_agg(ability.name, ', ' ORDER BY ability.cd, ability.id) AS inline
FROM class_ability
LEFT JOIN ability ON ability.id = class_ability.ability_id
GROUP BY class_ability.class_id;

-- Passive per class
CREATE VIEW v_class_passive AS SELECT
	class_passive.class_id AS class_id,
	string_agg(passive.name, chr(10) ORDER BY passive.id) AS list,
	string_agg(passive.name, ', ' ORDER BY passive.id) AS inline
FROM class_passive
LEFT JOIN passive ON passive.id = class_passive.passive_id
GROUP BY class_passive.class_id;

-- Ability wiki
CREATE VIEW ability_wiki AS SELECT
	ability.id,
	ability.name,
	ability.def,
	ability.cd,
	COALESCE(ability.mp_cost::text, 'None') AS mp_cost,
	v_ability_class.list AS classes
FROM ability
LEFT JOIN v_ability_class ON v_ability_class.ability_id = ability.id
ORDER BY ability.name;

-- Passive wiki
CREATE VIEW passive_wiki AS SELECT
	passive.*,
	v_passive_class.list AS classes
FROM passive
LEFT JOIN v_passive_class ON v_passive_class.passive_id = passive.id
ORDER BY passive.name;

-- Class wiki
CREATE VIEW class_wiki AS SELECT
	class.id as id,
	class.name AS name,
	COALESCE(v_class_child.list, '-') AS subclasses,
	COALESCE(parent.name, '-') AS subclass_of,
	v_class_stat_main.list AS main_stats,
	v_class_stat_other.list AS other_stats,
	v_class_ability.list AS abilities,
	v_class_passive.list AS passives
FROM class
LEFT JOIN v_class_child ON v_class_child.parent_id = class.id
LEFT JOIN class AS parent ON parent.id = class.parent_id
LEFT JOIN v_class_stat_main ON v_class_stat_main.class_id = class.id
LEFT JOIN v_class_stat_other ON v_class_stat_other.class_id = class.id
LEFT JOIN v_class_ability ON v_class_ability.class_id = class.id
LEFT JOIN v_class_passive ON v_class_passive.class_id = class.id
ORDER BY
	COALESCE(class.parent_id, class.id),
	class.parent_id NULLS FIRST,
	class.id;

CREATE VIEW ability_sidx AS SELECT
	COALESCE(ability.name, '<null>') || ' (Ability)' || chr(10) || chr(10) ||
	COALESCE(ability.def, '<null>') || chr(10) || chr(10) ||
	'Cooldown: ' || COALESCE(ability.cd::text, '<null>') || ' | MP Cost: ' || COALESCE(ability.mp_cost::text, '<null>') || chr(10) || chr(10) ||
	'Classes: ' || COALESCE(v_ability_class.inline, '<null>')
	AS idx
FROM ability
LEFT JOIN v_ability_class ON v_ability_class.ability_id = ability.id;

CREATE VIEW passive_sidx AS SELECT
	COALESCE(passive.name, '<null>') || ' (Passive)' || chr(10) || chr(10) ||
	COALESCE(passive.def, '<null>') || chr(10) || chr(10) ||
	'Classes: ' || COALESCE(v_passive_class.inline, '<null>')
	AS idx
FROM passive
LEFT JOIN v_passive_class ON v_passive_class.passive_id = passive.id;

CREATE VIEW class_sidx AS SELECT
	COALESCE(class.name, '<null>') || ' (Class)' || chr(10) || chr(10) ||
	'Main stats: ' || COALESCE(v_class_stat_main.inline, '<null>') || chr(10) ||
	'Other stats: ' || COALESCE(v_class_stat_other.inline, '<null>') || chr(10) ||
	'Passives: ' || COALESCE(v_class_passive.inline, '<null>') || chr(10) ||
	'Abilities: ' || COALESCE(v_class_ability.inline, '<null>') || chr(10) || chr(10) ||
	'Parent class: ' || COALESCE(parent.name, '<null>') || chr(10) ||
	'Subclasses: ' || COALESCE(v_class_child.inline, '<null>')
	AS idx
FROM class
LEFT JOIN v_class_stat_main ON v_class_stat_main.class_id = class.id
LEFT JOIN v_class_stat_other ON v_class_stat_other.class_id = class.id
LEFT JOIN v_class_passive ON v_class_passive.class_id = class.id
LEFT JOIN v_class_ability ON v_class_ability.class_id = class.id
LEFT JOIN class AS parent ON parent.id = class.parent_id
LEFT JOIN v_class_child ON v_class_child.parent_id = class.id;

CREATE VIEW search_idx AS SELECT
	idx::text FROM ability_sidx
	UNION ALL SELECT idx::text FROM passive_sidx
	UNION ALL SELECT idx::text FROM class_sidx;
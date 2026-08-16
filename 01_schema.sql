CREATE TABLE class (
	id SERIAL PRIMARY KEY,
	name TEXT UNIQUE,
	parent_id INT REFERENCES class(id) ON DELETE CASCADE
);

CREATE TABLE stat (
	id SERIAL PRIMARY KEY,
	long TEXT UNIQUE,
	short CHAR(3) UNIQUE
);

CREATE TABLE stat_type (
	id SERIAL PRIMARY KEY,
	name TEXT UNIQUE
);

CREATE TABLE bonus_att (
	id SERIAL PRIMARY KEY,
	name TEXT UNIQUE
);

CREATE TABLE ability (
	id SERIAL PRIMARY KEY,
	name TEXT,
	def TEXT,
	cd INT
);

CREATE TABLE passive (
	id SERIAL PRIMARY KEY,
	name TEXT,
	def TEXT
);

CREATE TABLE class_stat (
	id SERIAL PRIMARY KEY,
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	stat_id INT REFERENCES stat(id) ON DELETE CASCADE,
	type_id INT REFERENCES stat_type(id) ON DELETE CASCADE,
	UNIQUE (class_id, stat_id, type_id)
);

CREATE TABLE class_bonus (
	id SERIAL PRIMARY KEY,
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	bonus_id INT REFERENCES bonus_att(id) ON DELETE CASCADE,
	UNIQUE (class_id, bonus_id)
);

CREATE TABLE class_ability (
	id SERIAL PRIMARY KEY,
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	ability_id INT REFERENCES ability(id) ON DELETE CASCADE
);

CREATE TABLE class_passive (
	id SERIAL PRIMARY KEY,
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	passive_id INT REFERENCES passive(id) ON DELETE CASCADE
);

CREATE TABLE player (
	id SERIAL PRIMARY KEY,
	name TEXT
);

CREATE TABLE rpchar (
	id SERIAL PRIMARY KEY,
	name TEXT,
	player_id INT REFERENCES player(id)
);

CREATE VIEW v_class_child AS SELECT -- For each parent
	class.id AS parent_id,
	string_agg(child.name, E'\n' ORDER BY child.name) AS list
FROM class
LEFT JOIN class AS child ON child.parent_id = class.id
GROUP BY class.id;

CREATE VIEW v_class_stat AS SELECT
	class_stat.class_id AS class_id,
	string_agg(stat.short || ' ' || stat_type.name, E'\n' ORDER BY class_stat.type_id, stat.id) AS list
FROM class_stat
LEFT JOIN stat ON stat.id = class_stat.stat_id
LEFT JOIN stat_type ON stat_type.id = class_stat.type_id
GROUP BY class_stat.class_id;

CREATE VIEW v_class_bonus AS SELECT
	class_bonus.class_id AS class_id,
	string_agg(bonus_att.name, E'\n' ORDER BY bonus_att.name) AS list
FROM class_bonus
LEFT JOIN bonus_att ON bonus_att.id = class_bonus.bonus_id
GROUP BY class_bonus.class_id;

CREATE VIEW v_class_ability AS SELECT
	class_ability.class_id AS class_id,
	string_agg(ability.name, E'\n' ORDER BY ability.name) AS list
FROM class_ability
LEFT JOIN ability ON ability.id = class_ability.ability_id
GROUP BY class_ability.class_id;

CREATE VIEW v_class_passive AS SELECT
	class_passive.class_id AS class_id,
	string_agg(passive.name, E'\n' ORDER BY passive.name) AS list
FROM class_passive
LEFT JOIN passive ON passive.id = class_passive.passive_id
GROUP BY class_passive.class_id;

CREATE VIEW class_wiki AS SELECT
	class.id as id,
	class.name AS name,
	COALESCE(v_class_child.list, '-') AS subclasses,
	COALESCE(parent.name, '-') AS subclass_of,
	v_class_stat.list AS stats,
	v_class_bonus.list AS bonuses,
	v_class_ability.list AS abilities,
	v_class_passive.list AS passives
FROM class
LEFT JOIN v_class_child ON v_class_child.parent_id = class.id
LEFT JOIN class AS parent ON parent.id = class.parent_id
LEFT JOIN v_class_stat ON v_class_stat.class_id = class.id
LEFT JOIN v_class_bonus ON v_class_bonus.class_id = class.id
LEFT JOIN v_class_ability ON v_class_ability.class_id = class.id
LEFT JOIN v_class_passive ON v_class_passive.class_id = class.id
ORDER BY
	COALESCE(class.parent_id, class.id), -- Default parent_id to own id to meet family
	class.parent_id NULLS FIRST, -- Start with parents
	class.name; -- Sort among siblings
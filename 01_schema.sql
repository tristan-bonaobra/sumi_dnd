CREATE TABLE class (
	id SERIAL PRIMARY KEY,
	name TEXT
);

CREATE TABLE stat (
	id SERIAL PRIMARY KEY,
	long TEXT,
	short CHAR(3)
);

CREATE TABLE stat_type (
	id SERIAL PRIMARY KEY,
	name TEXT
);

CREATE TABLE class_stat (
	id SERIAL PRIMARY KEY,
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	stat_id INT REFERENCES stat(id) ON DELETE CASCADE,
	type_id INT REFERENCES stat_type(id) ON DELETE CASCADE,
	UNIQUE (class_id, stat_id, type_id)
);

CREATE TABLE bonus_att (
	id SERIAL PRIMARY KEY,
	name TEXT UNIQUE
);

CREATE TABLE class_bonus (
	id SERIAL PRIMARY KEY,
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	bonus_id INT REFERENCES bonus_att(id) ON DELETE CASCADE,
	UNIQUE (class_id, bonus_id)
);

CREATE TABLE ability (
	id SERIAL PRIMARY KEY,
	name TEXT,
	def TEXT,
	cd INT
);

CREATE TABLE class_ability (
	id SERIAL PRIMARY KEY,
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	ability_id INT REFERENCES ability(id) ON DELETE CASCADE
);

CREATE TABLE passive (
	id SERIAL PRIMARY KEY,
	name TEXT,
	def TEXT
);

CREATE TABLE class_passive (
	id SERIAL PRIMARY KEY,
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	passive_id INT REFERENCES passive(id) ON DELETE CASCADE
);

CREATE TABLE subclass (
	id SERIAL PRIMARY KEY,
	name TEXT,
	def TEXT
);

CREATE TABLE class_subclass (
	id SERIAL PRIMARY KEY,
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	subclass_id INT REFERENCES subclass(id) ON DELETE CASCADE
);

CREATE TABLE player (
	id SERIAL PRIMARY KEY,
	name TEXT
);

create TABLE rpchar (
	id SERIAL PRIMARY KEY,
	name TEXT,
	player_id INT REFERENCES player(id)
);

CREATE VIEW v_class_stat AS SELECT
	class_stat.class_id as class_id,
	string_agg(stat.short || ' ' || stat_type.name, E'\n') as list
FROM class_stat
LEFT JOIN stat ON stat.id = class_stat.stat_id
LEFT JOIN stat_type ON stat_type.id = class_stat.type_id
GROUP BY class_stat.class_id;

CREATE VIEW v_class_bonus AS SELECT
	class_bonus.class_id as class_id,
	string_agg(bonus_att.id || ' ' || bonus_att.name, E'\n') as list
FROM class_bonus
LEFT JOIN bonus_att ON bonus_att.id = class_bonus.bonus_id
GROUP BY class_bonus.class_id;

CREATE VIEW v_class_ability AS SELECT
	class_ability.class_id as class_id,
	string_agg(ability.id || ' ' || ability.name, E'\n') as list
FROM class_ability
LEFT JOIN ability ON ability.id = class_ability.ability_id
GROUP BY class_ability.class_id;

CREATE VIEW v_class_passive AS SELECT
	class_passive.class_id as class_id,
	string_agg(passive.id || ' ' || passive.name, E'\n') as list
FROM class_passive
LEFT JOIN passive ON passive.id = class_passive.passive_id
GROUP BY class_passive.class_id;

CREATE VIEW class_wiki AS SELECT
	class.id || ' ' || class.name as class,
	v_class_stat.list as stats,
	v_class_bonus.list as bonuses,
	v_class_ability.list as abilities,
	v_class_passive.list as passives
FROM class
LEFT JOIN v_class_stat on v_class_stat.class_id = class.id
LEFT JOIN v_class_bonus on v_class_bonus.class_id = class.id
LEFT JOIN v_class_ability on v_class_ability.class_id = class.id
LEFT JOIN v_class_passive on v_class_passive.class_id = class.id;
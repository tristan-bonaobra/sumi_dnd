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

CREATE TABLE class_to_stat (
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

CREATE TABLE class_to_bonus (
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

CREATE TABLE class_to_ability (
	id SERIAL PRIMARY KEY,
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	ability_id INT REFERENCES ability(id) ON DELETE CASCADE
);

CREATE TABLE passive (
	id SERIAL PRIMARY KEY,
	name TEXT,
	def TEXT
);

CREATE TABLE class_to_passive (
	id SERIAL PRIMARY KEY,
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	passive_id INT REFERENCES passive(id) ON DELETE CASCADE
);

CREATE TABLE subclass (
	id SERIAL PRIMARY KEY,
	name TEXT,
	def TEXT
);

CREATE TABLE class_to_subclass (
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
CREATE TABLE class (
	id SERIAL PRIMARY KEY,
	name TEXT UNIQUE,
	parent_id INT REFERENCES class(id) ON DELETE CASCADE
);

CREATE TABLE stat (
	id SERIAL PRIMARY KEY,
	name TEXT UNIQUE,
	short CHAR(3) UNIQUE
);

CREATE TABLE stat_type (
	id SERIAL PRIMARY KEY,
	name TEXT UNIQUE,
	short VARCHAR(2) UNIQUE
);

CREATE TABLE ability (
	id SERIAL PRIMARY KEY,
	name TEXT UNIQUE,
	def TEXT,
	cd INT,
	mp_cost INT
);

CREATE TABLE passive (
	id SERIAL PRIMARY KEY,
	name TEXT UNIQUE,
	def TEXT
);

CREATE TABLE target_type (
    id SERIAL PRIMARY KEY,
    name TEXT
);

CREATE TABLE effect_type (
    id SERIAL PRIMARY KEY,
    name TEXT
);

CREATE TABLE class_stat (
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	stat_id INT REFERENCES stat(id) ON DELETE CASCADE,
	type_id INT REFERENCES stat_type(id) ON DELETE CASCADE,
	PRIMARY KEY (class_id, stat_id)
);

CREATE TABLE class_ability (
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	ability_id INT REFERENCES ability(id) ON DELETE CASCADE,
	PRIMARY KEY (class_id, ability_id)
);

CREATE TABLE class_passive (
	class_id INT REFERENCES class(id) ON DELETE CASCADE,
	passive_id INT REFERENCES passive(id) ON DELETE CASCADE,
	PRIMARY KEY (class_id, passive_id)
);

CREATE TABLE ability_target_type (
    ability_id INT REFERENCES ability(id) ON DELETE CASCADE,
    type_id INT REFERENCES target_type(id) ON DELETE CASCADE,
    PRIMARY KEY (ability_id, type_id)
);

CREATE TABLE ability_effect_type (
    ability_id INT REFERENCES ability(id) ON DELETE CASCADE,
    type_id INT REFERENCES effect_type(id) ON DELETE CASCADE,
    PRIMARY KEY (ability_id, type_id)
);

CREATE TABLE passive_target_type (
    passive_id INT REFERENCES passive(id) ON DELETE CASCADE,
    type_id INT REFERENCES target_type(id) ON DELETE CASCADE,
    PRIMARY KEY (passive_id, type_id)
);

CREATE TABLE passive_effect_type (
    passive_id INT REFERENCES passive(id) ON DELETE CASCADE,
    type_id INT REFERENCES effect_type(id) ON DELETE CASCADE,
    PRIMARY KEY (passive_id, type_id)
);

CREATE FUNCTION add_class_stat(
    for_class_id INT,
    new_short CHAR(3),
    new_stat_type INT
) RETURNS void AS $$
    BEGIN
        INSERT INTO class_stat(class_id, stat_id, type_id) VALUES(for_class_id, (SELECT id FROM stat WHERE short = new_short), new_stat_type);
    END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION add_class_ability(
    for_class_id INT,
    new_name TEXT,
    new_def TEXT,
    new_cd INT,
    new_mp_cost INT,
    new_target_type_name TEXT DEFAULT '<null>',
    new_effect_names TEXT[] DEFAULT ARRAY['<null>']
) RETURNS INT AS $$
    DECLARE
        new_ability_id INT;
        new_effect_name TEXT;
    BEGIN
        new_effect_names := COALESCE(new_effect_names, ARRAY['<null>']);
        INSERT INTO ability(name, def, cd, mp_cost) VALUES (new_name, new_def, new_cd, new_mp_cost) RETURNING id INTO new_ability_id;
        INSERT INTO class_ability(class_id, ability_id) VALUES (for_class_id, new_ability_id);
        INSERT INTO ability_target_type(ability_id, type_id) VALUES (new_ability_id, (SELECT id FROM target_type WHERE name = new_target_type_name));
        FOREACH new_effect_name IN ARRAY new_effect_names LOOP
            INSERT INTO ability_effect_type(ability_id, type_id)
            VALUES (new_ability_id, (SELECT id FROM effect_type WHERE name = new_effect_name));
        END LOOP;
        RETURN new_ability_id;
    END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION add_class_passive(
    for_class_id INT,
    new_name TEXT,
    new_def TEXT,
    new_target_type_name TEXT DEFAULT '<null>',
    new_effect_names TEXT[] DEFAULT ARRAY['<null>']
) RETURNS INT AS $$
    DECLARE
        new_passive_id INT;
        new_effect_name TEXT;
    BEGIN
        new_effect_names := COALESCE(new_effect_names, ARRAY['<null>']);
        INSERT INTO passive(name, def) VALUES (new_name, new_def) RETURNING id INTO new_passive_id;
        INSERT INTO class_passive(class_id, passive_id) VALUES (for_class_id, new_passive_id);
        INSERT INTO passive_target_type(passive_id, type_id) VALUES (new_passive_id, (SELECT id FROM target_type WHERE name = new_target_type_name));
        FOREACH new_effect_name IN ARRAY new_effect_names LOOP
            INSERT INTO passive_effect_type(passive_id, type_id)
            VALUES (new_passive_id, (SELECT id FROM effect_type WHERE name = new_effect_name));
        END LOOP;
        RETURN new_passive_id;
    END;
$$ LANGUAGE plpgsql;


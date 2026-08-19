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
    name TEXT UNIQUE
);

CREATE TABLE effect (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE
);

CREATE TABLE keyword (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE,
    def TEXT
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

CREATE TABLE ability_effect (
    ability_id INT REFERENCES ability(id) ON DELETE CASCADE,
    effect_id INT REFERENCES effect(id) ON DELETE CASCADE,
    PRIMARY KEY (ability_id, effect_id)
);

CREATE TABLE ability_keyword (
    ability_id INT REFERENCES ability(id) ON DELETE CASCADE,
    keyword_id INT REFERENCES keyword(id) ON DELETE CASCADE,
    PRIMARY KEY (ability_id, keyword_id)
);

CREATE TABLE passive_target_type (
    passive_id INT REFERENCES passive(id) ON DELETE CASCADE,
    type_id INT REFERENCES target_type(id) ON DELETE CASCADE,
    PRIMARY KEY (passive_id, type_id)
);

CREATE TABLE passive_effect (
    passive_id INT REFERENCES passive(id) ON DELETE CASCADE,
    effect_id INT REFERENCES effect(id) ON DELETE CASCADE,
    PRIMARY KEY (passive_id, effect_id)
);

CREATE TABLE passive_keyword (
    passive_id INT REFERENCES passive(id) ON DELETE CASCADE,
    keyword_id INT REFERENCES keyword(id) ON DELETE CASCADE,
    PRIMARY KEY (passive_id, keyword_id)
);

CREATE TABLE keyword_effect (
    keyword_id INT REFERENCES keyword(id) ON DELETE CASCADE,
    effect_id INT REFERENCES effect(id) ON DELETE CASCADE,
    PRIMARY KEY (keyword_id, effect_id)
);

CREATE FUNCTION add_class_stat (
    for_class_id INT,
    new_short CHAR(3),
    new_stat_type INT
) RETURNS void AS $$
    BEGIN
        INSERT INTO class_stat(class_id, stat_id, type_id) VALUES (for_class_id, (SELECT id FROM stat WHERE short = new_short), new_stat_type);
    END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION add_class_ability (
    for_class_id INT,
    new_name TEXT,
    new_def TEXT,
    new_cd INT,
    new_mp_cost INT,
    new_target_type_name TEXT DEFAULT '<null>',
    new_effect_names TEXT[] DEFAULT ARRAY['<null>'],
    new_keywords TEXT[] DEFAULT ARRAY['<null>']
) RETURNS INT AS $$
    DECLARE
        new_ability_id INT;
        new_effect_name TEXT;
        new_keyword TEXT;
    BEGIN
        new_effect_names := COALESCE(new_effect_names, ARRAY['<null>']);
        INSERT INTO ability(name, def, cd, mp_cost) VALUES (new_name, new_def, new_cd, new_mp_cost) RETURNING id INTO new_ability_id;
        INSERT INTO class_ability(class_id, ability_id) VALUES (for_class_id, new_ability_id);
        INSERT INTO ability_target_type(ability_id, type_id) VALUES (new_ability_id, (SELECT id FROM target_type WHERE name = new_target_type_name));
        FOREACH new_effect_name IN ARRAY new_effect_names LOOP
            INSERT INTO ability_effect(ability_id, effect_id)
            VALUES (new_ability_id, (SELECT id FROM effect WHERE name = new_effect_name));
        END LOOP;
        FOREACH new_keyword IN ARRAY new_keywords LOOP
            INSERT INTO ability_keyword(ability_id, keyword_id) VALUES (new_ability_id, (SELECT id FROM keyword WHERE name = new_keyword));
        END LOOP;
        RETURN new_ability_id;
    END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION add_class_passive (
    for_class_id INT,
    new_name TEXT,
    new_def TEXT,
    new_target_type_name TEXT DEFAULT '<null>',
    new_effect_names TEXT[] DEFAULT ARRAY['<null>'],
    new_keywords TEXT[] DEFAULT ARRAY['<null>']
) RETURNS INT AS $$
    DECLARE
        new_passive_id INT;
        new_effect_name TEXT;
        new_keyword TEXT;
    BEGIN
        new_effect_names := COALESCE(new_effect_names, ARRAY['<null>']);
        INSERT INTO passive(name, def) VALUES (new_name, new_def) RETURNING id INTO new_passive_id;
        INSERT INTO class_passive(class_id, passive_id) VALUES (for_class_id, new_passive_id);
        INSERT INTO passive_target_type(passive_id, type_id) VALUES (new_passive_id, (SELECT id FROM target_type WHERE name = new_target_type_name));
        FOREACH new_effect_name IN ARRAY new_effect_names LOOP
            INSERT INTO passive_effect(passive_id, effect_id)
            VALUES (new_passive_id, (SELECT id FROM effect WHERE name = new_effect_name));
        END LOOP;
        FOREACH new_keyword IN ARRAY new_keywords LOOP
            INSERT INTO passive_keyword(passive_id, keyword_id) VALUES (new_passive_id, (SELECT id FROM keyword WHERE name = new_keyword));
        END LOOP;
        RETURN new_passive_id;
    END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION add_keyword (
    new_name TEXT,
    new_def TEXT,
    new_effect_names TEXT[] DEFAULT ARRAY['<null>']
) RETURNS INT AS $$
    DECLARE
        new_keyword_id INT;
        new_effect_name TEXT;
    BEGIN
        new_effect_names := COALESCE(new_effect_names, ARRAY['<null>']);
        INSERT INTO keyword(name, def) VALUES (new_name, new_def) RETURNING id INTO new_keyword_id;
        FOREACH new_effect_name IN ARRAY new_effect_names LOOP
            INSERT INTO keyword_effect(keyword_id, effect_id) VALUES (new_keyword_id, (SELECT id FROM effect WHERE name = new_effect_name));
        END LOOP;
        RETURN new_keyword_id;
    END;
$$ LANGUAGE plpgsql;

CREATE VIEW v_ability_effects AS SELECT
    ability.id AS ability_id,
    ARRAY_TO_STRING(ARRAY_AGG(effect.name), ', ') AS all
FROM ability
LEFT JOIN ability_effect ON ability_effect.ability_id = ability.id
LEFT JOIN effect ON effect.id = ability_effect.effect_id
GROUP BY ability.id;

CREATE VIEW v_passive_effects AS SELECT
    passive.id AS passive_id,
    ARRAY_TO_STRING(ARRAY_AGG(effect.name), ', ') AS all
FROM passive
LEFT JOIN passive_effect ON passive_effect.passive_id = passive.id
LEFT JOIN effect ON effect.id = passive_effect.effect_id
GROUP BY passive.id;

CREATE VIEW v_class_ability AS SELECT
    class.name AS "Class",
    'Ability' AS "Skill Type",
    ability.name AS "Skill",
    target_type.name AS "Target Type",
    v_ability_effects.all AS "Effects",
    ability.cd::text AS "CD",
    ability.mp_cost::text AS "MP",
    ability.def AS "Definition"
FROM class
LEFT JOIN class_ability ON class_ability.class_id = class.id
LEFT JOIN ability ON ability.id = class_ability.ability_id
LEFT JOIN ability_target_type ON ability_target_type.ability_id = ability.id
LEFT JOIN target_type ON target_type.id = ability_target_type.type_id
LEFT JOIN v_ability_effects ON v_ability_effects.ability_id = ability.id;

CREATE VIEW v_class_passive AS SELECT
    class.name AS "Class",
    'Passive' AS "Skill Type",
    passive.name AS "Skill",
    target_type.name AS "Target Type",
    v_passive_effects.all AS "Effects",
    '<null>' AS "CD",
    '<null>' AS "MP",
    passive.def AS "Definition"
FROM class
LEFT JOIN class_passive ON class_passive.class_id = class.id
LEFT JOIN passive ON passive.id = class_passive.passive_id
LEFT JOIN passive_target_type ON passive_target_type.passive_id = passive.id
LEFT JOIN target_type ON target_type.id = passive_target_type.type_id
LEFT JOIN v_passive_effects ON v_passive_effects.passive_id = passive.id;

CREATE VIEW skill_search AS SELECT * FROM v_class_ability
UNION ALL SELECT * FROM v_class_passive
ORDER BY "Class", "Skill Type";

CREATE VIEW keyword_search AS SELECT
    keyword.name AS "Keyword",
    ARRAY_TO_STRING(ARRAY_AGG(DISTINCT effect.name), ', ') AS "Effects",
    keyword.def AS "Definition",
    ARRAY_TO_STRING(ARRAY_AGG(DISTINCT class.name), CHR(10)) AS "Classes",
    ARRAY_TO_STRING(ARRAY_AGG(DISTINCT ability.name), CHR(10)) AS "Abilities",
    ARRAY_TO_STRING(ARRAY_AGG(DISTINCT passive.name), CHR(10)) AS "Passives"
FROM keyword
LEFT JOIN keyword_effect ON keyword_effect.keyword_id = keyword.id
LEFT JOIN effect ON effect.id = keyword_effect.effect_id
LEFT JOIN ability_keyword ON ability_keyword.keyword_id = keyword.id
LEFT JOIN passive_keyword ON passive_keyword.keyword_id = keyword.id
LEFT JOIN ability ON ability.id = ability_keyword.ability_id
LEFT JOIN passive ON passive.id = passive_keyword.passive_id
LEFT JOIN class_ability ON class_ability.ability_id = ability.id
LEFT JOIN class_passive ON class_passive.passive_id = passive.id
LEFT JOIN class ON class.id = class_ability.class_id OR class.id = class_passive.class_id
GROUP BY keyword.name, keyword.def
ORDER BY keyword.name;
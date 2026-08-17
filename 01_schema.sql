CREATE TABLE class (
	id SERIAL PRIMARY KEY,
	name TEXT,
	parent_id INT REFERENCES class(id) ON DELETE CASCADE,
	UNIQUE (name)
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

CREATE TABLE tag (
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

CREATE TABLE ability_tag (
    ability_id INT REFERENCES ability(id) ON DELETE CASCADE,
    tag_id INT REFERENCES tag(id) ON DELETE CASCADE,
    PRIMARY KEY (ability_id, tag_id)
);

CREATE TABLE passive_tag (
    passive_id INT REFERENCES passive(id) ON DELETE CASCADE,
    tag_id INT REFERENCES tag(id) ON DELETE CASCADE,
    PRIMARY KEY (passive_id, tag_id)
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
    new_mp_cost INT DEFAULT NULL,
    tag_names text[] DEFAULT ARRAY[]::text[]
) RETURNS INT AS $$
    DECLARE
        new_ability_id INT;
        tag_name TEXT;
    BEGIN
        INSERT INTO ability(name, def, cd, mp_cost) VALUES (new_name, new_def, new_cd, new_mp_cost) RETURNING id INTO new_ability_id;
        INSERT INTO class_ability(class_id, ability_id) VALUES (for_class_id, new_ability_id);
        FOREACH tag_name IN ARRAY tag_names LOOP
            INSERT INTO ability_tag(ability_id, tag_id) VALUES (new_ability_id, (SELECT id FROM tag WHERE name = tag_name));
        END LOOP;
        RETURN new_ability_id;
    END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION add_class_passive(
    for_class_id INT,
    new_name TEXT,
    new_def TEXT,
    tag_names text[] DEFAULT ARRAY[]::text[]
) RETURNS INT AS $$
    DECLARE
        new_passive_id INT;
        tag_name TEXT;
    BEGIN
        INSERT INTO passive(name, def) VALUES (new_name, new_def) RETURNING id INTO new_passive_id;
        INSERT INTO class_passive(class_id, passive_id) VALUES (for_class_id, new_passive_id);
        FOREACH tag_name IN ARRAY tag_names LOOP
            INSERT INTO passive_tag(passive_id, tag_id) VALUES (new_passive_id, (SELECT id FROM tag WHERE name = tag_name));
        END LOOP;
        RETURN new_passive_id;
    END;
$$ LANGUAGE plpgsql;

CREATE VIEW v_ability_class AS SELECT
	ability.id as ability_id,
	string_agg(class.name, chr(10) ORDER BY class.name) AS list,
    string_agg(class.name, ', ' ORDER BY class.name) AS inline
FROM ability
LEFT JOIN class_ability ON class_ability.ability_id = ability.id
LEFT JOIN class ON class.id = class_ability.class_id
GROUP BY ability.id;

CREATE VIEW v_passive_class AS SELECT
	passive.id as passive_id,
	string_agg(class.name, chr(10) ORDER BY class.name) AS list,
string_agg(class.name, ', ' ORDER BY class.name) AS inline
FROM passive
LEFT JOIN class_passive ON class_passive.passive_id = passive.id
LEFT JOIN class ON class.id = class_passive.class_id
GROUP BY passive.id;

CREATE VIEW v_class_child AS SELECT
	class.id AS parent_id,
	string_agg(child.name, chr(10) ORDER BY child.id) AS list,
	string_agg(child.name, ', ' ORDER BY child.id) AS inline
FROM class
LEFT JOIN class AS child ON child.parent_id = class.id
GROUP BY class.id;

CREATE VIEW v_class_main_stat AS SELECT
	class_stat.class_id AS class_id,
	string_agg(stat.short, chr(10)) AS list,
	string_agg(stat.short, ', ') AS inline
FROM class_stat
LEFT JOIN stat ON stat.id = class_stat.stat_id
LEFT JOIN stat_type ON stat_type.id = class_stat.type_id
WHERE stat_type.id = 1
GROUP BY class_stat.class_id;

CREATE VIEW v_class_other_stat AS SELECT
	class_stat.class_id AS class_id,
	string_agg(stat.short || ' (' || stat_type.short || ')', chr(10) ORDER BY class_stat.type_id) AS list,
	string_agg(stat.short || ' (' || stat_type.short || ')', ', ' ORDER BY class_stat.type_id) AS inline
FROM class_stat
LEFT JOIN stat ON stat.id = class_stat.stat_id
LEFT JOIN stat_type ON stat_type.id = class_stat.type_id
WHERE stat_type.id > 1
GROUP BY class_stat.class_id;

CREATE VIEW v_class_ability AS SELECT
	class_ability.class_id AS class_id,
	string_agg(ability.name, chr(10) ORDER BY ability.cd, ability.id) AS list,
	string_agg(ability.name, ', ' ORDER BY ability.cd, ability.id) AS inline
FROM class_ability
LEFT JOIN ability ON ability.id = class_ability.ability_id
GROUP BY class_ability.class_id;

CREATE VIEW v_class_passive AS SELECT
	class_passive.class_id AS class_id,
	string_agg(passive.name, chr(10) ORDER BY passive.id) AS list,
	string_agg(passive.name, ', ' ORDER BY passive.id) AS inline
FROM class_passive
LEFT JOIN passive ON passive.id = class_passive.passive_id
GROUP BY class_passive.class_id;

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
	'Main stats: ' || COALESCE(v_class_main_stat.inline, '<null>') || chr(10) ||
	'Other stats: ' || COALESCE(v_class_other_stat.inline, '<null>') || chr(10) ||
	'Passives: ' || COALESCE(v_class_passive.inline, '<null>') || chr(10) ||
	'Abilities: ' || COALESCE(v_class_ability.inline, '<null>') || chr(10) || chr(10) ||
	'Parent class: ' || COALESCE(parent.name, '<null>') || chr(10) ||
	'Subclasses: ' || COALESCE(v_class_child.inline, '<null>')
	AS idx
FROM class
LEFT JOIN v_class_main_stat ON v_class_main_stat.class_id = class.id
LEFT JOIN v_class_other_stat ON v_class_other_stat.class_id = class.id
LEFT JOIN v_class_passive ON v_class_passive.class_id = class.id
LEFT JOIN v_class_ability ON v_class_ability.class_id = class.id
LEFT JOIN class AS parent ON parent.id = class.parent_id
LEFT JOIN v_class_child ON v_class_child.parent_id = class.id;

CREATE VIEW search_idx AS SELECT
	idx::text FROM ability_sidx
	UNION ALL SELECT idx::text FROM passive_sidx
	UNION ALL SELECT idx::text FROM class_sidx;
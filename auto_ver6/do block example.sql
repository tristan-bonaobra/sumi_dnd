------------------------------------------------------------------------------------+
-- INITIAL DO BLOCK
------------------------------------------------------------------------------------+

DO $$
DECLARE
  v_class_id   INT;
  v_ability_id INT;
  v_passive_id INT;
BEGIN
  INSERT INTO class(name) VALUES('Scholar') RETURNING id INTO v_class_id;

  INSERT INTO ability(name, def, cd) VALUES('Lost Spell', '...', 5) RETURNING id INTO v_ability_id;
  INSERT INTO class_ability(class_id, ability_id) VALUES (v_class_id, v_ability_id);

  INSERT INTO ability(name, def, cd, mp_cost) VALUES('Portal', '...', 2, 3) RETURNING id INTO v_ability_id;
  INSERT INTO class_ability(class_id, ability_id) VALUES (v_class_id, v_ability_id);

  INSERT INTO ability(name, def, cd, mp_cost) VALUES('Quotation', '...', 1, 1) RETURNING id INTO v_ability_id;
  INSERT INTO class_ability(class_id, ability_id) VALUES (v_class_id, v_ability_id);

  INSERT INTO passive(name, def) VALUES ('Learning', '...') RETURNING id INTO v_passive_id;
  INSERT INTO class_passive(class_id, passive_id) VALUES (v_class_id, v_passive_id);

  INSERT INTO passive(name, def) VALUES ('Understanding', '...') RETURNING id INTO v_passive_id;
  INSERT INTO class_passive(class_id, passive_id) VALUES (v_class_id, v_passive_id);
END $$;

------------------------------------------------------------------------------------+
-- STORED PROCEDURE EXAMPLE
------------------------------------------------------------------------------------+

CREATE OR REPLACE FUNCTION add_class_ability(
  p_class_id INT,
  p_name     TEXT,
  p_def      TEXT,
  p_cd       INT,
  p_mp_cost  INT DEFAULT NULL
) RETURNS INT AS $$
DECLARE
  v_ability_id INT;
BEGIN
  INSERT INTO ability(name, def, cd, mp_cost)
    VALUES (p_name, p_def, p_cd, p_mp_cost)
    RETURNING id INTO v_ability_id;

  INSERT INTO class_ability(class_id, ability_id)
    VALUES (p_class_id, v_ability_id);

  RETURN v_ability_id;  -- handy if you need it for tags right after
END;
$$ LANGUAGE plpgsql;

------------------------------------------------------------------------------------+
-- DO BLOCK USING STORE PROCEDURE
------------------------------------------------------------------------------------+

DO $$
DECLARE
  v_class_id   INT;
  v_ability_id INT;
BEGIN
  INSERT INTO class(name) VALUES('Scholar') RETURNING id INTO v_class_id;

  PERFORM add_class_ability(v_class_id, 'Lost Spell', '...', 5);
  PERFORM add_class_ability(v_class_id, 'Portal', '...', 2, 3);
  v_ability_id := add_class_ability(v_class_id, 'Quotation', '...', 1, 1);

  INSERT INTO ability_tag (ability_id, tag_id) SELECT v_ability_id, id FROM tag WHERE name IN ('damage');
END $$;
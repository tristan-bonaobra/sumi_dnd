INSERT INTO stat(long, short) VALUES('Strength', 'STR');
INSERT INTO stat(long, short) VALUES('Dexterity', 'DEX');
INSERT INTO stat(long, short) VALUES('Constitution', 'CON');
INSERT INTO stat(long, short) VALUES('Intelligence', 'INT');
INSERT INTO stat(long, short) VALUES('Wisdom', 'WIS');
INSERT INTO stat(long, short) VALUES('Charisma', 'CHA');

INSERT INTO stat_type(name) VALUES('Main');
INSERT INTO stat_type(name) VALUES('Sub');

INSERT INTO bonus_att(name) VALUES('Physical Damage Type');
INSERT INTO bonus_att(name) VALUES('Durability Buffer');
INSERT INTO bonus_att(name) VALUES('Melee');
INSERT INTO bonus_att(name) VALUES('Damage Stacking');

INSERT INTO ability(name, def, cd) VALUES ('Slash', 'Deal [STR Base] physical damage to a single target.', 1);
INSERT INTO ability(name, def, cd) VALUES ('Defend', 'Negate [CON Base] Physical damage taken for 1 round.', 1);
INSERT INTO ability(name, def, cd) VALUES ('Concentrate', 'Gain +1 physical damage bonus for 6 rounds.', 6);
INSERT INTO ability(name, def, cd) VALUES ('Rage', 'Gain [Rage] for 2 rounds.', 1);
INSERT INTO ability(name, def, cd) VALUES ('Axe Throw', 'Deal [STR base] physical damage to a single target.', 1);
INSERT INTO ability(name, def, cd) VALUES ('Axe Swing', 'Deal [STR base] physical to all enemies.', 4);

INSERT INTO passive(name, def) VALUES ('Strength Buffer', '+1 Strength.');
INSERT INTO passive(name, def) VALUES ('Broken Blade', 'At below 50% HP, gain +1 Strength.');
INSERT INTO passive(name, def) VALUES ('Mediate', 'Taking damage with [Rage] grants a stack of [Mediate].');
INSERT INTO passive(name, def) VALUES ('Frustration', 'Increase crit damage by 50%.');

INSERT INTO subclass(name, def) VALUES ('Corrupted Knight', 'Sacrifice health for high damage.');
INSERT INTO subclass(name, def) VALUES ('Blade Dancer', 'Ability combos and follow-ups.');
INSERT INTO subclass(name, def) VALUES ('Wolf Teeth', 'Debuffs and damage over time.');

INSERT INTO class(name) VALUES('Warrior');
INSERT INTO class_to_stat(class_id, stat_id, type_id) VALUES(1, 1, 1);
INSERT INTO class_to_stat(class_id, stat_id, type_id) VALUES(1, 3, 1);
INSERT INTO class_to_stat(class_id, stat_id, type_id) VALUES(1, 2, 2);
INSERT INTO class_to_stat(class_id, stat_id, type_id) VALUES(1, 5, 2);
INSERT INTO class_to_bonus(class_id, bonus_id) VALUES(1, 1);
INSERT INTO class_to_bonus(class_id, bonus_id) VALUES(1, 2);
INSERT INTO class_to_bonus(class_id, bonus_id) VALUES(1, 3);
INSERT INTO class_to_ability(class_id, ability_id) VALUES (1, 1);
INSERT INTO class_to_ability(class_id, ability_id) VALUES (1, 2);
INSERT INTO class_to_ability(class_id, ability_id) VALUES (1, 3);
INSERT INTO class_to_passive(class_id, passive_id) VALUES (1, 1);
INSERT INTO class_to_passive(class_id, passive_id) VALUES (1, 2);
INSERT INTO class_to_subclass(class_id, subclass_id) VALUES(1, 1);
INSERT INTO class_to_subclass(class_id, subclass_id) VALUES(1, 2);
INSERT INTO class_to_subclass(class_id, subclass_id) VALUES(1, 3);

INSERT INTO class(name) VALUES('Barbarian');
INSERT INTO class_to_stat(class_id, stat_id, type_id) VALUES(2, 1, 1);
INSERT INTO class_to_stat(class_id, stat_id, type_id) VALUES(2, 2, 1);
INSERT INTO class_to_stat(class_id, stat_id, type_id) VALUES(2, 3, 2);
INSERT INTO class_to_bonus(class_id, bonus_id) VALUES(2, 1);
INSERT INTO class_to_bonus(class_id, bonus_id) VALUES(2, 4);
INSERT INTO class_to_ability(class_id, ability_id) VALUES (2, 4);
INSERT INTO class_to_ability(class_id, ability_id) VALUES (2, 5);
INSERT INTO class_to_ability(class_id, ability_id) VALUES (2, 6);
INSERT INTO class_to_passive(class_id, passive_id) VALUES (2, 3);
INSERT INTO class_to_passive(class_id, passive_id) VALUES (2, 4);
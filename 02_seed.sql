INSERT INTO stat(name, short) VALUES('Strength', 'STR');
INSERT INTO stat(name, short) VALUES('Dexterity', 'DEX');
INSERT INTO stat(name, short) VALUES('Constitution', 'CON');
INSERT INTO stat(name, short) VALUES('Intelligence', 'INT');
INSERT INTO stat(name, short) VALUES('Wisdom', 'WIS');
INSERT INTO stat(name, short) VALUES('Charisma', 'CHA');

INSERT INTO stat_type(name, short) VALUES('Main', 'm');
INSERT INTO stat_type(name, short) VALUES('Sub', 's');

INSERT INTO target_type(name) VALUES('<null>');
INSERT INTO target_type(name) VALUES('Single');
INSERT INTO target_type(name) VALUES('Multi');
INSERT INTO target_type(name) VALUES('Self');
INSERT INTO target_type(name) VALUES('Random');
INSERT INTO target_type(name) VALUES('Revenge');
INSERT INTO target_type(name) VALUES('Auto');
INSERT INTO target_type(name) VALUES('Sacrifice');
INSERT INTO target_type(name) VALUES('Field');

INSERT INTO effect_type(name) VALUES('<null>');
INSERT INTO effect_type(name) VALUES('Damage');
INSERT INTO effect_type(name) VALUES('DoT');
INSERT INTO effect_type(name) VALUES('CC');
INSERT INTO effect_type(name) VALUES('Buff');
INSERT INTO effect_type(name) VALUES('Debuff');
INSERT INTO effect_type(name) VALUES('Cleanse');
INSERT INTO effect_type(name) VALUES('Sustain');
INSERT INTO effect_type(name) VALUES('Stealth');
INSERT INTO effect_type(name) VALUES('Perception');
INSERT INTO effect_type(name) VALUES('Resources');
INSERT INTO effect_type(name) VALUES('Summon');
INSERT INTO effect_type(name) VALUES('Any');

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name) VALUES('Warrior') RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'STR', 1);
    PERFORM add_class_stat(new_class_id, 'CON', 1);
    PERFORM add_class_stat(new_class_id, 'DEX', 2);
    PERFORM add_class_stat(new_class_id, 'WIS', 2);
    PERFORM add_class_ability(new_class_id, 'Slash', 'Deal [STR Base] physical damage to a single target.', 1, NULL, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Guard', 'Negate [CON Base] Physical damage taken for 1 round.', 1, NULL, 'Self', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Concentrate', 'Gain +1 physical damage bonus for 6 rounds.', 6, NULL, 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Strength Buffer', 'Gain +1 STR.', 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Broken Blade', 'While below 50% HP, gain +1 STR.', 'Revenge', ARRAY ['Buff']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Barbarian', 1) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'STR', 1);
    PERFORM add_class_stat(new_class_id, 'DEX', 1);
    PERFORM add_class_stat(new_class_id, 'CON', 2);
    PERFORM add_class_ability(new_class_id, 'Rage', 'Gain [Rage] for 2 rounds.', 1, NULL, 'Self', ARRAY ['Buff']);
    PERFORM add_class_ability(new_class_id, 'Axe Throw', 'Deal [STR base] physical damage to a single target.', 1, NULL, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Axe Swing', 'Deal [STR base] physical to all enemies.', 4, NULL, 'Multi', ARRAY ['Damage']);
    PERFORM add_class_passive(new_class_id, 'Mediate', 'Taking damage with [Rage] grants a stack of [Mediate].', 'Revenge', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Frustration', 'Increase crit damage by 50%.', 'Self', ARRAY ['Buff']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Illrigger', 1) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'STR', 1);
    PERFORM add_class_stat(new_class_id, 'INT', 1);
    PERFORM add_class_stat(new_class_id, 'CON', 2);
    PERFORM add_class_ability(new_class_id, 'Jab', 'Deal [STR base] Physical damage, inflict [Hel seal].', 1, NULL, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Ignition', 'On a single enemy convert [Hel seal] to [Burn] for 3 rounds.', 1, NULL, 'Single', ARRAY ['DoT']);
    PERFORM add_class_ability(new_class_id, 'Combust', 'On a single enemy, consume [Hel seal] to deal [INT base] necrotic damage.', 5, NULL, 'Single', ARRAY ['Damage']);
    PERFORM add_class_passive(new_class_id, 'Helish Aura', 'The party becomes immune to fire damage.', 'Multi', ARRAY ['Cleanse']);
    PERFORM add_class_passive(new_class_id, 'HelSpawn', 'Gain +1 CON.', 'Self', ARRAY ['Sustain']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Symbiote', 1) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'CON', 1);
    PERFORM add_class_stat(new_class_id, 'STR', 2);
    PERFORM add_class_ability(new_class_id, 'Slam', 'Deal [CON base] physical damage to a single enemy.', 1, NULL, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Organic Skin', 'Gain [Defense] for 3 rounds.', 3, NULL, 'Self', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Latch', 'Inflict [Latch] on target.', 5, NULL, 'Single', ARRAY ['Debuff']);
    PERFORM add_class_passive(new_class_id, 'Self Regen', 'Gain [Regeneration].', 'Self', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Devour', 'Winning battles gains +1 CON permanently.', 'Self', ARRAY ['Sustain']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name) VALUES('Druid') RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 2);
    PERFORM add_class_ability(new_class_id, 'Plant Heal', 'Heal [WIS base] to a single ally.', 1, 1, 'Single', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Overgrowth', '[Stun] a single enemy.', 1, 1, 'Single', ARRAY ['CC']);
    PERFORM add_class_ability(new_class_id, 'Familiar', 'Summon a [Familiar].', 1, 1, 'Field', ARRAY ['Summon']);
    PERFORM add_class_passive(new_class_id, 'Thorns', 'Casting spells inflict [Poison] on a random enemy for 2 rounds.', 'Random', ARRAY ['DoT']);
    PERFORM add_class_passive(new_class_id, 'Animal Tongue', 'Ability to speak to animals.', 'Self', ARRAY ['Perception']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Shaman', 5) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'INT', 1);
    PERFORM add_class_stat(new_class_id, 'DEX', 2);
    PERFORM add_class_ability(new_class_id, 'Storm Totem', 'Summon [Storm totem] for 5 rounds.', 6, NULL, 'Field', ARRAY ['Summon']);
    PERFORM add_class_ability(new_class_id, 'Tempest Shift', 'Apply [Slow] on all enemies for 1 round.', 1, NULL, 'Multi', ARRAY ['Debuff']);
    PERFORM add_class_ability(new_class_id, 'Rain', 'Deal [WIS base] magic damage to all enemies.', 2, NULL, 'Multi', ARRAY ['Damage']);
    PERFORM add_class_passive(new_class_id, 'Mending Spirit', 'Casting spells applies [Regeneration] to a random ally.', 'Random', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Warding', 'Gain 1+ warding efficiency.', 'Self', ARRAY ['Perception']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Timekeeper', 5) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 2);
    PERFORM add_class_ability(new_class_id, 'Fast Forward', 'Target ally gains [WIS base] mana.', 1, NULL, 'Single', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Rewind', 'Rewind a single target to the previous round health value.', 2, 3, 'Single', ARRAY ['Any']);
    PERFORM add_class_ability(new_class_id, 'Pause', '[Stun] a single enemy for 1 round.', 1, 3, 'Single', ARRAY ['CC']);
    PERFORM add_class_passive(new_class_id, 'Foresight', 'See enemy actions before they perform them.', 'Self', ARRAY ['Perception']);
    PERFORM add_class_passive(new_class_id, 'Timezone', 'Short rest is considered a long rest.', 'Multi', ARRAY ['Sustain']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Warden', 5) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'CON', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 2);
    PERFORM add_class_ability(new_class_id, 'Natural Protection', 'Target gains [Defense] for 1 round.', 1, NULL, 'Single', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Spiritual Protection', 'Target gains [Defense+] for 3 rounds.', 4, 2, 'Single', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Warding Light', 'Remove [Invisibility] for enemies, and cleans [Blindness] for allies.', 2, 2, 'Multi', ARRAY ['Perception']);
    PERFORM add_class_passive(new_class_id, 'Ward Crafter', 'Gain ward crafting proficiency.', 'Self', ARRAY ['Resources']);
    PERFORM add_class_passive(new_class_id, 'Clarity', 'Gain +1 WIS.', 'Self', ARRAY ['Buff']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name) VALUES('Warlock') RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'CHA', 1);
    PERFORM add_class_stat(new_class_id, 'CON', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 2);
    PERFORM add_class_ability(new_class_id, 'Undead', 'Summon an [Undead] containing half of your health.', 1, 1, 'Field', ARRAY ['Summon']);
    PERFORM add_class_ability(new_class_id, 'Decay', 'Channel a blood field that will deal [CHA base] Magic damage to all enemies. MP per second.', 1, 1, 'Multi', ARRAY ['DoT']);
    PERFORM add_class_ability(new_class_id, 'Plague', 'Apply [Dark Plague] on a single target for 3 rounds.', 6, 2, 'Single', ARRAY ['Damage']);
    PERFORM add_class_passive(new_class_id, 'Blood Draw', 'Dealing magic damage will heal you.', 'Self', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Sacrifice', 'If you cant spend mana to cast a spell, consume your health instead.', 'Sacrifice', ARRAY ['Sustain']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Witch', 9) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'INT', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 2);
    PERFORM add_class_ability(new_class_id, 'Hex', 'Apply [Hex] on a single enemy.', 1, 1, 'Single', ARRAY ['Debuff']);
    PERFORM add_class_ability(new_class_id, 'Hex Field', 'Channel a hex field, enemies casting abilities will be inflected by [Hex]. MP per second.', 1, 1, 'Field', ARRAY ['Debuff']);
    PERFORM add_class_ability(new_class_id, 'Curse Rupture', 'Detonate all [Hex] stacks on enemies to deal half [INT base] Magic damage multiplied by the amount of stacks.', 3, NULL, 'Multi', ARRAY ['Damage']);
    PERFORM add_class_passive(new_class_id, 'Essence Capture', 'Dealing damage will heal you.', 'Self', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Witchcraft', 'Gain advantage and proficiency in spellcrafting and witch arts.', 'Self', ARRAY ['Resources']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Summoner', 9) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'INT', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 2);
    PERFORM add_class_ability(new_class_id, 'Void Spawn', 'Summon a [Voidling]', 5, 1, 'Field', ARRAY ['Summon']);
    PERFORM add_class_ability(new_class_id, 'Void Matter', 'Target summon, familiar, or construct_s heals [CHA base]', 1, 2, 'Single', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Guardian', 'Summon a [Void Guardian]', 10, NULL, 'Field', ARRAY ['Summon']);
    PERFORM add_class_passive(new_class_id, 'Void Blessing', 'Summons, familiars, and constructs gain +1 Level.', 'Multi', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Focus Point', 'Summons, familiars, and constructs gain 50% crit chance.', 'Multi', ARRAY ['Buff']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Death', 9) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'CON', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 2);
    PERFORM add_class_ability(new_class_id, 'Harvest', 'Deal half [CHA base] necrotic damage to all enemies.', 1, 3, 'Multi', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Death Mark', 'Inflict [Death Mark] on a single enemy for 3 rounds.', 7, 4, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Underworld', 'Remove all inflictions and debuffs on the caster.', 4, NULL, 'Self', ARRAY ['Cleanse']);
    PERFORM add_class_passive(new_class_id, 'Afterlife', 'When an enemy dies during battle, gain +1 CON for the rest of the battle.', 'Self', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Second Passing', 'Gain -3 CON. On death, ressurect with 50% max health. Refreshes every battle.', 'Sacrifice', ARRAY ['Sustain']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name) VALUES('Cleric') RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'CHA', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'DEX', 2);
    PERFORM add_class_ability(new_class_id, 'Heal', 'Heal a single ally [CHA base].', 1, 1, 'Single', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Divine Connection', 'Place [Faith] on a single ally for 3 rounds.', 3, 3, 'Single', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Holy Spear', 'Deal [CHA base] holy damage to a single enemy.', 1, 1, 'Single', ARRAY ['Damage']);
    PERFORM add_class_passive(new_class_id, 'Resurrection', 'The next ally that dies will be resurrected. Occurs once per battle.', 'Single', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Prayer', 'On turn skip, all party members gain [Defense] for 1 round.', 'Multi', ARRAY ['Sustain']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Diviner', 13) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'CHA', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'DEX', 2);
    PERFORM add_class_ability(new_class_id, 'Fortune', 'Target gains [Fortune].', 1, 1, 'Single', ARRAY ['Any']);
    PERFORM add_class_ability(new_class_id, 'Misfortune', 'Target gains [Misfortune].', 1, 1, 'Single', ARRAY ['Any']);
    PERFORM add_class_ability(new_class_id, 'Blessing', 'Target gains +1 on all stats for 2 rounds.', 4, 2, 'Single', ARRAY ['Buff']);
    INSERT INTO class_passive(class_id, passive_id) VALUES (new_class_id, (SELECT id FROM passive WHERE passive.name = 'Foresight'));
    PERFORM add_class_passive(new_class_id, 'Lucky', 'Party gains +1 on rolls.', 'Multi', ARRAY ['Any']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Radiance', 13) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'INT', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 2);
    PERFORM add_class_ability(new_class_id, 'Solar Beam', 'Deal [INT base] light damage to a single enemy.', 1, 1, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Reflect', 'Inflict [Mirror] at a single target for 4 rounds.', 1, 3, 'Multi', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Shun', '[Stun] a single target.', 1, 1, 'Single', ARRAY ['CC']);
    PERFORM add_class_passive(new_class_id, 'Absolute', 'Upon dying, deal x2 [INT base] light damage on all enemies.', 'Revenge', ARRAY ['Damage']);
    PERFORM add_class_passive(new_class_id, 'Spectrum', 'Critical hits on enemies will apply [Mirror] for 1 round.', 'Multi', ARRAY ['Damage']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Cultist', 13) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 2);
    PERFORM add_class_ability(new_class_id, 'Surge', 'Deal [WIS base] dark damage to a single enemy.', 1, 1, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Chain Bind', '[Stun] a single enemy and another random enemy,.', 2, 3, 'Multi', ARRAY ['CC']);
    PERFORM add_class_ability(new_class_id, 'Ritual', '[Stun] all enemies and deal half [WIS base] dark damage.', 6, 6, 'Multi', ARRAY ['CC']);
    PERFORM add_class_passive(new_class_id, 'Devotion', 'Gain WIS for the amount of enemies inflicted with [Stun].', 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Bow', 'Skipping grants you [Defense] for 1 round.', 'Self', ARRAY ['Sustain']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name) VALUES('Mage') RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'INT', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 2);
    PERFORM add_class_stat(new_class_id, 'DEX', 2);
    PERFORM add_class_ability(new_class_id, 'Magic Missile', 'Deal [INT Base] magical damage to a single target.', 1, 1, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Mana Flux', 'Gain [Mana Flux] for 3 rounds.', 6, 2, 'Self', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Hyper Flux', 'Consume all MP, granting INT for each MP consumed for 2 rounds.', 3, NULL, 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Wisdom Buffer', 'Gain 1+ WIS.', 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Continuity', 'Reduce Magic base damage intake by half.', 'Self', ARRAY ['Sustain']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Artificer', 17) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 2);
    PERFORM add_class_ability(new_class_id, 'Pulse Fire', 'Deal [WIS base] magic damage to a single enemy.', 1, 1, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Tech Advancement', 'Grant an ally [Upgrade] for 1 round.', 3, 5, 'Single', ARRAY ['Buff']);
    PERFORM add_class_ability(new_class_id, 'Holo Shield', 'Grant [Magic Shield] for you or an ally for 2 rounds.', 3, 2, 'Single', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Magic Tinkerer', 'Gain advantage on Magic item crafting.', 'Self', ARRAY ['Resources']);
    PERFORM add_class_passive(new_class_id, 'Creativity', 'Gain +1 CHA.', 'Self', ARRAY ['Buff']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Wizard', 17) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'INT', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 2);
    PERFORM add_class_ability(new_class_id, 'Fireball', 'Deal [INT base] Fire damage.', 1, 1, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Ice Spike', 'Deal [INT base] Ice damage.', 1, 1, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Shatter', 'Deal [INT base] physical damage to all enemies.', 2, 3, 'Multi', ARRAY ['Damage']);
    PERFORM add_class_passive(new_class_id, 'Tempest', 'Grant yourself and your allies +1 DEX.', 'Multi', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Spell Proficiency', 'Gain advantage on spellcrafting.', 'Self', ARRAY ['Resources']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Sorcerer', 17) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'INT', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'DEX', 2);
    PERFORM add_class_ability(new_class_id, 'Destruction', 'Gain [Destruction].', 1, 1, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Serenity', 'Gain [Serenity].', 1, 1, 'Multi', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Obedience', 'Gain [Obedience].', 1, 1, 'Multi', ARRAY ['Any']);
    PERFORM add_class_passive(new_class_id, 'Spell Memory', 'Gain +1 INT.', 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Spellcraft', 'Gain advantage on spellcrafting.', 'Self', ARRAY ['Resources']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name) VALUES('Ranger') RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'DEX', 1);
    PERFORM add_class_stat(new_class_id, 'STR', 2);
    PERFORM add_class_ability(new_class_id, 'Arrow Shot', 'Fire an arrow to deal [DEX base] physical damage.', 1, NULL, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Arrow Infusion', 'Apply a chosen infliction on the next Arrow Shot.', 1, 2, 'Self', ARRAY ['Buff']);
    PERFORM add_class_ability(new_class_id, 'Headshot', 'Next Arrow Shot will crit.', 6, NULL, 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Arrow Proficiency', 'Gain x2 arrows on crafting.', 'Self', ARRAY ['Resources']);
    PERFORM add_class_passive(new_class_id, 'Arrow Counter', 'Successful dodges from you or an ally grants fire Arrow Shot.', 'Self', ARRAY ['Buff']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Gunslinger', 21) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'STR', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 2);
    PERFORM add_class_ability(new_class_id, 'Open Fire', 'Deal [STR base] physical damage to a single enemy.', 1, 1, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Deadeye', 'Gain 50% crit damage boost for 4 rounds.', 3, 2, 'Self', ARRAY ['Buff']);
    PERFORM add_class_ability(new_class_id, 'Riptide Shots', 'Deal x2 [STR base] physical damage to a single enemy.', 3, 2, 'Single', ARRAY ['Damage']);
    PERFORM add_class_passive(new_class_id, 'Headshot', 'Gain 25% crit chance.', 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Quick Shot', '[Stun] enemies automatically casts Open Fire on them at no cost.', 'Auto', ARRAY ['Damage']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Wild Card', 21) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'DEX', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'STR', 2);
    PERFORM add_class_stat(new_class_id, 'INT', 2);
    PERFORM add_class_ability(new_class_id, 'Reshuffle', 'Reshuffle Deck Buff', 1, 1, 'Self', ARRAY ['Buff']);
    PERFORM add_class_ability(new_class_id, 'Card Toss', 'Deal [DEX base] physical damage to a single enemy.', 1, 1, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Quick Feet', 'Gain [Quick Feet] for 1 round.', 3, 2, 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Deck Buff', 'Randomly gain [Mana Card], [Flame Card], or [Heal Card].', 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Loot Lucky', 'Gain advantage while collecting loot.', 'Self', ARRAY ['Resources']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name) VALUES('Hunter') RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'DEX', 1);
    PERFORM add_class_stat(new_class_id, 'STR', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 2);
    PERFORM add_class_ability(new_class_id, 'Shank', 'Deal [STR base] physical damage to a single target.', 1, NULL, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Bear Trap', '[Stun] a single target for one round.', 3, NULL, 'Single', ARRAY ['CC']);
    PERFORM add_class_ability(new_class_id, 'Hunters Mark', 'Apply [Hunter Mark] on a single target for 3 rounds.', 3, NULL, 'Single', ARRAY ['Debuff']);
    PERFORM add_class_passive(new_class_id, 'Swift Feet', 'Gain advantage on dodge rolls.', 'Self', ARRAY ['Stealth']);
    PERFORM add_class_passive(new_class_id, 'Hunting Proficiency', 'Gain advantage on material scavenging.', 'Self', ARRAY ['Resources']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Rogue', 24) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'DEX', 1);
    PERFORM add_class_stat(new_class_id, 'STR', 2);
    PERFORM add_class_ability(new_class_id, 'Hide', 'Become invisible for 1 round.', 1, NULL, 'Self', ARRAY ['Stealth']);
    PERFORM add_class_ability(new_class_id, 'Pickpocket', 'Deal [STR base] physical damage with a chance to receive gold.', 1, NULL, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Execute', 'Deal [STR base] physical damage, executing enemies at or below 10% max health. Executing resets cooldown.', 8, NULL, 'Single', ARRAY ['Damage']);
    PERFORM add_class_passive(new_class_id, 'Lootrunner', 'Gain advantage on loot opening.', 'Self', ARRAY ['Resources']);
    PERFORM add_class_passive(new_class_id, 'Lockpick', 'Gain advantage on lock picking.', 'Self', ARRAY ['Any']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Nightmare', 24) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'DEX', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'STR', 2);
    PERFORM add_class_ability(new_class_id, 'Fear', 'Inflict [Fear], to a single enemy for 3 rounds.', 3, 2, 'Single', ARRAY ['Debuff']);
    PERFORM add_class_ability(new_class_id, 'Dread', 'Inflict [Nightmare Strike] to a single enemy for 2 rounds.', 1, 1, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Terror', 'Deal [STR base] physical damage, consuming all stacks of [Nightmare Strike].', 8, 4, 'Single', ARRAY ['Damage']);
    PERFORM add_class_passive(new_class_id, 'Anxiety', '[Fear], [Stun], and [Slow] triggers Dread on the target.', 'Auto', ARRAY ['Damage']);
    PERFORM add_class_passive(new_class_id, 'Shadow Step', 'Gain +1 DEX.', 'Self', ARRAY ['Buff']);
END $$;
'cc'
DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Tricker', 24) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'DEX', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 2);
    PERFORM add_class_ability(new_class_id, 'Fake Out', 'Summon a [Self Replica].', 3, 2, 'Field', ARRAY ['Summon']);
    PERFORM add_class_ability(new_class_id, 'Laughter', 'Deal half [DEX base] magic damage to all enemies.', 1, 1, 'Multi', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Jack in the Box', 'Inflict a random Debuff/Infliction to all enemies.', 8, 4, 'Multi', ARRAY ['Debuff']);
    PERFORM add_class_passive(new_class_id, 'Jackpot', 'Every 3 rounds, flip a coin to receive bonuses.', 'Self', ARRAY ['Resources']);
    PERFORM add_class_passive(new_class_id, 'Grand Illusion', 'Party gains dodge advantage.', 'Multi', ARRAY ['Stealth']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name) VALUES('Bard') RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'CHA', 1);
    PERFORM add_class_stat(new_class_id, 'DEX', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 2);
    PERFORM add_class_ability(new_class_id, 'Melody', 'Grant a single ally +1 [STR] and +1 [INT].', 1, NULL, 'Single', ARRAY ['Buff']);
    PERFORM add_class_ability(new_class_id, 'Sound Wave', 'Grant all allies [Inspire] and enemies [Discourage].', 3, 2, 'Multi', ARRAY ['Buff']);
    PERFORM add_class_ability(new_class_id, 'Reverb', 'Grant a single ally [Double Cast].', 7, 3, 'Single', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Tuning', 'Increased instrument mastery.', 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Natural Charm', 'Gain persuasion advantage.', 'Self', ARRAY ['Buff']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Tamer', 28) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'CHA', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'DEX', 2);
    PERFORM add_class_ability(new_class_id, 'Charm', 'Apply [Charm] to a single enemy for 2 rounds.', 2, NULL, 'Single', ARRAY ['CC']);
    PERFORM add_class_ability(new_class_id, 'Submission', 'Inflict [Complete Submission] on a single target.', 1, 5, 'Single', ARRAY ['Summon']);
    PERFORM add_class_ability(new_class_id, 'Demand', 'Grant your familiar [Double Cast]', 6, 1, 'Single', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Charisma Advantage', 'Gain +1 CHA.', 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Familiar Advancement', 'Grant +1 Level for familiars.', 'Multi', ARRAY ['Buff']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Puppeteer', 28) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'CHA', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'DEX', 2);
    PERFORM add_class_ability(new_class_id, 'String', 'Inflict [Strung] on a single enemy.', 1, 1, 'Single', ARRAY ['Debuff']);
    PERFORM add_class_ability(new_class_id, 'Pull', 'Deal [CHA base] magic damage to a single enemy. May convert [Strung] to [Stun].', 1, 4, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Control', 'Inflict [Puppeted] to a single enemy for 5 rounds.', 7, 4, 'Single', ARRAY ['CC']);
    PERFORM add_class_passive(new_class_id, 'Dexful Hands', 'Gain +1 DEX.', 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Puppet Show', 'Gain +1 CHA for each enemy inflicted with [Strung].', 'Self', ARRAY ['Buff']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Performer', 28) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 1);
    PERFORM add_class_stat(new_class_id, 'INT', 2);
    PERFORM add_class_ability(new_class_id, 'High Note', 'Deal half [CHA base] magic damage to a single enemy.', 1, 2, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Minor Note', 'Grant the party [Remedy] for 3 rounds.', 4, 6, 'Multi', ARRAY ['Buff']);
    PERFORM add_class_ability(new_class_id, 'Major Note', 'Grant the party [Legato] for 3 rounds.', 7, 9, 'Multi', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Show Time', 'Evert third ability used, enter [Stage Mode] for 3 rounds.', 'Auto', ARRAY ['Cleanse']);
    PERFORM add_class_passive(new_class_id, 'Background Track', 'Every round, cleanse a random ally of one debuff, infliction, or crowd control.', 'Random', ARRAY ['Cleanse']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name) VALUES('Fighter') RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'STR', 1);
    PERFORM add_class_stat(new_class_id, 'CON', 2);
    PERFORM add_class_ability(new_class_id, 'Strike1', 'Deal [STR base] physical damage to a single enemy.', 1, NULL, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Parry', 'Grant [Parry].', 3, NULL, 'Revenge', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Defend', 'Grant [Defense] for 1 round.', 1, NULL, 'Self', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Strong Heart', 'Gain [Strong Heart].', 'Self', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Honor', 'Party gains +1 STR.', 'Multi', ARRAY ['Buff']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Pugilist', 32) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'STR', 1);
    PERFORM add_class_stat(new_class_id, 'DEX', 2);
    PERFORM add_class_ability(new_class_id, 'Punch', 'Deal [STR base] physical damage, applying [Imbalance] for 1 round.', 1, NULL, 'Single', ARRAY ['Damage', 'CC']);
    PERFORM add_class_ability(new_class_id, 'Kick', 'Deal [STR base] physical damage, applying [Stun] for 1 round.', 3, NULL, 'Single', ARRAY ['Damage', 'CC']);
    PERFORM add_class_ability(new_class_id, 'Guard1', 'Gain [Defense] for 2 rounds.', 3, NULL, 'Self', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'No Weapon', 'Gain +1 STR and +1 CON when weapon slot is empty.', 'Sacrifice', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Inner Strength', 'Gain +1 STR.', 'Self', ARRAY ['Buff']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Monk', 32) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'CON', 2);
    PERFORM add_class_ability(new_class_id, 'Bonk', 'Deal half [WIS base] physical damage to a single enemy, gaining [Ki].', 1, 1, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Meditate', 'Convert [Ki] to [Regeneration].', 1, 2, 'Self', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Ki Unlock', 'Convert [Ki] to [Bonk Boost].', 1, 1, 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Ki Protection', 'Ki grants +1 CON per stack.', 'Self', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Hard Body', 'Gain +1 CON.', 'Self', ARRAY ['Sustain']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Captain', 32) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'STR', 1);
    PERFORM add_class_stat(new_class_id, 'DEX', 2);
    PERFORM add_class_ability(new_class_id, 'Orange', 'Heal [STR base] and cleanse [Poison].', 3, NULL, 'Self', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Rally', 'Grant the party +1 STR and +1 DEX for 3 rounds.', 3, NULL, 'Multi', ARRAY ['Buff']);
    PERFORM add_class_ability(new_class_id, 'Cannon', 'Summon a [Cannon].', 1, NULL, 'Field', ARRAY ['Summon']);
    PERFORM add_class_passive(new_class_id, 'Crew', 'Gain +1 STR for every living party member.', 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Leadership', 'Gain advantage on initiative roll.', 'Self', ARRAY ['Buff']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name) VALUES('Knight') RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'CON', 1);
    PERFORM add_class_stat(new_class_id, 'STR', 2);
    PERFORM add_class_ability(new_class_id, 'Bash', 'Deal [CON base] physical damage to a single target.', 1, NULL, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Defensive Stance', 'Grant [Defense] for 2 rounds.', 4, NULL, 'Self', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Slash1', 'Deal [STR base] physical damage to a single enemy.', 1, NULL, 'Single', ARRAY ['Damage']);
    PERFORM add_class_passive(new_class_id, 'Survivability', 'Party gains +1 CON.', 'Multi', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Shield Proficiency', 'Gain Shield Level +1.', 'Self', ARRAY ['Buff']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Paladin', 36) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'CHA', 1);
    PERFORM add_class_stat(new_class_id, 'CON', 1);
    PERFORM add_class_stat(new_class_id, 'STR', 2);
    PERFORM add_class_ability(new_class_id, 'Retribution', 'Deal half [CHA base] Strength damage to a single target.', 1, 1, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Redemption', 'Party gains [Regeneration] for 3 rounds.', 3, NULL, 'Multi', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Divine Smite', 'Deal [CHA base] holy damage to all enemies.', 4, 3, 'Multi', ARRAY ['Damage']);
    PERFORM add_class_passive(new_class_id, 'Holy Protection', 'Gain CON equal to half of base CHA.', 'Self', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Holy Spirit', 'Gain +1 CON.', 'Self', ARRAY ['Sustain']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('King', 36) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'CON', 1);
    PERFORM add_class_stat(new_class_id, 'STR', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 2);
    PERFORM add_class_ability(new_class_id, 'Command', 'Grant target ally [Triumph] for 1 round.', 1, NULL, 'Single', ARRAY ['Buff']);
    PERFORM add_class_ability(new_class_id, 'Plunge', 'Deal 2x [STR base] physical damage to target enemy.', 2, NULL, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Guard Stance', 'Party gains [Defense] for 2 rounds.', 4, NULL, 'Multi', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Honor1', 'Gain CON equal to half of STR.', 'Self', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Vows', 'Taking damage grants [Defense] for 1 round.', 'Revenge', ARRAY ['Sustain']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Blade Dancer', 36) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'DEX', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'STR', 2);
    PERFORM add_class_ability(new_class_id, 'Blade Surge', 'Deal half [DEX base] physical damage to target enemy.', 1, 1, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Sharp Rain', 'Deal half [DEX base] physical damage to all enemies.', 1, 2, 'Multi', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Dancing Blade', 'Summon a [Floating Blade]', 1, 6, 'Field', ARRAY ['Summon']);
    PERFORM add_class_passive(new_class_id, 'Blade Form', 'Abilities grant [Bladedancer Form] until attacked.', 'Self', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Blade Stance', 'Having 2 stacks of [Floating Blade] grants [Defense+].', 'Self', ARRAY ['Sustain']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name) VALUES('Scholar') RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 2);
    PERFORM add_class_ability(new_class_id, 'Lost Spell', 'Replenish all party mana by half of [WIS base].', 5, NULL, 'Multi', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Portal', 'Target ally gains [Warp].', 2, 3, 'Single', ARRAY ['Stealth']);
    PERFORM add_class_ability(new_class_id, 'Quotation', 'Deal [WIS base] magic damage to a single enemy.', 1, 1, 'Single', ARRAY ['Damage']);
    PERFORM add_class_passive(new_class_id, 'Learning', 'Party gains +1 Level.', 'Multi', ARRAY ['Buff']);
    PERFORM add_class_passive(new_class_id, 'Understanding', 'Allies gain +1 Spell Level.', 'Multi', ARRAY ['Buff']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Doorman', 40) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'CON', 1);
    PERFORM add_class_stat(new_class_id, 'WIS', 2);
    PERFORM add_class_ability(new_class_id, 'Doorbell', 'Gain [Defense+] for 3 rounds.', 3, 5, 'Self', ARRAY ['Sustain']);
    PERFORM add_class_ability(new_class_id, 'Lock', 'Disable target [Doorway].', 1, NULL, 'Single');
    PERFORM add_class_ability(new_class_id, 'Unlock', 'Enable target [Doorway].', 1, NULL, 'Single', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Otherworldly', 'Gain double max health.', 'Self', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Doorway', 'Gain [Doorway].', 'Multi', ARRAY ['Sustain']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Janitor', 40) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 2);
    PERFORM add_class_ability(new_class_id, 'Window Clean', 'Target ally gains [Immunity] for 2 rounds.', 6, 2, 'Single', ARRAY ['Cleanse']);
    PERFORM add_class_ability(new_class_id, 'Spray Cleaner', 'Target gains [Poison] for 2 rounds.', 2, 3, 'Single', ARRAY ['DoT']);
    PERFORM add_class_ability(new_class_id, 'Sweep', 'Remove all debuffs and inflictions from target ally.', 1, 1, 'Single', ARRAY ['Cleanse']);
    PERFORM add_class_passive(new_class_id, 'Wet Floor Sign', 'All enemies gain [Slippery].', 'Multi', ARRAY ['Debuff']);
    PERFORM add_class_passive(new_class_id, 'Clean', 'Gain immunity to inflictions and debuffs.', 'Self', ARRAY ['Cleanse']);
END $$;

DO $$
DECLARE
    new_class_id INT;
BEGIN
    INSERT INTO class(name, parent_id) VALUES('Messenger', 40) RETURNING id INTO new_class_id;
    PERFORM add_class_stat(new_class_id, 'WIS', 1);
    PERFORM add_class_stat(new_class_id, 'CHA', 2);
    PERFORM add_class_ability(new_class_id, 'Notes', 'Deal [WIS base] psychic damage to a single enemy.', 1, 2, 'Single', ARRAY ['Damage']);
    PERFORM add_class_ability(new_class_id, 'Bird Call', 'Summon [Bird Familiar].', 6, 5, 'Field', ARRAY ['Summon']);
    PERFORM add_class_ability(new_class_id, 'Passage', 'Target enemy gains [Passage] for 3 rounds.', 3, 3, 'Self', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Calling', 'Gain CON equal to half of WIS.', 'Self', ARRAY ['Sustain']);
    PERFORM add_class_passive(new_class_id, 'Reply', 'Taking damage from enemies with [Passage] causes them to receive the same amount of damage.', 'Revenge', ARRAY ['Damage']);
END $$;
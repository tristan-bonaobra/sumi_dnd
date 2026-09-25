### [Link to Realms Unknown Canva PDF binaries](https://drive.google.com/drive/folders/1zZixfmZYeETFU3_8plNsSCOCGb-4USUY?usp=sharing)

# About

sumi_dnd is a specialized Canva PDF extractor and search interface layer for Realms Unknown.

# Usage guide

Here's how to use this thing, for both users and admins.

## For users

1. Simply extract and run the command line interface under Releases.
2. Search with any combination of these prefixes:

| Prefix | Example values |
| :- | :- |
| `effect:` | damage, dot, cc, buff, debuff, cleanse, sustain, antiheal, stealth, perception, resources, summon, persuasion, any, null |
| `skill:` | slash, guard |
| `target:` | single, multi, self, random, revenge, auto, sacrifice, field, null |
| `type:` | ability, passive |
| `class:` | knight, warrior |
| `keyword:` | stun, defense+, rage, ... |

## For database admins

1. Set up a PostgreSQL database.

   * **IMPORTANT**: Multiple steps during the ingestion process wipe the database entirely. There's a lot of nuking going on but I'd say the important baseline is the binaries and everything else is just the translation layer on top.

2. Extract the latest binaries into `src/dnd_ingest/pdf/dm` (see above link) and configure `config.toml` in the root folder accordingly.
3. Add and configure `.env` files to connect to your database (see below format).
4. Call `dnd_ingest.main`.

### .env format

1. For `src/dnd_ingest/db/.env`:

   > DATABASE_URL=
   > 
   > READONLY_PASSWORD=

2. For `src/dnd_app/db/.env`:

   > DB_HOST=
   > 
   > DB_PORT=
   > 
   > DB_NAME=
   > 
   > DB_USER=
   > 
   > DB_PASSWORD=

# Main features

Subpackages and stuff that makes this turn.

## Cloud infrastructure

The apps under Releases connect to a free and secure cloud database provided by [**Neon**](https://github.com/neondatabase/neon).

## dnd_ingest.db

Handles database connection and reinitialization.

| Feature | Description |
| :- | :- |
| `get_engine` | Returns an [**SQLAlchemy**](https://github.com/sqlalchemy/sqlalchemy) engine to connect with the database. |
| `reinitialize_database` | Initiates the reinitialization process. |

**⚠️ A .env is expected here containing `DATABASE_URL` and `READONLY_PASSWORD`.**

**⚠️ Reinitialization deletes the existing database.**

### Reinitialization steps

1. Nuke existing database
2. Create `readonly` role with password `READONLY_PASSWORD`
3. Create tables and views (see `sql/schema.sql`)

## dnd_ingest.pdf

Handles the PDF-to-database data pipeline.

| Feature | Description |
| :- | :- |
| `extract_classes_from_pdf` |  Uses [**pdfplumber**](https://github.com/jsvine/pdfplumber) analysis to convert Realms Unknown Canva PDFs into JSON. |
| `insert_pdf` |  Inserts the extracted JSONs into the database. |
| `insert_keywords_for_skill_type` |  Uses regular expressions to extract keywords, wrapped in square brackets, and inserts them into the database. |

**⚠️ The program assumes that all class cards look more or less as seen in `dm/class_template.pdf`.**

### Canva formatting assumptions

1. All class cards have a copy of the same rectangular image behind them.
2. All cards follow the same set of known markers in the text.
3. All comments are a mid gray and italic.
4. Subheaders in the skill card are always bold and are always the only bold text in the skill card.
5. Skill cards are split vertically at the subheader that says "Passive".
6. Stat cards follow this order of data:

   * Main stats
   * Sub stats
   * Bonus attributes

7. The source PDF uses a DeviceRGB color space.

There are built-in buffers to account for slight deviations.

## dnd_ingest.tag

Generates and inserts effect and target type tags for abilities and passives.

| Feature | Description |
| :- | :- |
| `TargetType` | Class used for seeding and prompting. |
| `Effect` | Class used for seeding and prompting. |
| `seed_tags` | Inserts tags into the database's tag dimension tables as normalization. |
| `nuke_database_and_generate_prompts` | Clears the database to insert legacy manual seed data to use in the LLM prompt. |
| `insert_tags_for_skills` | Chooses tags using [**Llama 3.2**](https://ollama.com/library/llama3.2) **via** [**Ollama**](https://github.com/ollama/ollama) and inserts them into the database junction tables. |

**⚠️ Prompt generation deletes the existing database.**

# Other features

Features too minor for their own sections.

## dnd_ingest/config.py

Handles reading `config.toml` at project root.

## dnd_ingest/main.py

Orchestrates database ingestion by calling the above functions. 

## dnd_ingest.db

Works similarly to `dnd_ingest.db`.

**⚠️ A .env is expected here containing `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, and `DB_PASSWORD`.**

## dnd_app/main.py

Code for the frontend CLI. Uses fuzzy search.

# Credits

Tristan Bonaobra (Author)

Zedryck Pugayan (Assets)
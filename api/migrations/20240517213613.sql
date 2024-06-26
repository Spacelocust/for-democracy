-- Create enum type "role"
CREATE TYPE "role" AS ENUM ('admin', 'user');
-- Create enum type "objective_type"
CREATE TYPE "objective_type" AS ENUM ('terminate_illegal_broadcast', 'pump_fuel_to_icbm', 'upload_escape_pod_data', 'conduct_geological_survey', 'launch_icbm', 'retrieve_valuable_data', 'emergency_evacuation', 'spread_democracy', 'eliminate_brood_commanders', 'purge_hatcheries', 'activate_e710_pumps', 'blitz_search_and_destroy_terminids', 'eliminate_chargers', 'eradicate_terminid_swarm', 'eliminate_bile_titans', 'enable_e710_extraction', 'eliminate_devastators', 'sabotage_supply_bases', 'destroy_transmission_network', 'eradicate_automaton_forces', 'blitz_search_and_destroy_automatons', 'sabotage_air_base', 'eliminate_automaton_factory_strider', 'destroy_command_bunkers');
-- Create enum type "stratagem_use_type"
CREATE TYPE "stratagem_use_type" AS ENUM ('self', 'team', 'shared');
-- Create enum type "stratagem_type"
CREATE TYPE "stratagem_type" AS ENUM ('supply', 'mission', 'defensive', 'offensive');
-- Create enum type "stratagem_keys"
CREATE TYPE "stratagem_keys" AS ENUM ('up', 'down', 'left', 'right');
-- Create enum type "faction"
CREATE TYPE "faction" AS ENUM ('humans', 'terminids', 'automatons', 'illuminates');
-- Create enum type "event_type"
CREATE TYPE "event_type" AS ENUM ('defence', 'liberation');
-- Create enum type "difficulty"
CREATE TYPE "difficulty" AS ENUM ('trivial', 'easy', 'medium', 'challenging', 'hard', 'extreme', 'suicide_mission', 'impossible', 'helldive');
-- Create "biomes" table
CREATE TABLE "biomes" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "name" text NOT NULL,
  "description" text NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "uni_biomes_name" UNIQUE ("name")
);
-- Create index "idx_biomes_deleted_at" to table: "biomes"
CREATE INDEX "idx_biomes_deleted_at" ON "biomes" ("deleted_at");
-- Create "features" table
CREATE TABLE "features" (
  "deleted_at" timestamptz NULL,
  "code" text NOT NULL,
  "enabled" boolean NOT NULL DEFAULT true,
  "updated_at" timestamptz NULL,
  "created_at" timestamptz NULL,
  PRIMARY KEY ("code")
);
-- Create index "idx_features_deleted_at" to table: "features"
CREATE INDEX "idx_features_deleted_at" ON "features" ("deleted_at");
-- Create "planets" table
CREATE TABLE "planets" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "name" text NOT NULL,
  "max_health" bigint NOT NULL,
  "disabled" boolean NOT NULL DEFAULT false,
  "regeneration" bigint NOT NULL DEFAULT 0,
  "position_x" numeric NOT NULL,
  "position_y" numeric NOT NULL,
  "helldivers_id" bigint NOT NULL,
  "image_url" text NOT NULL,
  "initial_owner" "faction" NOT NULL,
  "owner" "faction" NOT NULL,
  "biome_id" bigint NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "uni_planets_name" UNIQUE ("name"),
  CONSTRAINT "fk_biomes_planets" FOREIGN KEY ("biome_id") REFERENCES "biomes" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_planets_deleted_at" to table: "planets"
CREATE INDEX "idx_planets_deleted_at" ON "planets" ("deleted_at");
-- Create "defences" table
CREATE TABLE "defences" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "health" bigint NOT NULL,
  "start_at" timestamptz NULL,
  "end_at" timestamptz NULL,
  "ennemy_faction" "faction" NOT NULL,
  "ennemy_health" bigint NOT NULL,
  "ennemy_max_health" bigint NOT NULL,
  "helldivers_id" bigint NOT NULL,
  "planet_id" bigint NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "uni_defences_helldivers_id" UNIQUE ("helldivers_id"),
  CONSTRAINT "fk_planets_defence" FOREIGN KEY ("planet_id") REFERENCES "planets" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_defences_deleted_at" to table: "defences"
CREATE INDEX "idx_defences_deleted_at" ON "defences" ("deleted_at");
-- Create "groups" table
CREATE TABLE "groups" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "code" text NULL,
  "name" text NOT NULL,
  "description" text NULL,
  "public" boolean NOT NULL DEFAULT true,
  "start_at" timestamptz NOT NULL,
  "difficulty" "difficulty" NOT NULL,
  PRIMARY KEY ("id")
);
-- Create index "idx_groups_deleted_at" to table: "groups"
CREATE INDEX "idx_groups_deleted_at" ON "groups" ("deleted_at");
-- Create "users" table
CREATE TABLE "users" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "steam_id" text NULL,
  "username" text NOT NULL,
  "password" text NULL,
  "avatar_url" text NULL,
  "role" "role" NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "uni_users_steam_id" UNIQUE ("steam_id"),
  CONSTRAINT "uni_users_username" UNIQUE ("username")
);
-- Create index "idx_users_deleted_at" to table: "users"
CREATE INDEX "idx_users_deleted_at" ON "users" ("deleted_at");
-- Create "group_users" table
CREATE TABLE "group_users" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "group_id" bigint NULL,
  "user_id" bigint NULL,
  "owner" boolean NOT NULL DEFAULT false,
  PRIMARY KEY ("id"),
  CONSTRAINT "fk_group_users_group" FOREIGN KEY ("group_id") REFERENCES "groups" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_users_group_users" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_group_users_deleted_at" to table: "group_users"
CREATE INDEX "idx_group_users_deleted_at" ON "group_users" ("deleted_at");
-- Create "missions" table
CREATE TABLE "missions" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "name" text NOT NULL,
  "instructions" text NULL,
  "objective_types" text[] NOT NULL,
  "group_id" bigint NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "fk_groups_missions" FOREIGN KEY ("group_id") REFERENCES "groups" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_missions_deleted_at" to table: "missions"
CREATE INDEX "idx_missions_deleted_at" ON "missions" ("deleted_at");
-- Create "group_user_missions" table
CREATE TABLE "group_user_missions" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "mission_id" bigint NULL,
  "group_user_id" bigint NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "fk_group_user_missions_group_user" FOREIGN KEY ("group_user_id") REFERENCES "group_users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_missions_group_user_missions" FOREIGN KEY ("mission_id") REFERENCES "missions" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_group_user_missions_deleted_at" to table: "group_user_missions"
CREATE INDEX "idx_group_user_missions_deleted_at" ON "group_user_missions" ("deleted_at");
-- Create "stratagems" table
CREATE TABLE "stratagems" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "code_name" text NULL,
  "name" text NOT NULL,
  "use_count" bigint NULL,
  "use_type" text NOT NULL,
  "cooldown" bigint NOT NULL,
  "activation" bigint NOT NULL,
  "image_url" text NOT NULL,
  "type" "stratagem_type" NOT NULL,
  "keys" text[] NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "uni_stratagems_name" UNIQUE ("name")
);
-- Create index "idx_stratagems_deleted_at" to table: "stratagems"
CREATE INDEX "idx_stratagems_deleted_at" ON "stratagems" ("deleted_at");
-- Create "group_user_mission_stratagems" table
CREATE TABLE "group_user_mission_stratagems" (
  "stratagem_id" bigint NOT NULL,
  "group_user_mission_id" bigint NOT NULL,
  PRIMARY KEY ("stratagem_id", "group_user_mission_id"),
  CONSTRAINT "fk_group_user_mission_stratagems_group_user_mission" FOREIGN KEY ("group_user_mission_id") REFERENCES "group_user_missions" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_group_user_mission_stratagems_stratagem" FOREIGN KEY ("stratagem_id") REFERENCES "stratagems" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create "liberations" table
CREATE TABLE "liberations" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "health" bigint NOT NULL,
  "players" bigint NOT NULL,
  "helldivers_id" bigint NOT NULL,
  "planet_id" bigint NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "uni_liberations_helldivers_id" UNIQUE ("helldivers_id"),
  CONSTRAINT "fk_planets_liberation" FOREIGN KEY ("planet_id") REFERENCES "planets" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_liberations_deleted_at" to table: "liberations"
CREATE INDEX "idx_liberations_deleted_at" ON "liberations" ("deleted_at");
-- Create "effects" table
CREATE TABLE "effects" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "name" text NOT NULL,
  "description" text NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "uni_effects_name" UNIQUE ("name")
);
-- Create index "idx_effects_deleted_at" to table: "effects"
CREATE INDEX "idx_effects_deleted_at" ON "effects" ("deleted_at");
-- Create "planet_effects" table
CREATE TABLE "planet_effects" (
  "planet_id" bigint NOT NULL,
  "effect_id" bigint NOT NULL,
  PRIMARY KEY ("planet_id", "effect_id"),
  CONSTRAINT "fk_planet_effects_effect" FOREIGN KEY ("effect_id") REFERENCES "effects" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "fk_planet_effects_planet" FOREIGN KEY ("planet_id") REFERENCES "planets" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create "statistics" table
CREATE TABLE "statistics" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "planet_id" bigint NULL,
  "helldivers_id" bigint NOT NULL,
  "missions_won" bigint NOT NULL DEFAULT 0,
  "mission_time" bigint NOT NULL DEFAULT 0,
  "bug_kills" bigint NOT NULL DEFAULT 0,
  "automaton_kills" bigint NOT NULL DEFAULT 0,
  "illuminate_kills" bigint NOT NULL DEFAULT 0,
  "bullets_fired" bigint NOT NULL DEFAULT 0,
  "bullets_hit" bigint NOT NULL DEFAULT 0,
  "time_played" bigint NOT NULL DEFAULT 0,
  "deaths" bigint NOT NULL DEFAULT 0,
  "revives" bigint NOT NULL DEFAULT 0,
  "friendly_kills" bigint NOT NULL DEFAULT 0,
  "mission_success_rate" bigint NOT NULL DEFAULT 0,
  "accuracy" bigint NOT NULL DEFAULT 0,
  PRIMARY KEY ("id"),
  CONSTRAINT "uni_statistics_helldivers_id" UNIQUE ("helldivers_id"),
  CONSTRAINT "fk_planets_statistic" FOREIGN KEY ("planet_id") REFERENCES "planets" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_statistics_deleted_at" to table: "statistics"
CREATE INDEX "idx_statistics_deleted_at" ON "statistics" ("deleted_at");

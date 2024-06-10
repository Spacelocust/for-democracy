-- Modify "defences" table
ALTER TABLE "defences" DROP COLUMN "enemy_health", DROP COLUMN "enemy_max_health", ADD COLUMN "max_health" bigint NOT NULL, ADD COLUMN "impact_per_hour" numeric NOT NULL DEFAULT 0;
-- Modify "planets" table
ALTER TABLE "planets" DROP COLUMN "regeneration";
-- Modify "statistics" table
ALTER TABLE "statistics" ALTER COLUMN "mission_success_rate" TYPE numeric, ALTER COLUMN "accuracy" TYPE numeric, ADD COLUMN "missions_lost" bigint NOT NULL DEFAULT 0;
-- Create "defence_health_histories" table
CREATE TABLE "defence_health_histories" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "health" bigint NOT NULL,
  "defence_id" bigint NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "fk_defences_defence_health_histories" FOREIGN KEY ("defence_id") REFERENCES "defences" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_defence_health_histories_deleted_at" to table: "defence_health_histories"
CREATE INDEX "idx_defence_health_histories_deleted_at" ON "defence_health_histories" ("deleted_at");
-- Modify "liberations" table
ALTER TABLE "liberations" ADD COLUMN "regeneration_per_hour" numeric NOT NULL, ADD COLUMN "impact_per_hour" numeric NOT NULL DEFAULT 0;
-- Create "liberation_health_histories" table
CREATE TABLE "liberation_health_histories" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "health" bigint NOT NULL,
  "liberation_id" bigint NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "fk_liberations_liberation_health_histories" FOREIGN KEY ("liberation_id") REFERENCES "liberations" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_liberation_health_histories_deleted_at" to table: "liberation_health_histories"
CREATE INDEX "idx_liberation_health_histories_deleted_at" ON "liberation_health_histories" ("deleted_at");

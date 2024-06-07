-- Modify "liberations" table
ALTER TABLE "liberations" ADD COLUMN "regeneration" numeric NOT NULL;
-- Modify "planets" table
ALTER TABLE "planets" DROP COLUMN "regeneration";
-- Modify "statistics" table
ALTER TABLE "statistics" ALTER COLUMN "mission_success_rate" TYPE numeric, ALTER COLUMN "accuracy" TYPE numeric, ADD COLUMN "missions_lost" bigint NOT NULL DEFAULT 0;
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

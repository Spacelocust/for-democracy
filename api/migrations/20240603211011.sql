-- Modify "defences" table
ALTER TABLE "defences" DROP COLUMN "enemy_health", DROP COLUMN "enemy_max_health", ADD COLUMN "max_health" bigint NOT NULL;

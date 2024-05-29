-- Modify "sectors" table
ALTER TABLE "sectors" ADD COLUMN "helldivers_id" bigint NOT NULL, ADD CONSTRAINT "uni_sectors_helldivers_id" UNIQUE ("helldivers_id");

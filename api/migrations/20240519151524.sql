-- Create "sectors" table
CREATE TABLE "sectors" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "name" text NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "uni_sectors_name" UNIQUE ("name")
);
-- Create index "idx_sectors_deleted_at" to table: "sectors"
CREATE INDEX "idx_sectors_deleted_at" ON "sectors" ("deleted_at");
-- Modify "planets" table
ALTER TABLE "planets" ADD COLUMN "sector_id" bigint NULL, ADD
 CONSTRAINT "fk_sectors_planets" FOREIGN KEY ("sector_id") REFERENCES "sectors" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION;

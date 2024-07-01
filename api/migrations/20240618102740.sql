-- Modify "groups" table
ALTER TABLE "groups" ADD COLUMN "planet_id" bigint NULL, ADD
 CONSTRAINT "fk_planets_group" FOREIGN KEY ("planet_id") REFERENCES "planets" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION;

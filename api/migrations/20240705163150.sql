-- Modify "groups" table
ALTER TABLE "groups" ALTER COLUMN "public" DROP DEFAULT, ADD COLUMN "planet_id" bigint NULL, ADD
 CONSTRAINT "fk_planets_group" FOREIGN KEY ("planet_id") REFERENCES "planets" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION;
-- Modify "missions" table
ALTER TABLE "missions" DROP CONSTRAINT "fk_groups_missions", ADD
 CONSTRAINT "fk_groups_missions" FOREIGN KEY ("group_id") REFERENCES "groups" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "group_user_missions" table
ALTER TABLE "group_user_missions" DROP CONSTRAINT "fk_missions_group_user_missions", ADD
 CONSTRAINT "fk_missions_group_user_missions" FOREIGN KEY ("mission_id") REFERENCES "missions" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "group_user_mission_stratagems" table
ALTER TABLE "group_user_mission_stratagems" DROP CONSTRAINT "fk_group_user_mission_stratagems_group_user_mission", DROP CONSTRAINT "fk_group_user_mission_stratagems_stratagem", ADD
 CONSTRAINT "fk_group_user_mission_stratagems_group_user_mission" FOREIGN KEY ("group_user_mission_id") REFERENCES "group_user_missions" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD
 CONSTRAINT "fk_group_user_mission_stratagems_stratagem" FOREIGN KEY ("stratagem_id") REFERENCES "stratagems" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "group_users" table
ALTER TABLE "group_users" DROP CONSTRAINT "fk_group_users_group", ADD
 CONSTRAINT "fk_groups_group_users" FOREIGN KEY ("group_id") REFERENCES "groups" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;

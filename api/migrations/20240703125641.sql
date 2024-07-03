-- Modify "group_user_mission_stratagems" table
ALTER TABLE "group_user_mission_stratagems" DROP CONSTRAINT "fk_group_user_mission_stratagems_group_user_mission", DROP CONSTRAINT "fk_group_user_mission_stratagems_stratagem", ADD
 CONSTRAINT "fk_group_user_mission_stratagems_group_user_mission" FOREIGN KEY ("group_user_mission_id") REFERENCES "group_user_missions" ("id") ON UPDATE NO ACTION ON DELETE CASCADE, ADD
 CONSTRAINT "fk_group_user_mission_stratagems_stratagem" FOREIGN KEY ("stratagem_id") REFERENCES "stratagems" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;

-- Modify "missions" table
ALTER TABLE "missions" DROP CONSTRAINT "fk_groups_missions", ADD
 CONSTRAINT "fk_groups_missions" FOREIGN KEY ("group_id") REFERENCES "groups" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "group_user_missions" table
ALTER TABLE "group_user_missions" DROP CONSTRAINT "fk_missions_group_user_missions", ADD
 CONSTRAINT "fk_missions_group_user_missions" FOREIGN KEY ("mission_id") REFERENCES "missions" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- Modify "group_users" table
ALTER TABLE "group_users" DROP CONSTRAINT "fk_group_users_group", ADD
 CONSTRAINT "fk_groups_group_users" FOREIGN KEY ("group_id") REFERENCES "groups" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;

-- Modify "group_user_missions" table
ALTER TABLE "group_user_missions" ADD
 CONSTRAINT "fk_group_users_group_user_missions" FOREIGN KEY ("group_user_id") REFERENCES "group_users" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;

-- Modify "features" table
ALTER TABLE "features" DROP CONSTRAINT "features_pkey", ADD COLUMN "id" bigserial NOT NULL, ADD PRIMARY KEY ("id"), ADD CONSTRAINT "uni_features_code" UNIQUE ("code");
-- Modify "group_user_missions" table
ALTER TABLE "group_user_missions" DROP CONSTRAINT "fk_group_user_missions_group_user";

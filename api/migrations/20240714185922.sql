-- Create "token_fcms" table
CREATE TABLE "token_fcms" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "token" text NOT NULL,
  "user_id" bigint NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "uni_token_fcms_token" UNIQUE ("token"),
  CONSTRAINT "fk_users_token_fcm" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_token_fcms_deleted_at" to table: "token_fcms"
CREATE INDEX "idx_token_fcms_deleted_at" ON "token_fcms" ("deleted_at");

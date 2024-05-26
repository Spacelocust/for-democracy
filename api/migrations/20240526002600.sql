-- Create "sessions" table
CREATE TABLE "sessions" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "verification_key" text NULL,
  "access_token" text NULL,
  "expires_at" timestamptz NULL,
  "user_id" bigint NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "uni_sessions_user_id" UNIQUE ("user_id"),
  CONSTRAINT "fk_users_session" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- Create index "idx_sessions_deleted_at" to table: "sessions"
CREATE INDEX "idx_sessions_deleted_at" ON "sessions" ("deleted_at");

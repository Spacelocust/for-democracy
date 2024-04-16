-- Create "users" table
CREATE TABLE "users" (
  "id" bigserial NOT NULL,
  "created_at" timestamptz NULL,
  "updated_at" timestamptz NULL,
  "deleted_at" timestamptz NULL,
  "username" text NOT NULL,
  "password" text NOT NULL,
  "email" text NOT NULL,
  "role" text NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "uni_users_email" UNIQUE ("email"),
  CONSTRAINT "uni_users_username" UNIQUE ("username")
);
-- Create index "idx_users_deleted_at" to table: "users"
CREATE INDEX "idx_users_deleted_at" ON "users" ("deleted_at");

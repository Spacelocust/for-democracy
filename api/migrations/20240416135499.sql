-- Create "users" table
CREATE TABLE "session_storage" (
  "k" character varying(64),
  "v" bytea,
  "e" bigint
  PRIMARY KEY ("k"),
);

-- Modify "planets" table
ALTER TABLE "planets" ADD COLUMN "waypoints" text NOT NULL DEFAULT '[]';

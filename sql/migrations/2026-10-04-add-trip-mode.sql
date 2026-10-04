-- Existing trips remain group trips, including those with one member.
ALTER TABLE trip_trips
  ADD COLUMN trip_mode ENUM('group', 'solo') NOT NULL DEFAULT 'group' AFTER name;

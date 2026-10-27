ALTER TABLE trip_trips ADD COLUMN destinations_json TEXT NULL;
ALTER TABLE trip_travel_places
  ADD COLUMN trip_id INT UNSIGNED NULL,
  ADD COLUMN source_key VARCHAR(40) NOT NULL DEFAULT 'manual',
  ADD COLUMN trip_name VARCHAR(120) NULL,
  ADD COLUMN title VARCHAR(120) NOT NULL DEFAULT '',
  ADD COLUMN photo_data MEDIUMBLOB NULL,
  ADD COLUMN photo_source VARCHAR(10) NULL,
  ADD COLUMN photo_version INT UNSIGNED NOT NULL DEFAULT 0,
  DROP INDEX uniq_travel_visit,
  ADD UNIQUE KEY uniq_travel_visit (user_id, place_key, visited_on, source_key),
  ADD CONSTRAINT fk_travel_places_trip FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE SET NULL;

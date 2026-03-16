SET @trip_trips_image_path_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_trips'
    AND column_name = 'image_path'
);

SET @trip_trips_image_path_sql := IF(
  @trip_trips_image_path_exists = 0,
  'ALTER TABLE trip_trips ADD COLUMN image_path VARCHAR(255) NULL AFTER created_by',
  'SELECT 1'
);

PREPARE stmt_trip_trips_image_path FROM @trip_trips_image_path_sql;
EXECUTE stmt_trip_trips_image_path;
DEALLOCATE PREPARE stmt_trip_trips_image_path;

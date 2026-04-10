SET @trip_trips_date_from_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_trips'
    AND column_name = 'date_from'
);

SET @trip_trips_date_from_sql := IF(
  @trip_trips_date_from_exists = 0,
  'ALTER TABLE trip_trips ADD COLUMN date_from DATE NULL DEFAULT NULL AFTER created_by',
  'SELECT 1'
);

PREPARE stmt_trip_trips_date_from FROM @trip_trips_date_from_sql;
EXECUTE stmt_trip_trips_date_from;
DEALLOCATE PREPARE stmt_trip_trips_date_from;

SET @trip_trips_date_to_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_trips'
    AND column_name = 'date_to'
);

SET @trip_trips_date_to_sql := IF(
  @trip_trips_date_to_exists = 0,
  'ALTER TABLE trip_trips ADD COLUMN date_to DATE NULL DEFAULT NULL AFTER date_from',
  'SELECT 1'
);

PREPARE stmt_trip_trips_date_to FROM @trip_trips_date_to_sql;
EXECUTE stmt_trip_trips_date_to;
DEALLOCATE PREPARE stmt_trip_trips_date_to;

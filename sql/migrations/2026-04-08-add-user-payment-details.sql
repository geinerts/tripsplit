SET @trip_users_bank_country_code_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'bank_country_code'
);

SET @trip_users_bank_country_code_sql := IF(
  @trip_users_bank_country_code_exists = 0,
  'ALTER TABLE trip_users ADD COLUMN bank_country_code CHAR(2) NULL AFTER avatar_path',
  'SELECT 1'
);

PREPARE stmt_trip_users_bank_country_code FROM @trip_users_bank_country_code_sql;
EXECUTE stmt_trip_users_bank_country_code;
DEALLOCATE PREPARE stmt_trip_users_bank_country_code;

SET @trip_users_bank_account_holder_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'bank_account_holder'
);

SET @trip_users_bank_account_holder_sql := IF(
  @trip_users_bank_account_holder_exists = 0,
  'ALTER TABLE trip_users ADD COLUMN bank_account_holder VARCHAR(120) NULL AFTER bank_country_code',
  'SELECT 1'
);

PREPARE stmt_trip_users_bank_account_holder FROM @trip_users_bank_account_holder_sql;
EXECUTE stmt_trip_users_bank_account_holder;
DEALLOCATE PREPARE stmt_trip_users_bank_account_holder;

SET @trip_users_bank_account_number_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'bank_account_number'
);

SET @trip_users_bank_account_number_sql := IF(
  @trip_users_bank_account_number_exists = 0,
  'ALTER TABLE trip_users ADD COLUMN bank_account_number VARCHAR(64) NULL AFTER bank_account_holder',
  'SELECT 1'
);

PREPARE stmt_trip_users_bank_account_number FROM @trip_users_bank_account_number_sql;
EXECUTE stmt_trip_users_bank_account_number;
DEALLOCATE PREPARE stmt_trip_users_bank_account_number;

SET @trip_users_bank_iban_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'bank_iban'
);

SET @trip_users_bank_iban_sql := IF(
  @trip_users_bank_iban_exists = 0,
  'ALTER TABLE trip_users ADD COLUMN bank_iban VARCHAR(34) NULL AFTER bank_account_number',
  'SELECT 1'
);

PREPARE stmt_trip_users_bank_iban FROM @trip_users_bank_iban_sql;
EXECUTE stmt_trip_users_bank_iban;
DEALLOCATE PREPARE stmt_trip_users_bank_iban;

SET @trip_users_bank_bic_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'bank_bic'
);

SET @trip_users_bank_bic_sql := IF(
  @trip_users_bank_bic_exists = 0,
  'ALTER TABLE trip_users ADD COLUMN bank_bic VARCHAR(11) NULL AFTER bank_iban',
  'SELECT 1'
);

PREPARE stmt_trip_users_bank_bic FROM @trip_users_bank_bic_sql;
EXECUTE stmt_trip_users_bank_bic;
DEALLOCATE PREPARE stmt_trip_users_bank_bic;

SET @trip_users_bank_sort_code_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'bank_sort_code'
);

SET @trip_users_bank_sort_code_sql := IF(
  @trip_users_bank_sort_code_exists = 0,
  'ALTER TABLE trip_users ADD COLUMN bank_sort_code VARCHAR(16) NULL AFTER bank_bic',
  'SELECT 1'
);

PREPARE stmt_trip_users_bank_sort_code FROM @trip_users_bank_sort_code_sql;
EXECUTE stmt_trip_users_bank_sort_code;
DEALLOCATE PREPARE stmt_trip_users_bank_sort_code;

SET @trip_users_bank_routing_number_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'bank_routing_number'
);

SET @trip_users_bank_routing_number_sql := IF(
  @trip_users_bank_routing_number_exists = 0,
  'ALTER TABLE trip_users ADD COLUMN bank_routing_number VARCHAR(16) NULL AFTER bank_sort_code',
  'SELECT 1'
);

PREPARE stmt_trip_users_bank_routing_number FROM @trip_users_bank_routing_number_sql;
EXECUTE stmt_trip_users_bank_routing_number;
DEALLOCATE PREPARE stmt_trip_users_bank_routing_number;

SET @trip_users_revolut_handle_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'revolut_handle'
);

SET @trip_users_revolut_handle_sql := IF(
  @trip_users_revolut_handle_exists = 0,
  'ALTER TABLE trip_users ADD COLUMN revolut_handle VARCHAR(80) NULL AFTER bank_routing_number',
  'SELECT 1'
);

PREPARE stmt_trip_users_revolut_handle FROM @trip_users_revolut_handle_sql;
EXECUTE stmt_trip_users_revolut_handle;
DEALLOCATE PREPARE stmt_trip_users_revolut_handle;

SET @trip_users_paypal_me_link_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'paypal_me_link'
);

SET @trip_users_paypal_me_link_sql := IF(
  @trip_users_paypal_me_link_exists = 0,
  'ALTER TABLE trip_users ADD COLUMN paypal_me_link VARCHAR(255) NULL AFTER revolut_handle',
  'SELECT 1'
);

PREPARE stmt_trip_users_paypal_me_link FROM @trip_users_paypal_me_link_sql;
EXECUTE stmt_trip_users_paypal_me_link;
DEALLOCATE PREPARE stmt_trip_users_paypal_me_link;

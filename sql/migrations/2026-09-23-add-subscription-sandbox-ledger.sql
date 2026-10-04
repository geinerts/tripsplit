-- Sandbox ledger only. These tables do not grant production entitlements.
CREATE TABLE IF NOT EXISTS trip_subscription_accounts (
  user_id INT UNSIGNED NOT NULL,
  account_token CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  verification_sequence BIGINT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  UNIQUE KEY uq_subscription_account_token (account_token),
  CONSTRAINT fk_subscription_account_user FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_subscription_sandbox_attempts (
  account_token CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  request_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  reference_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  verification_sequence BIGINT UNSIGNED NOT NULL,
  status ENUM('pending', 'applied', 'superseded', 'failed') NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (account_token, request_hash),
  KEY idx_subscription_sandbox_attempts_created (created_at),
  CONSTRAINT fk_subscription_sandbox_attempt_account FOREIGN KEY (account_token)
    REFERENCES trip_subscription_accounts(account_token) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_subscription_sandbox_purchases (
  purchase_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  account_token CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  store ENUM('app_store', 'play_store') NOT NULL,
  product_id VARCHAR(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  expires_at_ms BIGINT UNSIGNED NULL,
  access_allowed TINYINT UNSIGNED NOT NULL,
  provider_status VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  auto_renew TINYINT UNSIGNED NOT NULL,
  verified_at_ms BIGINT UNSIGNED NOT NULL,
  verification_sequence BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (purchase_hash),
  KEY idx_subscription_sandbox_purchase_account (account_token),
  CONSTRAINT fk_subscription_sandbox_purchase_account FOREIGN KEY (account_token)
    REFERENCES trip_subscription_accounts(account_token) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

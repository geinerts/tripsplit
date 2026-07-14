ALTER TABLE trip_payments
  MODIFY COLUMN status ENUM('requested', 'sent', 'confirmed', 'cancelled') NOT NULL DEFAULT 'sent',
  ADD COLUMN requester_user_id INT UNSIGNED NULL AFTER note,
  ADD COLUMN requested_at TIMESTAMP NULL DEFAULT NULL AFTER requester_user_id,
  MODIFY COLUMN cancel_reason ENUM(
    'sender_cancelled',
    'not_received',
    'request_cancelled',
    'request_declined'
  ) NULL,
  ADD KEY idx_trip_payments_requester (requester_user_id),
  ADD CONSTRAINT fk_trip_payments_requester_user_id
    FOREIGN KEY (requester_user_id) REFERENCES trip_users(id) ON DELETE SET NULL;

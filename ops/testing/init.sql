USE splyto_security_test;
CREATE TABLE splyto_test_environment (
    marker VARCHAR(64) PRIMARY KEY
) ENGINE=InnoDB;
INSERT INTO splyto_test_environment VALUES ('synthetic-registration-tests-only');

CREATE USER 'splyto_runtime_test'@'%' IDENTIFIED BY 'isolated-runtime-only';
GRANT SELECT, INSERT, UPDATE, DELETE ON splyto_security_test.* TO 'splyto_runtime_test'@'%';

USE splyto_security_test;
CREATE TABLE splyto_test_environment (
    marker VARCHAR(64) PRIMARY KEY
) ENGINE=InnoDB;
INSERT INTO splyto_test_environment VALUES ('synthetic-registration-tests-only');

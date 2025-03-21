-- This table is for archived employees but is not referenced anywhere
CREATE TABLE archived_employee (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255),
    exit_date DATE
);

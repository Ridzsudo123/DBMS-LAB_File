-- Experiment 8: Financial-Style Database Transactions & Concurrency Control (PostgreSQL)

-- A. Create the Financial Accounts Table
CREATE TABLE Financial_Accounts (
    acc_num INT PRIMARY KEY,
    client_name VARCHAR(50),
    funds NUMERIC(12, 2) CHECK (funds >= 0)
);

INSERT INTO Financial_Accounts VALUES
(201, 'Vikram', 15000.00),
(202, 'Sita', 8000.00);

SELECT * FROM Financial_Accounts;

-- B. Demonstrate BEGIN and COMMIT
BEGIN;

UPDATE Financial_Accounts
SET funds = funds - 3000
WHERE acc_num = 201;

UPDATE Financial_Accounts
SET funds = funds + 3000
WHERE acc_num = 202;

COMMIT;

SELECT * FROM Financial_Accounts;

-- C. Demonstrate ROLLBACK
BEGIN;

UPDATE Financial_Accounts
SET funds = funds - 1500
WHERE acc_num = 201;

SELECT * FROM Financial_Accounts;

ROLLBACK;

SELECT * FROM Financial_Accounts;

-- D. Demonstrate SAVEPOINT
BEGIN;

UPDATE Financial_Accounts
SET funds = funds - 800
WHERE acc_num = 201;

SAVEPOINT checkpoint1;

UPDATE Financial_Accounts
SET funds = funds - 50000
WHERE acc_num = 201;

ROLLBACK TO SAVEPOINT checkpoint1;

UPDATE Financial_Accounts
SET funds = funds + 800
WHERE acc_num = 202;

COMMIT;

SELECT * FROM Financial_Accounts;

-- E. Demonstrate Transaction Isolation
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

START TRANSACTION;

SELECT * FROM Financial_Accounts;

COMMIT;

-- F. Demonstrate Concurrency Anomalies Using Two Sessions
-- Session 1:
BEGIN;

UPDATE Financial_Accounts
SET funds = 12000
WHERE acc_num = 201;

-- Session 2:
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT funds FROM Financial_Accounts WHERE acc_num = 201;

COMMIT;

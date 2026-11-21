-- Experiment 10: Query Optimization & Execution Plan Analysis (MySQL)

-- 1. Database and Table Creation
CREATE DATABASE IF NOT EXISTS CorpDataDB;
USE CorpDataDB;

DROP TABLE IF EXISTS StaffRecords;

CREATE TABLE StaffRecords (
    staff_id INT PRIMARY KEY,
    full_name VARCHAR(60) NOT NULL,
    division VARCHAR(30) NOT NULL,
    compensation INT NOT NULL,
    location VARCHAR(40) NOT NULL,
    join_date DATE NOT NULL,
    rating DECIMAL(4,2) NOT NULL
);

-- 2. Generate Over 10,000 Rows
SET SESSION cte_max_recursion_depth = 11000;

INSERT INTO StaffRecords (staff_id, full_name, division, compensation, location, join_date, rating)
WITH RECURSIVE num_seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM num_seq WHERE n < 10500
)
SELECT 
    n,
    CONCAT('Staff_', n),
    ELT((n MOD 5) + 1, 'Engineering', 'Marketing', 'Accounts', 'Sales', 'Logistics'),
    35000 + ((n * 143) MOD 85001),
    ELT((n MOD 6) + 1, 'Kanpur', 'Chandigarh', 'Noida', 'Gurugram', 'Bengaluru', 'Hyderabad'),
    DATE_ADD('2015-01-01', INTERVAL (n MOD 3500) DAY),
    1.00 + ((n MOD 50) / 10.0)
FROM num_seq;

SELECT COUNT(*) AS total_rows FROM StaffRecords;

-- 3. Query 1: Index Suppression via Function
-- Slow Query:
EXPLAIN SELECT staff_id, full_name, join_date FROM StaffRecords WHERE YEAR(join_date) = 2022;

-- Optimized Query:
CREATE INDEX idx_join_date ON StaffRecords(join_date);
EXPLAIN SELECT staff_id, full_name, join_date FROM StaffRecords WHERE join_date >= '2022-01-01' AND join_date <= '2022-12-31';

-- 4. Query 2: Inefficient Wildcard Search
-- Slow Query:
EXPLAIN SELECT staff_id, full_name FROM StaffRecords WHERE full_name LIKE '%888%';

-- Optimized Query:
CREATE INDEX idx_full_name ON StaffRecords(full_name);
EXPLAIN SELECT staff_id, full_name FROM StaffRecords WHERE full_name LIKE 'Staff_888%';

-- 5. Query 3: Missing Index on Frequently Filtered Column
-- Slow Query:
EXPLAIN SELECT staff_id, full_name, compensation FROM StaffRecords WHERE division = 'Accounts';

-- Optimized Query:
CREATE INDEX idx_division ON StaffRecords(division);
EXPLAIN SELECT staff_id, full_name, compensation FROM StaffRecords WHERE division = 'Accounts';

-- 6. Query 4: Correlated Subquery Bottleneck
-- Slow Query:
EXPLAIN SELECT s.staff_id, s.full_name, s.division, s.compensation
FROM StaffRecords s
WHERE s.compensation > (
    SELECT AVG(s2.compensation) 
    FROM StaffRecords s2 
    WHERE s2.division = s.division
);

-- Optimized Query:
CREATE INDEX idx_div_comp ON StaffRecords(division, compensation);
EXPLAIN SELECT s.staff_id, s.full_name, s.division, s.compensation
FROM StaffRecords s
JOIN (
    SELECT division, AVG(compensation) AS avg_comp
    FROM StaffRecords
    GROUP BY division
) AS d ON d.division = s.division
WHERE s.compensation > d.avg_comp;

-- 7. Query 5: OR Condition Index Degradation
-- Slow Query:
EXPLAIN SELECT staff_id, full_name, division, location
FROM StaffRecords 
WHERE division = 'Engineering' OR location = 'Kanpur';

-- Optimized Query:
CREATE INDEX idx_loc ON StaffRecords(location);
EXPLAIN SELECT staff_id, full_name, division, location
FROM StaffRecords 
WHERE division = 'Engineering'
UNION
SELECT staff_id, full_name, division, location
FROM StaffRecords 
WHERE location = 'Kanpur';

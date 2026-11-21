-- --------------------------------------------------------
-- Experiment 9 Source Code
-- --------------------------------------------------------

-- Phase 1: Database Setup and Data Generation
CREATE DATABASE IF NOT EXISTS TrainSysDB;
USE TrainSysDB;

CREATE TABLE Ticket_Reservations (
    ticket_id INT PRIMARY KEY,
    passenger VARCHAR(50) NOT NULL,
    route_no INT NOT NULL,
    start_point VARCHAR(30) NOT NULL,
    end_point VARCHAR(30) NOT NULL,
    travel_date DATE NOT NULL,
    coach_type VARCHAR(5),
    seat_num INT,
    price DECIMAL(8,2),
    reservation_status VARCHAR(15)
);

SET SESSION cte_max_recursion_depth = 10000;

INSERT INTO Ticket_Reservations
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n+1 FROM seq WHERE n<6500
)
SELECT
    n,
    CONCAT('Traveler_', n),
    15000 + MOD(n * 7, 50),
    ELT(MOD(n, 10) + 1, 'Delhi', 'Pune', 'Kolkata', 'Chennai', 'Lucknow', 'Kanpur', 'Jaipur', 'Bhopal', 'Patna', 'Surat'),
    ELT(MOD(n*3+1, 10) + 1, 'Delhi', 'Pune', 'Kolkata', 'Chennai', 'Lucknow', 'Kanpur', 'Jaipur', 'Bhopal', 'Patna', 'Surat'),
    DATE_ADD('2026-03-01', INTERVAL MOD(n, 365) DAY),
    ELT(MOD(FLOOR(n/7), 5) + 1, 'SL', '3A', '2A', '1A', 'CC'),
    1+MOD(n*11, 72),
    300+MOD(n*37, 2700),
    ELT(MOD(FLOOR(n/3), 3) + 1, 'Confirmed', 'Waitlisted', 'Cancelled')
FROM seq;

SELECT COUNT(*) AS total_records FROM Ticket_Reservations;
SELECT * FROM Ticket_Reservations LIMIT 5;

-- Queries Used for Benchmarking
-- Query A (Single-column filter)
SELECT * FROM Ticket_Reservations WHERE route_no = 15021;

-- Query B (Multi-column filter)
SELECT * FROM Ticket_Reservations WHERE route_no = 15021 AND travel_date = '2026-08-15';

-- Query C (Non-leading column filter)
SELECT * FROM Ticket_Reservations WHERE travel_date = '2026-08-15';

-- Phase 2: Execution Without Indexes
EXPLAIN SELECT * FROM Ticket_Reservations WHERE route_no = 15021;
EXPLAIN ANALYZE SELECT * FROM Ticket_Reservations WHERE route_no = 15021;

-- Phase 3: Impact of a Single-Column Index
CREATE INDEX idx_route ON Ticket_Reservations(route_no);
ANALYZE TABLE Ticket_Reservations;
EXPLAIN SELECT * FROM Ticket_Reservations WHERE route_no = 15021;

-- Phase 4: Impact of a Composite Index
CREATE INDEX idx_route_date ON Ticket_Reservations(route_no, travel_date);
ANALYZE TABLE Ticket_Reservations;

-- Optimal usage of composite index
EXPLAIN SELECT * FROM Ticket_Reservations WHERE route_no = 15021 AND travel_date = '2026-08-15';

-- Demonstrating the leftmost-prefix limitation
EXPLAIN SELECT * FROM Ticket_Reservations WHERE travel_date = '2026-08-15';

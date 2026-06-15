-- =========================================================================
-- SYSTEM: Football Ticket Booking System Database Setup Template
-- AUTHOR: MD. Sidur Rahaman Rupom
-- DESCRIPTION: Full DDL, Data Seeding, and Query Solutions
-- =========================================================================


-- DROP TABLES IF THEY ALREADY EXIST TO PREVENT CONFLICTS
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Matches;
DROP TABLE IF EXISTS Users;


-- =========================================================================
-- 1. CREATE USERS TABLE
-- =========================================================================
CREATE TABLE Users (
    user_id      INT            NOT NULL,
    full_name    VARCHAR(100)   NOT NULL,
    email        VARCHAR(150)   NOT NULL,
    role         VARCHAR(50)    NOT NULL,
    phone_number VARCHAR(20),                        -- nullable: Jannat Ara has NULL

    -- Primary Key
    CONSTRAINT pk_users PRIMARY KEY (user_id),

    -- Unique email
    CONSTRAINT uq_users_email UNIQUE (email),

    -- Restrict role to allowed values
    CONSTRAINT chk_users_role CHECK (role IN ('Football Fan', 'Ticket Manager'))
);


-- =========================================================================
-- 2. CREATE MATCHES TABLE
-- =========================================================================
CREATE TABLE Matches (
    match_id             INT            NOT NULL,
    fixture              VARCHAR(150)   NOT NULL,
    tournament_category  VARCHAR(100)   NOT NULL,
    base_ticket_price    NUMERIC(10, 2) NOT NULL,
    match_status         VARCHAR(50)    NOT NULL,

    -- Primary Key
    CONSTRAINT pk_matches PRIMARY KEY (match_id),

    -- Prevent negative prices
    CONSTRAINT chk_matches_price CHECK (base_ticket_price >= 0),

    -- Restrict match status to allowed values
    CONSTRAINT chk_matches_status CHECK (
        match_status IN ('Available', 'Selling Fast', 'Sold Out', 'Postponed')
    )
);


-- =========================================================================
-- 3. CREATE BOOKINGS TABLE
-- =========================================================================
CREATE TABLE Bookings (
    booking_id     INT            NOT NULL,
    user_id        INT            NOT NULL,
    match_id       INT            NOT NULL,
    seat_number    VARCHAR(20),                      -- nullable (booking 504 has NULL)
    payment_status VARCHAR(50),                      -- nullable (booking 504 has NULL)
    total_cost     NUMERIC(10, 2) NOT NULL,

    -- Primary Key
    CONSTRAINT pk_bookings PRIMARY KEY (booking_id),

    -- Foreign Key → Users
    CONSTRAINT fk_bookings_user FOREIGN KEY (user_id)
        REFERENCES Users (user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Foreign Key → Matches
    CONSTRAINT fk_bookings_match FOREIGN KEY (match_id)
        REFERENCES Matches (match_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Non-negative total cost
    CONSTRAINT chk_bookings_cost CHECK (total_cost >= 0),

    -- Restrict payment status to allowed values (also permits NULL)
    CONSTRAINT chk_bookings_status CHECK (
        payment_status IS NULL OR
        payment_status IN ('Pending', 'Confirmed', 'Cancelled', 'Refunded')
    )
);


-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO USERS
-- =========================================================================
INSERT INTO Users (user_id, full_name, email, role, phone_number) VALUES
(1, 'Tanvir Rahman',  'tanvir@mail.com', 'Football Fan',    '+8801711111111'),
(2, 'Asif Haque',     'asif@mail.com',   'Football Fan',    '+8801722222222'),
(3, 'Sajjad Rahman',  'sajjad@mail.com', 'Ticket Manager',  '+8801733333333'),
(4, 'Jannat Ara',     'jannat@mail.com', 'Football Fan',    NULL);


-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO MATCHES
-- =========================================================================
INSERT INTO Matches (match_id, fixture, tournament_category, base_ticket_price, match_status) VALUES
(101, 'Real Madrid vs Barcelona', 'Champions League', 150.00, 'Available'),
(102, 'Man City vs Liverpool',    'Premier League',   120.00, 'Selling Fast'),
(103, 'Bayern Munich vs PSG',     'Champions League', 130.00, 'Available'),
(104, 'AC Milan vs Inter Milan',  'Serie A',           90.00, 'Sold Out'),
(105, 'Juventus vs Roma',         'Serie A',           80.00, 'Available');


-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO BOOKINGS
-- =========================================================================
INSERT INTO Bookings (booking_id, user_id, match_id, seat_number, payment_status, total_cost) VALUES
(501, 1, 101, 'A-12', 'Confirmed', 150.00),
(502, 1, 102, 'B-04', 'Confirmed', 120.00),
(503, 2, 101, 'A-13', 'Confirmed', 150.00),
(504, 2, 101, NULL,   NULL,        150.00),
(505, 3, 102, 'C-20', 'Pending',   120.00);

-- =========================================================================
-- PART 2: SQL QUERIES
-- =========================================================================


-- -------------------------------------------------------------------------
-- Query 1:
-- Retrieve all upcoming football matches belonging to the 'Champions League'
-- where the match status is 'Available'.
-- -------------------------------------------------------------------------
SELECT
    match_id,
    fixture,
    base_ticket_price
FROM Matches
WHERE tournament_category = 'Champions League'
  AND match_status = 'Available';

/*
Expected Output:
match_id | fixture                  | base_ticket_price
---------+--------------------------+------------------
101      | Real Madrid vs Barcelona | 150
103      | Bayern Munich vs PSG     | 130
*/


-- -------------------------------------------------------------------------
-- Query 2:
-- Search for all users whose full names start with 'Tanvir'
-- or contain the phrase 'Haque' (case-insensitive).
-- Concepts: LIKE, ILIKE
-- -------------------------------------------------------------------------
-- PostgreSQL version (uses ILIKE for case-insensitive match):
SELECT
    user_id,
    full_name,
    email
FROM Users
WHERE full_name ILIKE 'Tanvir%'
   OR full_name ILIKE '%Haque%';

-- MySQL / SQL Server compatible alternative (LOWER + LIKE):
-- SELECT user_id, full_name, email
-- FROM Users
-- WHERE LOWER(full_name) LIKE 'tanvir%'
--    OR LOWER(full_name) LIKE '%haque%';

/*
Expected Output:
user_id | full_name     | email
--------+---------------+----------------
1       | Tanvir Rahman | tanvir@mail.com
2       | Asif Haque    | asif@mail.com
*/


-- -------------------------------------------------------------------------
-- Query 3:
-- Retrieve all booking records where the payment_status is missing (NULL),
-- replacing the empty result with 'Action Required'.
-- Concepts: IS NULL, COALESCE
-- -------------------------------------------------------------------------
SELECT
    booking_id,
    user_id,
    match_id,
    COALESCE(payment_status, 'Action Required') AS systematic_status
FROM Bookings
WHERE payment_status IS NULL;

/*
Expected Output:
booking_id | user_id | match_id | systematic_status
-----------+---------+----------+------------------
504        | 2       | 101      | Action Required
*/


-- -------------------------------------------------------------------------
-- Query 4:
-- Retrieve match booking details along with the User's full name
-- and the scheduled Match fixture teams.
-- Concepts: INNER JOIN
-- -------------------------------------------------------------------------
SELECT
    b.booking_id,
    u.full_name,
    m.fixture,
    b.total_cost
FROM Bookings b
INNER JOIN Users   u ON b.user_id  = u.user_id
INNER JOIN Matches m ON b.match_id = m.match_id
ORDER BY b.booking_id;

/*
Expected Output:
booking_id | full_name     | fixture                  | total_cost
-----------+---------------+--------------------------+-----------
501        | Tanvir Rahman | Real Madrid vs Barcelona | 150
502        | Tanvir Rahman | Man City vs Liverpool    | 120
503        | Asif Haque    | Real Madrid vs Barcelona | 150
504        | Asif Haque    | Real Madrid vs Barcelona | 150
505        | Sajjad Rahman | Man City vs Liverpool    | 120
*/


-- -------------------------------------------------------------------------
-- Query 5:
-- Display a comprehensive list of all users and their booking IDs,
-- ensuring fans who have never bought a ticket are still listed.
-- Concepts: LEFT JOIN
-- -------------------------------------------------------------------------
SELECT
    u.user_id,
    u.full_name,
    b.booking_id
FROM Users u
LEFT JOIN Bookings b ON u.user_id = b.user_id
ORDER BY u.user_id, b.booking_id;

/*
Expected Output:
user_id | full_name     | booking_id
--------+---------------+-----------
1       | Tanvir Rahman | 501
1       | Tanvir Rahman | 502
2       | Asif Haque    | 503
2       | Asif Haque    | 504
3       | Sajjad Rahman | 505
4       | Jannat Ara    | NULL
*/


-- -------------------------------------------------------------------------
-- Query 6:
-- Find all ticket bookings where the total cost is strictly higher
-- than the average cost of all ticket bookings.
-- Concepts: Subquery, AVG aggregate
-- -------------------------------------------------------------------------
SELECT
    booking_id,
    match_id,
    total_cost
FROM Bookings
WHERE total_cost > (
    SELECT AVG(total_cost)
    FROM Bookings
)
ORDER BY booking_id;

/*
AVG of all bookings = (150 + 120 + 150 + 150 + 120) / 5 = 138.00

Expected Output:
booking_id | match_id | total_cost
-----------+----------+-----------
501        | 101      | 150
503        | 101      | 150
504        | 101      | 150
*/


-- -------------------------------------------------------------------------
-- Query 7:
-- Retrieve the top 2 most expensive matches sorted by base ticket price,
-- skipping the absolute highest premium match.
-- (Skips Real Madrid vs Barcelona at 150)
-- Concepts: ORDER BY, LIMIT, OFFSET
-- -------------------------------------------------------------------------
SELECT
    match_id,
    fixture,
    base_ticket_price
FROM Matches
ORDER BY base_ticket_price DESC
LIMIT 2 OFFSET 1;

/*
Sorted order: 150 → 130 → 120 → 90 → 80
OFFSET 1 skips the first row (150), LIMIT 2 takes the next two (130, 120).

Expected Output:
match_id | fixture              | base_ticket_price
---------+----------------------+------------------
103      | Bayern Munich vs PSG | 130
102      | Man City vs Liverpool| 120
*/

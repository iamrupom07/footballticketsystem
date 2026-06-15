# 🏟️ Football Ticket Booking System

A relational database project that models a simplified football ticket booking platform. This project covers full schema design, sample data seeding, and SQL query solutions as part of a database design assignment.

---

## 📋 Project Overview

The system manages three core entities:

- **Users** — Football fans and ticket managers registered on the platform
- **Matches** — Tournament fixtures with pricing and availability status
- **Bookings** — Individual ticket purchase records linking users to matches

---

## 🗂️ Repository Structure

```
footballticketsystem/
│
└── query.sql        # Full DDL schema, sample data inserts, and all SQL query solutions
```

---

## 🧱 Database Schema

### Users
| Column | Type | Notes |
|---|---|---|
| user_id | INT | Primary Key |
| full_name | VARCHAR(100) | Not Null |
| email | VARCHAR(150) | Unique, Not Null |
| role | VARCHAR(50) | `Football Fan` or `Ticket Manager` |
| phone_number | VARCHAR(20) | Nullable |

### Matches
| Column | Type | Notes |
|---|---|---|
| match_id | INT | Primary Key |
| fixture | VARCHAR(150) | e.g. `Real Madrid vs Barcelona` |
| tournament_category | VARCHAR(100) | e.g. `Champions League` |
| base_ticket_price | NUMERIC(10,2) | Must be ≥ 0 |
| match_status | VARCHAR(50) | `Available`, `Selling Fast`, `Sold Out`, or `Postponed` |

### Bookings
| Column | Type | Notes |
|---|---|---|
| booking_id | INT | Primary Key |
| user_id | INT | Foreign Key → Users |
| match_id | INT | Foreign Key → Matches |
| seat_number | VARCHAR(20) | Nullable |
| payment_status | VARCHAR(50) | `Pending`, `Confirmed`, `Cancelled`, `Refunded`, or NULL |
| total_cost | NUMERIC(10,2) | Must be ≥ 0 |

---

## 🔗 Entity Relationships

```
Users (1) ──────────── (Many) Bookings (Many) ──────────── (1) Matches
```

- One **User** can have many **Bookings**
- One **Match** can appear in many **Bookings**
- Each **Booking** row maps exactly one user to one match (logical 1-to-1 per booking record)

---

## 🚀 How to Run

This project targets **PostgreSQL**. To set up the database locally:

1. Open your PostgreSQL client (e.g. pgAdmin, DBeaver, or `psql` terminal)
2. Create a new database:
   ```sql
   CREATE DATABASE football_ticket_system;
   ```
3. Connect to it and run the full `query.sql` file:
   ```bash
   psql -U your_username -d football_ticket_system -f query.sql
   ```

> ⚠️ The script drops existing tables at the top (`DROP TABLE IF EXISTS`) so it is safe to re-run.

---

## 📝 SQL Queries Covered

| # | Description | Concepts Used |
|---|---|---|
| 1 | Retrieve available Champions League matches | `WHERE`, multiple conditions |
| 2 | Search users by name pattern | `ILIKE`, `LIKE` |
| 3 | Find bookings with missing payment status | `IS NULL`, `COALESCE` |
| 4 | Booking details with user and match info | `INNER JOIN` |
| 5 | All users including those with no bookings | `LEFT JOIN` |
| 6 | Bookings above the average total cost | Subquery, `AVG` |
| 7 | Top 2 matches after skipping the most expensive | `ORDER BY`, `LIMIT`, `OFFSET` |

---


## 🛠️ Constraints & Design Decisions

- `CHECK` constraints enforce valid values for `role`, `match_status`, and `payment_status`
- `UNIQUE` constraint on `email` prevents duplicate user accounts
- `ON DELETE CASCADE` on foreign keys ensures booking records are removed if a user or match is deleted
- `phone_number`, `seat_number`, and `payment_status` are intentionally nullable to reflect real-world incomplete data scenarios

---

## 👤 Author

**MD. Sidur Rahaman Rupom**  
Database Design Assignment — Football Ticket Booking System



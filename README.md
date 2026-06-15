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


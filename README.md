# SQL Customer Retention & Cohort Analysis

Retention analysis written in SQL: which signup cohorts keep ordering,
how many customers buy more than once, who has gone quiet, and how much
revenue each cohort produces over time.

All data is sample/practice data created for portfolio purposes. No real
company or customer data is used anywhere in this project.

## The questions it answers

1. Of the customers who signed up in a given month, what percentage were
   still placing orders 1, 2, and 3 months later? (cohort retention)
2. What share of customers are repeat buyers, and how does their spending
   compare with one-time buyers? (repeat-purchase rate)
3. Which customers have not ordered in 90+ days and should be on a
   win-back list? (churn list)
4. How much revenue does each signup cohort generate per month after
   signup? (revenue by cohort)

## Tables (see `queries.sql` for full queries)

- `customers` (customer_id, signup_date, segment, region)
- `orders` (order_id, customer_id, order_date, status)
- `order_items` (order_id, product_id, quantity, unit_price, returned_flag)

A customer's **cohort** is the month of their signup date. **Months since
signup** is the difference in months between the cohort month and the
order month. Only `completed` orders count, and returned items are
excluded from revenue.

## What was done

- Built cohorts with `DATE_TRUNC` on signup date and joined each order to
  its customer's cohort.
- Calculated months-since-signup per order, then pivoted active customers
  per cohort per month into retention percentages.
- Separated repeat vs. one-time buyers with a per-customer order count in
  a CTE, and compared average order value between the two groups.
- Produced a churn list using `HAVING MAX(order_date) < CURRENT_DATE -
  INTERVAL '90 days'`, including each customer's lifetime order count and
  spend so the win-back list can be prioritized.
- Summed revenue by cohort and months-since-signup to show which cohorts
  keep contributing after the first month.

## Skills shown

- Cohort analysis with CTEs and date arithmetic
- Window-free pivot logic with conditional aggregation (`COUNT(DISTINCT
  ... ) FILTER` / `CASE` inside aggregates)
- Customer-level aggregation: repeat rate, lifetime value, recency
- Clear business definitions documented before the queries that use them

## Files

- `README.md` — this file
- `queries.sql` — the four retention queries, commented section by section

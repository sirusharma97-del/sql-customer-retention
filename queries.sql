-- SQL Customer Retention & Cohort Analysis — sample dataset
-- Tables:
--   customers  (customer_id, signup_date, segment, region)
--   orders     (order_id, customer_id, order_date, status)
--   order_items(order_id, product_id, quantity, unit_price, returned_flag)
-- Definitions: cohort = signup month. Only 'completed' orders count.
-- Returned items are excluded from revenue.

-- ============================================================
-- 1. Cohort retention: % of each signup cohort still ordering
--    0, 1, 2 and 3 months after signup
-- ============================================================
WITH cohort AS (
    SELECT customer_id,
           DATE_TRUNC('month', signup_date) AS cohort_month
    FROM customers
),
activity AS (
    SELECT
        c.customer_id,
        c.cohort_month,
        DATE_TRUNC('month', o.order_date) AS order_month,
        (EXTRACT(YEAR  FROM o.order_date) - EXTRACT(YEAR  FROM c.cohort_month)) * 12
      + (EXTRACT(MONTH FROM o.order_date) - EXTRACT(MONTH FROM c.cohort_month))
            AS months_since_signup
    FROM cohort c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.status = 'completed'
),
cohort_size AS (
    SELECT cohort_month, COUNT(*) AS customers_in_cohort
    FROM cohort
    GROUP BY cohort_month
),
active AS (
    SELECT
        cohort_month,
        months_since_signup,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM activity
    WHERE months_since_signup BETWEEN 0 AND 3
    GROUP BY cohort_month, months_since_signup
)
SELECT
    a.cohort_month,
    s.customers_in_cohort,
    MAX(CASE WHEN a.months_since_signup = 0 THEN a.active_customers END) AS month_0,
    ROUND(100.0 * MAX(CASE WHEN a.months_since_signup = 1 THEN a.active_customers END)
          / s.customers_in_cohort, 1) AS pct_month_1,
    ROUND(100.0 * MAX(CASE WHEN a.months_since_signup = 2 THEN a.active_customers END)
          / s.customers_in_cohort, 1) AS pct_month_2,
    ROUND(100.0 * MAX(CASE WHEN a.months_since_signup = 3 THEN a.active_customers END)
          / s.customers_in_cohort, 1) AS pct_month_3
FROM active a
JOIN cohort_size s ON s.cohort_month = a.cohort_month
GROUP BY a.cohort_month, s.customers_in_cohort
ORDER BY a.cohort_month;

-- ============================================================
-- 2. Repeat-purchase rate and average order value:
--    repeat buyers vs one-time buyers
-- ============================================================
WITH per_customer AS (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id)              AS order_count,
        SUM(oi.quantity * oi.unit_price)        AS total_spend
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'completed' AND oi.returned_flag = 0
    GROUP BY o.customer_id
)
SELECT
    COUNT(*)                                                        AS customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)                AS repeat_customers,
    ROUND(100.0 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
          / COUNT(*), 1)                                            AS repeat_pct,
    ROUND(AVG(CASE WHEN order_count > 1
                   THEN total_spend / order_count END), 2)          AS repeat_avg_order_value,
    ROUND(AVG(CASE WHEN order_count = 1
                   THEN total_spend / order_count END), 2)          AS one_time_avg_order_value
FROM per_customer;

-- ============================================================
-- 3. Churn list: customers with no completed order in 90+ days,
--    with lifetime value so the win-back list can be prioritised
-- ============================================================
SELECT
    c.customer_id,
    c.segment,
    c.region,
    MAX(o.order_date)                       AS last_order_date,
    CURRENT_DATE - MAX(o.order_date)        AS days_since_last_order,
    COUNT(DISTINCT o.order_id)              AS lifetime_orders,
    SUM(oi.quantity * oi.unit_price)        AS lifetime_spend
FROM customers c
JOIN orders o       ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
WHERE o.status = 'completed' AND oi.returned_flag = 0
GROUP BY c.customer_id, c.segment, c.region
HAVING MAX(o.order_date) < CURRENT_DATE - INTERVAL '90 days'
ORDER BY lifetime_spend DESC;

-- ============================================================
-- 4. Revenue by cohort and months since signup:
--    which cohorts keep contributing after month 0?
-- ============================================================
WITH cohort AS (
    SELECT customer_id,
           DATE_TRUNC('month', signup_date) AS cohort_month
    FROM customers
)
SELECT
    c.cohort_month,
    (EXTRACT(YEAR  FROM o.order_date) - EXTRACT(YEAR  FROM c.cohort_month)) * 12
  + (EXTRACT(MONTH FROM o.order_date) - EXTRACT(MONTH FROM c.cohort_month))
        AS months_since_signup,
    COUNT(DISTINCT o.customer_id)           AS active_customers,
    COUNT(DISTINCT o.order_id)              AS orders,
    SUM(oi.quantity * oi.unit_price)        AS revenue
FROM cohort c
JOIN orders o       ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
WHERE o.status = 'completed' AND oi.returned_flag = 0
GROUP BY c.cohort_month, months_since_signup
ORDER BY c.cohort_month, months_since_signup;

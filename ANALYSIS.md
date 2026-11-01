# Analysis — Customer Retention & Cohorts

**Sample data.** Every figure below was computed from the generated sample
dataset in `data/` (85 customers who signed up Nov 2025 – Jun 2026, 283
orders through Oct 2026), loaded into SQLite and queried with SQLite
equivalents of the queries in `queries.sql`. It is practice data — no
real customers are used. Revenue excludes returned items, only completed
orders count, and recency is measured against 2026-10-31.

## Business questions

1. After the first order, do customers come back — and how fast does
   each signup cohort fade?
2. How much of the business depends on repeat buyers?
3. Who has gone quiet, and who is worth winning back first?

## Key findings

1. **The drop-off happens immediately.** Averaged across the eight
   signup cohorts, only 33.0% of customers placed an order in the month
   after signup (cohort range: 18.2% to 40.0%). Two out of three new
   customers are already inactive by month 1 — retention is won or lost
   in the first few weeks, not over the year.
2. **The customers who stay, stay.** Month-3 retention averaged 30.6% —
   barely below the month-1 figure — and the March 2026 cohort was still
   at 45.5% in month 3. The pattern is a sharp early filter, then a
   stable core, rather than a steady leak.
3. **Repeat buyers are half the customers and most of the money.** 45 of
   85 customers (52.9%) ordered more than once, and they produced
   $40,792.05 of the $48,012.06 total net revenue (85.0%). Overall, 68.1%
   of revenue ($32,708.42) came after the signup month.
4. **Repeat buyers don't spend more per order — they just come back.**
   Repeat buyers' average order value was $168.81, slightly *below* the
   one-time buyer figure of $180.50. First orders are actually the
   biggest single baskets; lifetime value is built from frequency.
5. **More than half the customer base has gone quiet.** 46 of 85
   customers (54.1%) had no completed order in the 90 days before
   2026-10-31. The five highest-value lapsed customers account for
   $3,288.57 in lifetime spend, led by one customer with $1,148.88 across
   6 orders whose last order was 2026-06-17.

## What this means

This is a "leaky first month, loyal core" business. Acquisition is
producing customers — the failure is conversion from first order to
second. Because repeat buyers generate 85.0% of revenue at no premium in
basket size, moving even a small share of one-time buyers into a second
order is the highest-leverage growth available — cheaper than new
acquisition and aimed at the segment that already proved it will buy.

## Recommendations

1. **Build a first-30-days onboarding push.** The month-1 cliff (33.0%
   retention) is the problem to fix: a second-order incentive, a
   replenishment reminder timed to the first product's likely use, and a
   check-in email in weeks 2–3 after the first order.
2. **Find out what the strong cohorts did differently.** The March 2026
   cohort held 45.5% at month 3 vs. the February cohort's 18.2% at
   month 1 — compare their signup channel, first products, and first
   order values before assuming it's chance.
3. **Run win-back in lifetime-value order.** Start with the top of the
   churn list (the $1,148.88 / 6-order customer and the rest of the top
   five, $3,288.57 combined) with a personal offer, then work down;
   don't spend the same effort on one-order, low-spend lapses.
4. **Don't chase bigger first baskets.** One-time buyers already spend
   the most per order ($180.50). Discounting first orders to grow AOV
   would subsidize the wrong behavior — spend that money on the second
   order instead.
5. **Report cohort retention monthly with these definitions.** The
   month-1 number is the early-warning metric; if a new cohort prints
   below ~30% in month 1, intervene while there's still time to change
   its curve.

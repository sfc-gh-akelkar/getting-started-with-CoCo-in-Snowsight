----------------------------------------------------------------------
-- 06_enhanced_capabilities.sql
-- Advanced Cortex Code Features
----------------------------------------------------------------------

----------------------------------------------------------------------
-- FIX ERRORS: Run this intentionally broken query, then click the
-- "Fix" button in the results grid to let CoCo diagnose it.
----------------------------------------------------------------------
SELECT
    customer_id,
    nama,                          -- typo: should be "name"
    TOTAL(amount) AS total_spent   -- wrong function: should be SUM
FROM QUICKSTART_DB.RAW.CUSTOMERS c
JOIN QUICKSTART_DB.RAW.ORDERS o USING (customer_id)
GROUP BY 1, 2;

----------------------------------------------------------------------
-- EXPLAIN CODE: Highlight the query below, right-click, and select
-- "Explain" from quick actions to get a plain-English walkthrough.
----------------------------------------------------------------------
SELECT
    c.region,
    COUNT(DISTINCT c.customer_id)                          AS total_customers,
    COUNT(o.order_id)                                      AS total_orders,
    ROUND(SUM(o.amount), 2)                                AS total_revenue,
    ROUND(AVG(o.amount), 2)                                AS avg_order_value,
    ROUND(SUM(o.amount) / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer
FROM QUICKSTART_DB.RAW.CUSTOMERS c
LEFT JOIN QUICKSTART_DB.RAW.ORDERS o
    ON c.customer_id = o.customer_id
    AND o.status = 'completed'
GROUP BY c.region
ORDER BY total_revenue DESC;

----------------------------------------------------------------------
-- QUICK EDIT: Highlight the query above, select "Quick Edit", and
-- try a prompt like:
--   "Add a WHERE clause to filter for only the last 90 days"
----------------------------------------------------------------------

----------------------------------------------------------------------
-- FOLLOW-UP QUESTIONS: After running any query, ask CoCo:
--   "Can you add a percent-of-total column to these results?"
--   "Convert this into a CTE-based approach"
--   "Add window functions to rank customers within each region"
----------------------------------------------------------------------

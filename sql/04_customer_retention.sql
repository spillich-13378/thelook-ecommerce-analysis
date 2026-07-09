-- 04_customer_retention.sql
-- Business question: What share of customers are one-time vs repeat buyers?
-- Technique: ROW_NUMBER() to sequence each customer's orders + chained CTEs to classify.

WITH order_sequence AS (
  SELECT
    user_id,
    order_id,
    created_at,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS order_number
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status != 'Cancelled'
),
customer_summary AS (
  SELECT
    user_id,
    MAX(order_number) AS total_orders
  FROM order_sequence
  GROUP BY user_id
)
SELECT
  CASE
    WHEN total_orders = 1 THEN 'One-time'
    ELSE 'Repeat'
  END AS customer_type,
  COUNT(*) AS customers,
  ROUND(SAFE_DIVIDE(COUNT(*), SUM(COUNT(*)) OVER ()) * 100, 1) AS pct_of_customers
FROM customer_summary
GROUP BY customer_type
ORDER BY customers DESC;

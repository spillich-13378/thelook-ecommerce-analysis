-- 03_revenue_by_channel.sql
-- Business question: Which acquisition channels bring the most valuable customers?
-- Technique: JOIN + COUNT(DISTINCT user_id) + SAFE_DIVIDE for revenue-per-customer.

WITH customer_orders AS (
  SELECT
    u.traffic_source,
    oi.sale_price,
    oi.user_id
  FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
  JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
    ON oi.user_id = u.id
  WHERE oi.status != 'Cancelled'
)
SELECT
  traffic_source,
  COUNT(DISTINCT user_id) AS customers,
  ROUND(SUM(sale_price), 2) AS revenue,
  ROUND(SAFE_DIVIDE(SUM(sale_price), COUNT(DISTINCT user_id)), 2) AS revenue_per_customer
FROM customer_orders
GROUP BY traffic_source
ORDER BY revenue DESC;

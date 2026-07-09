-- 01_monthly_revenue_growth.sql
-- Business question: How is revenue trending, and what is month-over-month growth?
-- Technique: LAG() window function to compare each month to the previous one.

WITH monthly_revenue AS (
  SELECT
    DATE_TRUNC(DATE(created_at), MONTH) AS month,
    ROUND(SUM(sale_price), 2) AS revenue
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE status != 'Cancelled'
  GROUP BY month
)
SELECT
  month,
  revenue,
  LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
  ROUND(
    SAFE_DIVIDE(
      revenue - LAG(revenue) OVER (ORDER BY month),
      LAG(revenue) OVER (ORDER BY month)
    ) * 100,
    1
  ) AS mom_growth_pct
FROM monthly_revenue
ORDER BY month;

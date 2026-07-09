-- 02_top_products_by_category.sql
-- Business question: Which products lead revenue within each category?
-- Technique: JOIN + RANK() OVER (PARTITION BY category) + QUALIFY for top 3 per group.

WITH product_sales AS (
  SELECT
    p.category,
    p.name AS product_name,
    ROUND(SUM(oi.sale_price), 2) AS revenue,
    COUNT(*) AS units_sold
  FROM `bigquery-public-data.thelook_ecommerce.order_items` AS oi
  JOIN `bigquery-public-data.thelook_ecommerce.products` AS p
    ON oi.product_id = p.id
  WHERE oi.status != 'Cancelled'
  GROUP BY p.category, p.name
)
SELECT
  category,
  product_name,
  revenue,
  units_sold,
  RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_in_category
FROM product_sales
QUALIFY rank_in_category <= 3
ORDER BY category, rank_in_category;

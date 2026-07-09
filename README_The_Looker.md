# TheLook E-commerce — Sales & Customer Analysis (BigQuery)

SQL analytics on **TheLook**, a fictional e-commerce dataset with 7 related
tables (~100K+ orders). The project answers four business questions spanning
revenue trends, product performance, acquisition channels, and customer
retention — then connects the findings into a single strategic diagnosis.

**Stack:** Google BigQuery · Standard SQL (multi-table `JOIN`s, window functions
`LAG` / `RANK` / `ROW_NUMBER`, chained CTEs, `SAFE_DIVIDE`, `QUALIFY`) · Looker Studio
**Data:** `bigquery-public-data.thelook_ecommerce` (public dataset — no upload needed)

🔗 **[Live dashboard (Looker Studio)](https://datastudio.google.com/reporting/372b78d7-281a-4453-89e0-bd33dfaa3dc8)**

![Dashboard](dashboard/thelook_dashboard.png)
<!-- TODO: add dashboard/thelook_dashboard.png (export from View mode) -->

---

## Repository structure

```
thelook-ecommerce-analysis/
├── README.md
├── sql/
│   ├── 01_monthly_revenue_growth.sql     -- LAG (month-over-month growth)
│   ├── 02_top_products_by_category.sql   -- JOIN + RANK + PARTITION BY + QUALIFY
│   ├── 03_revenue_by_channel.sql         -- JOIN + COUNT(DISTINCT)
│   └── 04_customer_retention.sql         -- ROW_NUMBER + chained CTEs
└── dashboard/
```

---

## Data model

The analysis joins four of the dataset's tables. The join keys are worth noting —
column names differ across tables:

| From | Key | To |
|------|-----|-----|
| `order_items.user_id` | → | `users.id` |
| `order_items.product_id` | → | `products.id` |
| `order_items.order_id` | → | `orders.order_id` |

`order_items` is the grain (one row per product per order) and carries the
actual `sale_price`; `products` holds `retail_price` and `cost`. All queries
exclude cancelled orders (`status != 'Cancelled'`).

---

## Business questions, technique & findings

### Q1 — How is revenue trending, and what is month-over-month growth?
**Technique:** `LAG()` window function to compare each month against the previous.

Revenue grows steadily from ~$600/month in early 2019 to ~$400–500K/month by
late 2025 — a healthy, sustained upward trend with month-to-month seasonality.

> *Data-quality note:* the final month shows an apparent drop. This is an
> artifact — the dataset generates events up to the present date, so the last
> month is partial, not a real decline.

### Q2 — Which categories and products drive revenue?
**Technique:** `JOIN` (order_items × products) + `RANK() OVER (PARTITION BY category ORDER BY revenue DESC)` + `QUALIFY` to keep the top 3 per category.

Outerwear and Jeans lead category revenue. High-ticket items (e.g. premium
outerwear ~$5.7K, sunglasses ~$3.3K) concentrate revenue within their
categories. `RANK` (not `ROW_NUMBER`) was used here, so tied products correctly
share a rank.

### Q3 — Which acquisition channels bring the most valuable customers?
**Technique:** `JOIN` (order_items × users) + `COUNT(DISTINCT user_id)` + `SAFE_DIVIDE` for revenue-per-customer.

| Channel | Customers | Revenue per customer |
|---------|----------:|---------------------:|
| Search | 50,353 | $125.97 |
| Organic | 10,668 | $127.86 |
| Facebook | 4,341 | $130.55 |
| Email | 3,712 | $128.91 |
| Display | 2,929 | $125.85 |

Two findings: (1) **Search dominates volume** — it brings ~5× more customers
than all other channels combined. (2) **Revenue per customer is essentially
flat (~$126–130) across every channel** — the acquisition source does *not*
change how much a customer spends.

### Q4 — What share of customers are repeat buyers?
**Technique:** `ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at)` to sequence each customer's orders, chained CTEs to classify.

**66.7% of customers buy once and never return; only 33.3% are repeat buyers.**

---

## Synthesis — the strategic diagnosis

The four findings connect into one story:

The business is **growing** (Q1) and **acquiring customers efficiently at scale
through Search** (Q3). But it has a **critical retention leak: two out of three
customers never come back** (Q4). And because customer value is **flat across
channels** (Q3), spending more on acquisition cannot improve customer *quality* —
only volume.

**The core diagnosis: this business is optimized to acquire, not to retain.**
Pouring budget into acquisition is filling a leaking bucket. The highest-ROI
lever is **retention**, not more traffic — converting one-time buyers into
repeat customers. Q2 points to the *how*: known category best-sellers are
natural anchors for post-purchase recommendation and re-engagement campaigns.

**Recommended actions:**
1. Shift investment toward retention (post-purchase email, loyalty, re-engagement) — the 67% one-time rate is the biggest untapped value.
2. Keep Search as the volume engine, but audit low-volume channels (Facebook, Email, Display) on cost-per-acquisition, since none delivers higher-value customers to justify a premium.
3. Use category best-sellers (Q2) as anchors in retention campaigns.

> *Analyst's caveat:* the near-identical revenue-per-customer across channels
> (~$2 spread) is unusually uniform and may partly reflect how this synthetic
> dataset is generated. The analytical approach holds; the exact figures would
> vary in real data.

---

## What's next

This project consolidates advanced SQL (joins, window functions, CTEs) on data
already in the warehouse. The next project is an **end-to-end pipeline** —
Python ingestion → cloud storage → BigQuery → transformation → dashboard —
adding the *build* side of data engineering on top of the *analyze* side shown
here.

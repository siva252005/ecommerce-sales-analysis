-- ==============================================================================
-- 12_ADVANCED_BUSINESS_ANALYSIS.SQL
-- Project: E-Commerce Sales Analysis
-- Database Engine: MySQL 8.0+
-- Description: Senior analyst-level business queries combining CTEs, window functions,
--              multi-tier partitions, running totals, growth indices, threshold filters,
--              and regional/category top-N segmentations.
-- ==============================================================================

USE ecommerce_sales;

-- ------------------------------------------------------------------------------
-- 1. RUNNING CUMULATIVE REVENUE & ANNUAL RESET
-- ------------------------------------------------------------------------------
-- Business Question: What is the cumulative revenue generated within each calendar year (YTD)
--                    as well as across the lifetime of the business?
-- Explanation: Demonstrates PARTITION BY year running totals alongside all-time running totals.

WITH monthly_sales AS (
    SELECT 
        year,
        month,
        year_month,
        ROUND(SUM(sales), 2) AS monthly_revenue
    FROM sales
    GROUP BY year, month, year_month
)
SELECT 
    year_month,
    year,
    month,
    monthly_revenue,
    -- Running total within each calendar year (YTD reset)
    ROUND(
        SUM(monthly_revenue) OVER (
            PARTITION BY year 
            ORDER BY month ASC
        ), 
        2
    ) AS ytd_cumulative_sales,
    -- Lifetime all-time running cumulative revenue
    ROUND(
        SUM(monthly_revenue) OVER (
            ORDER BY year_month ASC
        ), 
        2
    ) AS lifetime_cumulative_sales
FROM monthly_sales
ORDER BY year_month ASC;

-- ------------------------------------------------------------------------------
-- 2. DUAL-AXIS GROWTH ENGINE: MoM AND YoY SAME-MONTH GROWTH
-- ------------------------------------------------------------------------------
-- Business Question: How did each month perform compared to the previous month (MoM)
--                    AND compared to the exact same month in the prior year (YoY)?
-- Explanation: Combines LAG(revenue, 1) for MoM and LAG(revenue, 12) for same-month YoY analysis.

WITH monthly_revenue AS (
    SELECT 
        year,
        month,
        year_month,
        ROUND(SUM(sales), 2) AS revenue
    FROM sales
    GROUP BY year, month, year_month
)
SELECT 
    year_month,
    revenue,
    -- Month-over-Month (MoM)
    LAG(revenue, 1) OVER (ORDER BY year_month) AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue, 1) OVER (ORDER BY year_month)) 
        / LAG(revenue, 1) OVER (ORDER BY year_month) * 100, 
        2
    ) AS mom_growth_pct,
    -- Same Month Prior Year (YoY)
    LAG(revenue, 12) OVER (ORDER BY year_month) AS same_month_prev_year_revenue,
    ROUND(
        (revenue - LAG(revenue, 12) OVER (ORDER BY year_month)) 
        / LAG(revenue, 12) OVER (ORDER BY year_month) * 100, 
        2
    ) AS same_month_yoy_growth_pct
FROM monthly_revenue
ORDER BY year_month ASC;

-- ------------------------------------------------------------------------------
-- 3. TOP 3 BEST-SELLING PRODUCTS IN EACH CATEGORY
-- ------------------------------------------------------------------------------
-- Business Question: Which top 3 products drive the most revenue within each major product category?
-- Explanation: Uses DENSE_RANK() partitioned by category to isolate the top 3 merchandise champions.

WITH category_product_performance AS (
    SELECT 
        category,
        product_id,
        product_name,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(SUM(sales), 2)     AS total_sales,
        DENSE_RANK() OVER (
            PARTITION BY category 
            ORDER BY SUM(sales) DESC
        ) AS rank_in_category
    FROM sales
    GROUP BY category, product_id, product_name
)
SELECT 
    category,
    rank_in_category,
    product_id,
    product_name,
    total_orders,
    total_sales
FROM category_product_performance
WHERE rank_in_category <= 3
ORDER BY category ASC, rank_in_category ASC;

-- ------------------------------------------------------------------------------
-- 4. TOP 3 HIGHEST-SPENDING CUSTOMERS IN EACH REGION
-- ------------------------------------------------------------------------------
-- Business Question: Who are the top 3 highest-value customers residing in each of the 4 geographic regions?
-- Explanation: Uses DENSE_RANK() partitioned by region to pinpoint premier regional accounts.

WITH regional_customer_spending AS (
    SELECT 
        region,
        customer_id,
        customer_name,
        segment,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(SUM(sales), 2)     AS total_regional_spend,
        DENSE_RANK() OVER (
            PARTITION BY region 
            ORDER BY SUM(sales) DESC
        ) AS customer_rank_in_region
    FROM sales
    GROUP BY region, customer_id, customer_name, segment
)
SELECT 
    region,
    customer_rank_in_region,
    customer_id,
    customer_name,
    segment,
    total_orders,
    total_regional_spend
FROM regional_customer_spending
WHERE customer_rank_in_region <= 3
ORDER BY region ASC, customer_rank_in_region ASC;

-- ------------------------------------------------------------------------------
-- 5. MULTI-LEVEL SALES CONTRIBUTION PERCENTAGE MATRIX
-- ------------------------------------------------------------------------------
-- Business Question: For each sub-category, what is its contribution to its parent category
--                    AND to the overall business revenue?
-- Explanation: Demonstrates nested window partitions: SUM(...) OVER (PARTITION BY category) vs SUM(...) OVER ().

SELECT 
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS sub_category_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER (PARTITION BY category) * 100, 
        2
    ) AS pct_of_category_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
        2
    ) AS pct_of_company_total_sales
FROM sales
GROUP BY category, sub_category
ORDER BY category ASC, sub_category_sales DESC;

-- ------------------------------------------------------------------------------
-- 6. TRANSACTIONS EXCEEDING COMPANY AVERAGE SALES
-- ------------------------------------------------------------------------------
-- Business Question: Which individual line-item transactions exceeded the overall company average sales amount ($230.77)?
-- Explanation: Compares individual transaction sales to a scalar subquery calculating overall mean sales.

SELECT 
    row_id,
    order_id,
    order_date,
    customer_name,
    category,
    sub_category,
    product_name,
    sales,
    ROUND((SELECT AVG(sales) FROM sales), 2) AS company_avg_sales,
    ROUND(sales - (SELECT AVG(sales) FROM sales), 2) AS excess_over_average
FROM sales
WHERE sales > (SELECT AVG(sales) FROM sales)
ORDER BY sales DESC
LIMIT 25;

-- ------------------------------------------------------------------------------
-- 7. CUSTOMERS GENERATING ABOVE-AVERAGE REVENUE
-- ------------------------------------------------------------------------------
-- Business Question: How many customers spend more than the company average customer revenue (~$2,851.87),
--                    and what proportion of total sales do they represent?
-- Explanation: Uses a CTE to aggregate customer spend and filters for accounts above the mean.

WITH customer_spend_summary AS (
    SELECT 
        customer_id,
        customer_name,
        segment,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(SUM(sales), 2)     AS total_spend
    FROM sales
    GROUP BY customer_id, customer_name, segment
),
customer_benchmark AS (
    SELECT AVG(total_spend) AS avg_customer_spend FROM customer_spend_summary
)
SELECT 
    cs.customer_id,
    cs.customer_name,
    cs.segment,
    cs.total_orders,
    cs.total_spend,
    ROUND(cs.total_spend - cb.avg_customer_spend, 2) AS spend_above_benchmark
FROM customer_spend_summary cs
CROSS JOIN customer_benchmark cb
WHERE cs.total_spend > cb.avg_customer_spend
ORDER BY cs.total_spend DESC;

-- ------------------------------------------------------------------------------
-- 8. PRODUCTS GENERATING ABOVE-AVERAGE REVENUE
-- ------------------------------------------------------------------------------
-- Business Question: Which products generate revenue higher than the average product SKU revenue (~$1,215.23)?
-- Explanation: Filters product SKUs performing above the catalog mean revenue benchmark.

WITH product_spend_summary AS (
    SELECT 
        product_id,
        product_name,
        category,
        sub_category,
        COUNT(DISTINCT order_id) AS orders_count,
        ROUND(SUM(sales), 2)     AS total_product_revenue
    FROM sales
    GROUP BY product_id, product_name, category, sub_category
),
product_benchmark AS (
    SELECT AVG(total_product_revenue) AS avg_product_revenue FROM product_spend_summary
)
SELECT 
    ps.product_id,
    ps.product_name,
    ps.category,
    ps.sub_category,
    ps.orders_count,
    ps.total_product_revenue,
    ROUND(ps.total_product_revenue - pb.avg_product_revenue, 2) AS revenue_above_benchmark
FROM product_spend_summary ps
CROSS JOIN product_benchmark pb
WHERE ps.total_product_revenue > pb.avg_product_revenue
ORDER BY ps.total_product_revenue DESC;

-- ------------------------------------------------------------------------------
-- 9. CUSTOMER RECENCY & LIFETIME MONETARY (RFM BASICS)
-- ------------------------------------------------------------------------------
-- Business Question: What is the recency of purchase (days since last order relative to catalog max date)
--                    and total transaction velocity for each customer?
-- Explanation: Calculates DATEDIFF against maximum dataset date to model recency without external date bias.

WITH dataset_bounds AS (
    SELECT MAX(order_date) AS max_dataset_date FROM sales
),
customer_rfm_raw AS (
    SELECT 
        s.customer_id,
        s.customer_name,
        s.segment,
        COUNT(DISTINCT s.order_id) AS order_frequency,
        ROUND(SUM(s.sales), 2)     AS monetary_total,
        MAX(s.order_date)          AS last_order_date,
        DATEDIFF(db.max_dataset_date, MAX(s.order_date)) AS recency_days
    FROM sales s
    CROSS JOIN dataset_bounds db
    GROUP BY s.customer_id, s.customer_name, s.segment, db.max_dataset_date
)
SELECT 
    customer_id,
    customer_name,
    segment,
    order_frequency,
    monetary_total,
    last_order_date,
    recency_days,
    CASE 
        WHEN recency_days <= 90  AND monetary_total >= 3000 THEN 'Champions (Active High Spender)'
        WHEN recency_days <= 180 AND order_frequency >= 5   THEN 'Loyal Active Customers'
        WHEN recency_days > 365  THEN 'At Risk / Lapsed'
        ELSE 'Regular Customer'
    END AS customer_lifecycle_stage
FROM customer_rfm_raw
ORDER BY monetary_total DESC
LIMIT 25;

-- ==============================================================================
-- 07_CUSTOMER_ANALYSIS.SQL
-- Project: E-Commerce Sales Analysis
-- Database Engine: MySQL 8.0+
-- Description: Customer behavioral and demographic analytics, evaluating customer
--              segments (Consumer, Corporate, Home Office), high-value customer
--              rankings, average spend benchmarks, and order frequency patterns.
-- ==============================================================================

USE ecommerce_sales;

-- ------------------------------------------------------------------------------
-- 1. SALES PERFORMANCE BY CUSTOMER SEGMENT
-- ------------------------------------------------------------------------------
-- Business Question: What is the sales volume, customer count, order count, and AOV across customer segments?
-- Explanation: Summarizes overall performance across the 3 target market segments.

SELECT 
    segment,
    COUNT(DISTINCT customer_id)                     AS total_customers,
    COUNT(DISTINCT order_id)                        AS total_orders,
    COUNT(row_id)                                   AS total_line_items,
    ROUND(SUM(sales), 2)                            AS total_sales,
    ROUND(AVG(sales), 2)                            AS avg_sales_per_line_item,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value,
    ROUND(SUM(sales) / COUNT(DISTINCT customer_id), 2) AS avg_revenue_per_customer
FROM sales
GROUP BY segment
ORDER BY total_sales DESC;

-- ------------------------------------------------------------------------------
-- 2. SEGMENT PERCENTAGE CONTRIBUTION
-- ------------------------------------------------------------------------------
-- Business Question: What share of total revenue and total customer base is represented by each segment?
-- Explanation: Uses window functions to compute both revenue share and customer count share per segment.

SELECT 
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
        2
    ) AS revenue_share_pct,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(
        COUNT(DISTINCT customer_id) / SUM(COUNT(DISTINCT customer_id)) OVER () * 100, 
        2
    ) AS customer_share_pct
FROM sales
GROUP BY segment
ORDER BY total_sales DESC;

-- ------------------------------------------------------------------------------
-- 3. TOP 10 CUSTOMERS BY TOTAL SALES SPEND
-- ------------------------------------------------------------------------------
-- Business Question: Who are the top 10 highest-value individual customers by cumulative lifetime spend?
-- Explanation: Ranks customers by total historical purchases and limits to the top 10.

SELECT 
    customer_id,
    customer_name,
    segment,
    COUNT(DISTINCT order_id) AS total_orders_placed,
    COUNT(row_id)            AS total_items_purchased,
    ROUND(SUM(sales), 2)     AS total_spend,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
        2
    ) AS pct_of_company_revenue
FROM sales
GROUP BY customer_id, customer_name, segment
ORDER BY total_spend DESC
LIMIT 10;

-- ------------------------------------------------------------------------------
-- 4. GLOBAL CUSTOMER RANKING (DENSE_RANK)
-- ------------------------------------------------------------------------------
-- Business Question: What is the formal leaderboard ranking of all 793 customers by revenue?
-- Explanation: Assigns DENSE_RANK() and ROW_NUMBER() based on total spending per customer.

SELECT 
    customer_id,
    customer_name,
    segment,
    COUNT(DISTINCT order_id)                     AS total_orders,
    ROUND(SUM(sales), 2)                         AS total_spend,
    DENSE_RANK() OVER (ORDER BY SUM(sales) DESC) AS customer_rank,
    ROUND(
        PERCENT_RANK() OVER (ORDER BY SUM(sales) ASC) * 100, 
        2
    ) AS spending_percentile
FROM sales
GROUP BY customer_id, customer_name, segment
ORDER BY customer_rank ASC;

-- ------------------------------------------------------------------------------
-- 5. CUSTOMERS WITH SPENDING ABOVE AVERAGE CUSTOMER SPEND
-- ------------------------------------------------------------------------------
-- Business Question: Which customers have generated cumulative revenue exceeding the overall average customer spend?
-- Explanation: Uses a CTE to compute the company-wide average customer spend (~$2,851.87)
--              and filters for top-tier accounts outperforming the baseline.

WITH customer_spending AS (
    SELECT 
        customer_id,
        customer_name,
        segment,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(SUM(sales), 2)     AS total_spend
    FROM sales
    GROUP BY customer_id, customer_name, segment
),
benchmark AS (
    SELECT ROUND(AVG(total_spend), 2) AS overall_avg_customer_spend
    FROM customer_spending
)
SELECT 
    cs.customer_id,
    cs.customer_name,
    cs.segment,
    cs.total_orders,
    cs.total_spend,
    b.overall_avg_customer_spend,
    ROUND(cs.total_spend - b.overall_avg_customer_spend, 2) AS spend_above_average
FROM customer_spending cs
CROSS JOIN benchmark b
WHERE cs.total_spend > b.overall_avg_customer_spend
ORDER BY cs.total_spend DESC;

-- ------------------------------------------------------------------------------
-- 6. CUSTOMER PURCHASE FREQUENCY DISTRIBUTION
-- ------------------------------------------------------------------------------
-- Business Question: How are customers distributed based on order frequency tiers (e.g., 1-2, 3-5, 6-9, 10+ orders)?
-- Explanation: Categorizes customers into frequency buckets using CASE statements inside a CTE.

WITH customer_order_counts AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) AS order_frequency,
        SUM(sales)               AS total_spend
    FROM sales
    GROUP BY customer_id
),
customer_tiers AS (
    SELECT 
        customer_id,
        order_frequency,
        total_spend,
        CASE 
            WHEN order_frequency >= 10 THEN 'Tier 1: 10+ Orders (Power Buyers)'
            WHEN order_frequency >= 6  THEN 'Tier 2: 6-9 Orders (Frequent)'
            WHEN order_frequency >= 3  THEN 'Tier 3: 3-5 Orders (Moderate)'
            ELSE 'Tier 4: 1-2 Orders (Occasional)'
        END AS frequency_tier
    FROM customer_order_counts
)
SELECT 
    frequency_tier,
    COUNT(customer_id)                      AS customer_count,
    ROUND(
        COUNT(customer_id) / SUM(COUNT(customer_id)) OVER () * 100, 
        2
    ) AS pct_of_customer_base,
    ROUND(SUM(total_spend), 2)              AS total_tier_revenue,
    ROUND(
        SUM(total_spend) / SUM(SUM(total_spend)) OVER () * 100, 
        2
    ) AS pct_of_total_revenue,
    ROUND(AVG(total_spend), 2)              AS avg_revenue_per_customer_in_tier
FROM customer_tiers
GROUP BY frequency_tier
ORDER BY total_tier_revenue DESC;

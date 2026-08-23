-- ==============================================================================
-- 11_WINDOW_FUNCTIONS.SQL
-- Project: E-Commerce Sales Analysis
-- Database Engine: MySQL 8.0+
-- Description: Comprehensive masterclass on SQL Window Functions demonstrating:
--              ROW_NUMBER(), RANK(), DENSE_RANK(), LAG(), LEAD(), and Cumulative
--              aggregations applied to real-world e-commerce business problems.
-- ==============================================================================

USE ecommerce_sales;

-- ==============================================================================
-- SECTION A: RANKING FUNCTIONS COMPARISON (ROW_NUMBER vs RANK vs DENSE_RANK)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. COMPARATIVE RANKING OF SUB-CATEGORIES
-- ------------------------------------------------------------------------------
-- Business Question: What is the exact behavioral difference between ROW_NUMBER(), RANK(), and DENSE_RANK()?
-- Explanation:
--   - ROW_NUMBER(): Assigns a unique sequential integer (1, 2, 3, 4...) regardless of ties.
--   - RANK(): Assigns identical rank for ties, but skips subsequent rank numbers (e.g., 1, 2, 2, 4).
--   - DENSE_RANK(): Assigns identical rank for ties without skipping rank numbers (e.g., 1, 2, 2, 3).

SELECT 
    sub_category,
    category,
    ROUND(SUM(sales), 2)                                  AS total_sales,
    ROW_NUMBER() OVER (ORDER BY SUM(sales) DESC)          AS row_num,
    RANK() OVER (ORDER BY SUM(sales) DESC)                AS standard_rank,
    DENSE_RANK() OVER (ORDER BY SUM(sales) DESC)          AS dense_rank
FROM sales
GROUP BY sub_category, category
ORDER BY total_sales DESC;

-- ------------------------------------------------------------------------------
-- 2. PARTITIONED RANKING: TOP PRODUCTS WITHIN EACH CATEGORY
-- ------------------------------------------------------------------------------
-- Business Question: How do we rank products within their respective categories using PARTITION BY?
-- Explanation: Demonstrates PARTITION BY category combined with DENSE_RANK() to restart rankings for each group.

WITH ranked_category_skus AS (
    SELECT 
        category,
        product_id,
        product_name,
        ROUND(SUM(sales), 2) AS product_sales,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY SUM(sales) DESC
        ) AS row_num_in_cat,
        DENSE_RANK() OVER (
            PARTITION BY category 
            ORDER BY SUM(sales) DESC
        ) AS dense_rank_in_cat
    FROM sales
    GROUP BY category, product_id, product_name
)
SELECT 
    category,
    dense_rank_in_cat,
    row_num_in_cat,
    product_id,
    product_name,
    product_sales
FROM ranked_category_skus
WHERE dense_rank_in_cat <= 5
ORDER BY category ASC, dense_rank_in_cat ASC;

-- ------------------------------------------------------------------------------
-- 3. CUSTOMER SPENDING LEADERBOARD RANKING
-- ------------------------------------------------------------------------------
-- Business Question: How do we rank all 793 customers by cumulative revenue, showing top percentiles?
-- Explanation: Uses DENSE_RANK() and NTILE(10) to group customers into 10 equal deciles.

SELECT 
    customer_id,
    customer_name,
    segment,
    ROUND(SUM(sales), 2)                         AS total_spend,
    DENSE_RANK() OVER (ORDER BY SUM(sales) DESC) AS customer_rank,
    NTILE(10) OVER (ORDER BY SUM(sales) DESC)    AS customer_decile -- 1 = Top 10% spenders
FROM sales
GROUP BY customer_id, customer_name, segment
ORDER BY customer_rank ASC
LIMIT 20;

-- ==============================================================================
-- SECTION B: VALUE NAVIGATION FUNCTIONS (LAG & LEAD)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 4. YEAR-OVER-YEAR (YoY) HISTORICAL COMPARISON (LAG)
-- ------------------------------------------------------------------------------
-- Business Question: How did each year's sales compare to the immediately preceding year?
-- Explanation: Uses LAG(sales, 1) to fetch prior-year revenue and compute YoY delta and % growth.

WITH yearly_sales_summary AS (
    SELECT 
        year,
        ROUND(SUM(sales), 2) AS current_year_sales
    FROM sales
    GROUP BY year
)
SELECT 
    year,
    current_year_sales,
    LAG(current_year_sales, 1) OVER (ORDER BY year ASC) AS previous_year_sales,
    ROUND(current_year_sales - LAG(current_year_sales, 1) OVER (ORDER BY year ASC), 2) AS yoy_sales_diff,
    ROUND(
        (current_year_sales - LAG(current_year_sales, 1) OVER (ORDER BY year ASC)) 
        / LAG(current_year_sales, 1) OVER (ORDER BY year ASC) * 100, 
        2
    ) AS yoy_growth_rate_pct
FROM yearly_sales_summary
ORDER BY year ASC;

-- ------------------------------------------------------------------------------
-- 5. MONTH-OVER-MONTH (MoM) HISTORICAL COMPARISON (LAG)
-- ------------------------------------------------------------------------------
-- Business Question: How does each month's sales compare to the prior month across all 48 operating months?
-- Explanation: Uses LAG() across chronological year_month to evaluate consecutive monthly performance.

WITH monthly_sales_data AS (
    SELECT 
        year_month,
        ROUND(SUM(sales), 2) AS monthly_sales
    FROM sales
    GROUP BY year_month
)
SELECT 
    year_month,
    monthly_sales,
    LAG(monthly_sales, 1) OVER (ORDER BY year_month ASC) AS previous_month_sales,
    ROUND(monthly_sales - LAG(monthly_sales, 1) OVER (ORDER BY year_month ASC), 2) AS mom_dollar_change,
    ROUND(
        (monthly_sales - LAG(monthly_sales, 1) OVER (ORDER BY year_month ASC)) 
        / LAG(monthly_sales, 1) OVER (ORDER BY year_month ASC) * 100, 
        2
    ) AS mom_growth_rate_pct
FROM monthly_sales_data
ORDER BY year_month ASC;

-- ------------------------------------------------------------------------------
-- 6. FORWARD TRAJECTORY & NEXT-MONTH COMPARISON (LEAD)
-- ------------------------------------------------------------------------------
-- Business Question: Looking forward from any given month, what was the revenue of the following month?
-- Explanation: Demonstrates LEAD(sales, 1) to look ahead into the next chronological period.

WITH monthly_sales_data AS (
    SELECT 
        year_month,
        ROUND(SUM(sales), 2) AS monthly_sales
    FROM sales
    GROUP BY year_month
)
SELECT 
    year_month,
    monthly_sales,
    LEAD(monthly_sales, 1) OVER (ORDER BY year_month ASC) AS next_month_sales,
    ROUND(LEAD(monthly_sales, 1) OVER (ORDER BY year_month ASC) - monthly_sales, 2) AS forward_month_difference
FROM monthly_sales_data
ORDER BY year_month ASC;

-- ==============================================================================
-- SECTION C: AGGREGATE WINDOW FUNCTIONS (RUNNING TOTALS & BENCHMARKS)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 7. RUNNING CUMULATIVE REVENUE TOTAL OVER TIME
-- ------------------------------------------------------------------------------
-- Business Question: What is the cumulative running total of sales revenue building up over time?
-- Explanation: Uses SUM(sales) OVER (ORDER BY year_month) to maintain a continuous cumulative balance.

WITH monthly_totals AS (
    SELECT 
        year_month,
        ROUND(SUM(sales), 2) AS monthly_sales
    FROM sales
    GROUP BY year_month
)
SELECT 
    year_month,
    monthly_sales,
    ROUND(
        SUM(monthly_sales) OVER (
            ORDER BY year_month ASC 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 
        2
    ) AS running_cumulative_sales
FROM monthly_totals
ORDER BY year_month ASC;

-- ------------------------------------------------------------------------------
-- 8. TRANSACTION VARIANCE FROM CATEGORY BENCHMARK (AVG OVER PARTITION)
-- ------------------------------------------------------------------------------
-- Business Question: For each transaction line item, how does its sale amount compare to the category average?
-- Explanation: Uses AVG(sales) OVER (PARTITION BY category) to compute deviation from category norms.

SELECT 
    row_id,
    order_id,
    category,
    sub_category,
    sales,
    ROUND(AVG(sales) OVER (PARTITION BY category), 2) AS category_avg_sales,
    ROUND(sales - AVG(sales) OVER (PARTITION BY category), 2) AS diff_from_category_avg
FROM sales
ORDER BY row_id ASC
LIMIT 20;

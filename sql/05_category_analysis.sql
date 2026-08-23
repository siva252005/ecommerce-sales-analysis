-- ==============================================================================
-- 05_CATEGORY_ANALYSIS.SQL
-- Project: E-Commerce Sales Analysis
-- Database Engine: MySQL 8.0+
-- Description: Product category and sub-category analytics, evaluating revenue
--              concentration, portfolio share %, top/bottom sub-categories,
--              within-category distribution, and category rankings.
-- ==============================================================================

USE ecommerce_sales;

-- ------------------------------------------------------------------------------
-- 1. SALES PERFORMANCE BY PRODUCT CATEGORY
-- ------------------------------------------------------------------------------
-- Business Question: What is the total sales revenue, order count, and average item value per category?
-- Explanation: Aggregates high-level performance across the 3 primary categories (Technology, Furniture, Office Supplies).

SELECT 
    category,
    COUNT(DISTINCT order_id)   AS total_orders,
    COUNT(row_id)              AS total_line_items,
    ROUND(SUM(sales), 2)       AS total_sales,
    ROUND(AVG(sales), 2)       AS avg_line_item_sales
FROM sales
GROUP BY category
ORDER BY total_sales DESC;

-- ------------------------------------------------------------------------------
-- 2. CATEGORY SALES PERCENTAGE (REVENUE SHARE)
-- ------------------------------------------------------------------------------
-- Business Question: What percentage of total business revenue is contributed by each category?
-- Explanation: Uses the window function SUM(SUM(sales)) OVER () to calculate category revenue share dynamically.

SELECT 
    category,
    ROUND(SUM(sales), 2) AS category_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
        2
    ) AS revenue_contribution_pct
FROM sales
GROUP BY category
ORDER BY category_sales DESC;

-- ------------------------------------------------------------------------------
-- 3. SALES PERFORMANCE BY SUB-CATEGORY
-- ------------------------------------------------------------------------------
-- Business Question: How does revenue break down across all 17 individual product sub-categories?
-- Explanation: Aggregates sales, unique products, and order counts at the sub-category level.

SELECT 
    category,
    sub_category,
    COUNT(DISTINCT product_id) AS unique_products_offered,
    COUNT(DISTINCT order_id)   AS total_orders,
    COUNT(row_id)              AS total_line_items,
    ROUND(SUM(sales), 2)       AS total_sales,
    ROUND(AVG(sales), 2)       AS avg_line_item_sales
FROM sales
GROUP BY category, sub_category
ORDER BY total_sales DESC;

-- ------------------------------------------------------------------------------
-- 4. TOP 5 SUB-CATEGORIES BY SALES
-- ------------------------------------------------------------------------------
-- Business Question: Which top 5 sub-categories generate the highest cumulative revenue?
-- Explanation: Ranks sub-categories in descending order of sales and limits to the top 5.

SELECT 
    sub_category,
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
        2
    ) AS pct_of_total_catalog_sales
FROM sales
GROUP BY sub_category, category
ORDER BY total_sales DESC
LIMIT 5;

-- ------------------------------------------------------------------------------
-- 5. BOTTOM 5 SUB-CATEGORIES BY SALES
-- ------------------------------------------------------------------------------
-- Business Question: Which 5 sub-categories have the lowest sales revenue?
-- Explanation: Ranks sub-categories in ascending order of sales to identify under-performing or niche lines.

SELECT 
    sub_category,
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
        2
    ) AS pct_of_total_catalog_sales
FROM sales
GROUP BY sub_category, category
ORDER BY total_sales ASC
LIMIT 5;

-- ------------------------------------------------------------------------------
-- 6. GLOBAL SUB-CATEGORY RANKING
-- ------------------------------------------------------------------------------
-- Business Question: What is the formal sales rank and dense rank of every sub-category in the catalog?
-- Explanation: Uses RANK() and DENSE_RANK() window functions across all 17 sub-categories.

SELECT 
    sub_category,
    category,
    ROUND(SUM(sales), 2)                                 AS total_sales,
    RANK() OVER (ORDER BY SUM(sales) DESC)               AS sales_rank,
    DENSE_RANK() OVER (ORDER BY SUM(sales) DESC)         AS sales_dense_rank
FROM sales
GROUP BY sub_category, category
ORDER BY sales_rank ASC;

-- ------------------------------------------------------------------------------
-- 7. SUB-CATEGORY CONTRIBUTION WITHIN PARENT CATEGORY
-- ------------------------------------------------------------------------------
-- Business Question: Within each parent category, what percentage of revenue does each sub-category generate?
-- Explanation: Uses SUM(SUM(sales)) OVER (PARTITION BY category) to compute within-category contribution share.

SELECT 
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS sub_category_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER (PARTITION BY category) * 100, 
        2
    ) AS pct_share_within_category,
    DENSE_RANK() OVER (
        PARTITION BY category 
        ORDER BY SUM(sales) DESC
    ) AS rank_within_category
FROM sales
GROUP BY category, sub_category
ORDER BY category ASC, sub_category_sales DESC;

-- ------------------------------------------------------------------------------
-- 8. CATEGORY PERFORMANCE MATRIX ACROSS CALENDAR YEARS
-- ------------------------------------------------------------------------------
-- Business Question: How has revenue for each category evolved year-over-year from 2015 to 2018?
-- Explanation: Aggregates category sales across years to evaluate growth consistency.

SELECT 
    category,
    ROUND(SUM(CASE WHEN year = 2015 THEN sales ELSE 0 END), 2) AS sales_2015,
    ROUND(SUM(CASE WHEN year = 2016 THEN sales ELSE 0 END), 2) AS sales_2016,
    ROUND(SUM(CASE WHEN year = 2017 THEN sales ELSE 0 END), 2) AS sales_2017,
    ROUND(SUM(CASE WHEN year = 2018 THEN sales ELSE 0 END), 2) AS sales_2018,
    ROUND(SUM(sales), 2)                                       AS total_category_sales
FROM sales
GROUP BY category
ORDER BY total_category_sales DESC;

-- ==============================================================================
-- 08_PRODUCT_ANALYSIS.SQL
-- Project: E-Commerce Sales Analysis
-- Database Engine: MySQL 8.0+
-- Description: Product-level performance analytics, identifying top/bottom grossing
--              SKUs, catalog-wide rankings, within-category bestsellers, and
--              cross-category merchandise matrices.
-- ==============================================================================

USE ecommerce_sales;

-- ------------------------------------------------------------------------------
-- 1. TOP 10 BEST-SELLING PRODUCTS BY TOTAL SALES
-- ------------------------------------------------------------------------------
-- Business Question: Which top 10 products generate the highest cumulative sales revenue?
-- Explanation: Aggregates sales at the product SKU level and lists the top 10 revenue drivers.

SELECT 
    product_id,
    product_name,
    category,
    sub_category,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(row_id)            AS total_units_sold_lines,
    ROUND(SUM(sales), 2)     AS total_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
        2
    ) AS pct_of_catalog_revenue
FROM sales
GROUP BY product_id, product_name, category, sub_category
ORDER BY total_sales DESC
LIMIT 10;

-- ------------------------------------------------------------------------------
-- 2. BOTTOM 10 PRODUCTS BY TOTAL SALES
-- ------------------------------------------------------------------------------
-- Business Question: Which 10 products have generated the lowest total sales revenue?
-- Explanation: Identifies low-velocity or long-tail products that may require inventory rationalization.

SELECT 
    product_id,
    product_name,
    category,
    sub_category,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2)     AS total_sales
FROM sales
GROUP BY product_id, product_name, category, sub_category
ORDER BY total_sales ASC
LIMIT 10;

-- ------------------------------------------------------------------------------
-- 3. GLOBAL PRODUCT RANKING ACROSS CATALOG (1,861 SKUs)
-- ------------------------------------------------------------------------------
-- Business Question: What is the formal sales rank for every product in the catalog?
-- Explanation: Uses DENSE_RANK() and PERCENT_RANK() to classify all products by revenue tier.

SELECT 
    product_id,
    product_name,
    category,
    sub_category,
    ROUND(SUM(sales), 2)                         AS total_sales,
    DENSE_RANK() OVER (ORDER BY SUM(sales) DESC) AS product_sales_rank,
    ROUND(
        PERCENT_RANK() OVER (ORDER BY SUM(sales) ASC) * 100, 
        2
    ) AS catalog_sales_percentile
FROM sales
GROUP BY product_id, product_name, category, sub_category
ORDER BY product_sales_rank ASC;

-- ------------------------------------------------------------------------------
-- 4. TOP 3 BEST-SELLING PRODUCTS WITHIN EACH CATEGORY
-- ------------------------------------------------------------------------------
-- Business Question: Which are the top 3 highest-grossing products within each major category?
-- Explanation: Uses DENSE_RANK() partitioned by category to isolate category leaders.

WITH category_product_ranks AS (
    SELECT 
        category,
        product_id,
        product_name,
        ROUND(SUM(sales), 2) AS product_sales,
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
    product_sales
FROM category_product_ranks
WHERE rank_in_category <= 3
ORDER BY category ASC, rank_in_category ASC;

-- ------------------------------------------------------------------------------
-- 5. TOP BEST-SELLING PRODUCT IN EACH SUB-CATEGORY
-- ------------------------------------------------------------------------------
-- Business Question: What is the single top-grossing flagship product in every sub-category?
-- Explanation: Uses ROW_NUMBER() partitioned by sub-category to extract the #1 SKU per sub-category.

WITH subcategory_product_ranks AS (
    SELECT 
        category,
        sub_category,
        product_id,
        product_name,
        ROUND(SUM(sales), 2) AS product_sales,
        ROW_NUMBER() OVER (
            PARTITION BY sub_category 
            ORDER BY SUM(sales) DESC
        ) AS rank_in_subcategory
    FROM sales
    GROUP BY category, sub_category, product_id, product_name
)
SELECT 
    category,
    sub_category,
    product_id,
    product_name,
    product_sales
FROM subcategory_product_ranks
WHERE rank_in_subcategory = 1
ORDER BY category ASC, product_sales DESC;

-- ------------------------------------------------------------------------------
-- 6. CATEGORY & SUB-CATEGORY PERFORMANCE SUMMARY MATRIX
-- ------------------------------------------------------------------------------
-- Business Question: What is the SKU breadth, total sales, and average sales per SKU across all sub-categories?
-- Explanation: Provides a comprehensive merchandising summary across the entire hierarchy.

SELECT 
    category,
    sub_category,
    COUNT(DISTINCT product_id)                      AS active_sku_count,
    COUNT(DISTINCT order_id)                        AS total_orders,
    ROUND(SUM(sales), 2)                            AS total_sales,
    ROUND(SUM(sales) / COUNT(DISTINCT product_id), 2) AS avg_sales_per_sku,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
        2
    ) AS pct_of_total_catalog_revenue
FROM sales
GROUP BY category, sub_category
ORDER BY category ASC, total_sales DESC;

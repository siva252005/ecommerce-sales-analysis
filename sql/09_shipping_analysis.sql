-- ==============================================================================
-- 09_SHIPPING_ANALYSIS.SQL
-- Project: E-Commerce Sales Analysis
-- Database Engine: MySQL 8.0+
-- Description: Logistics and shipping mode analysis evaluating volume share,
--              revenue contribution, average basket size, delivery duration,
--              and regional shipping preferences.
-- ==============================================================================

USE ecommerce_sales;

-- ------------------------------------------------------------------------------
-- 1. SALES PERFORMANCE BY SHIPPING MODE
-- ------------------------------------------------------------------------------
-- Business Question: What is the total sales revenue, order volume, and line-item count for each shipping mode?
-- Explanation: Aggregates logistics data across the 4 delivery options (Standard Class, Second Class, First Class, Same Day).

SELECT 
    ship_mode,
    COUNT(DISTINCT order_id)                        AS total_orders,
    COUNT(row_id)                                   AS total_line_items,
    ROUND(SUM(sales), 2)                            AS total_sales,
    ROUND(AVG(sales), 2)                            AS avg_sales_per_line_item,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM sales
GROUP BY ship_mode
ORDER BY total_sales DESC;

-- ------------------------------------------------------------------------------
-- 2. SHIPPING MODE VOLUME & REVENUE SHARE PERCENTAGES
-- ------------------------------------------------------------------------------
-- Business Question: What percentage of total orders and total revenue is represented by each shipping tier?
-- Explanation: Uses window functions to compare order share percentage vs. revenue share percentage.

SELECT 
    ship_mode,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        COUNT(DISTINCT order_id) / SUM(COUNT(DISTINCT order_id)) OVER () * 100, 
        2
    ) AS order_volume_pct,
    ROUND(SUM(sales), 2)     AS total_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
        2
    ) AS revenue_share_pct
FROM sales
GROUP BY ship_mode
ORDER BY total_sales DESC;

-- ------------------------------------------------------------------------------
-- 3. AVERAGE SHIPPING DURATION (FULFILLMENT SPEED)
-- ------------------------------------------------------------------------------
-- Business Question: What is the average and maximum shipping turnaround time (in days) for each shipping mode?
-- Explanation: Uses DATEDIFF(ship_date, order_date) to analyze fulfillment cycle time per tier.

SELECT 
    ship_mode,
    COUNT(DISTINCT order_id)                     AS total_orders,
    ROUND(AVG(DATEDIFF(ship_date, order_date)), 2) AS avg_shipping_days,
    MIN(DATEDIFF(ship_date, order_date))         AS min_shipping_days,
    MAX(DATEDIFF(ship_date, order_date))         AS max_shipping_days
FROM sales
GROUP BY ship_mode
ORDER BY avg_shipping_days ASC;

-- ------------------------------------------------------------------------------
-- 4. SHIPPING PREFERENCE BY CUSTOMER SEGMENT
-- ------------------------------------------------------------------------------
-- Business Question: Which shipping modes do Consumer, Corporate, and Home Office customers prefer most?
-- Explanation: Cross-tabulates customer segment with shipping mode order volumes and sales.

SELECT 
    segment,
    ship_mode,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2)     AS total_sales,
    ROUND(
        COUNT(DISTINCT order_id) / SUM(COUNT(DISTINCT order_id)) OVER (PARTITION BY segment) * 100, 
        2
    ) AS segment_order_share_pct
FROM sales
GROUP BY segment, ship_mode
ORDER BY segment ASC, total_orders DESC;

-- ------------------------------------------------------------------------------
-- 5. REGIONAL SHIPPING MODE UTILIZATION MATRIX
-- ------------------------------------------------------------------------------
-- Business Question: How does shipping mode adoption vary across the West, East, Central, and South regions?
-- Explanation: Assesses regional logistics distribution to identify potential regional fulfillment patterns.

SELECT 
    region,
    ship_mode,
    COUNT(DISTINCT order_id) AS order_count,
    ROUND(SUM(sales), 2)     AS region_mode_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER (PARTITION BY region) * 100, 
        2
    ) AS pct_of_regional_sales
FROM sales
GROUP BY region, ship_mode
ORDER BY region ASC, region_mode_sales DESC;

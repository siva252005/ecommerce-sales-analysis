-- ==============================================================================
-- 04_TIME_ANALYSIS.SQL
-- Project: E-Commerce Sales Analysis
-- Database Engine: MySQL 8.0+
-- Description: Temporal analytics evaluating annual growth, seasonality, monthly
--              chronological trends, Year-over-Year (YoY) and Month-over-Month (MoM)
--              growth rates, and peak/trough sales periods.
-- ==============================================================================

USE ecommerce_sales;

-- ------------------------------------------------------------------------------
-- 1. ANNUAL SALES PERFORMANCE & BREAKDOWN
-- ------------------------------------------------------------------------------
-- Business Question: What is the total sales revenue, order volume, and average order value for each year?
-- Explanation: Aggregates performance by calendar year to show broad trajectory from 2015 to 2018.

SELECT 
    year,
    COUNT(DISTINCT order_id)                        AS total_orders,
    COUNT(row_id)                                   AS total_line_items,
    ROUND(SUM(sales), 2)                            AS total_sales,
    ROUND(AVG(sales), 2)                            AS avg_line_item_sales,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM sales
GROUP BY year
ORDER BY year ASC;

-- ------------------------------------------------------------------------------
-- 2. YEAR-OVER-YEAR (YoY) SALES GROWTH RATE
-- ------------------------------------------------------------------------------
-- Business Question: How did sales grow year-over-year in absolute dollars and percentage terms?
-- Explanation: Uses a CTE and the LAG() window function to calculate YoY difference and % change.

WITH annual_sales AS (
    SELECT 
        year,
        ROUND(SUM(sales), 2) AS current_year_sales
    FROM sales
    GROUP BY year
)
SELECT 
    year,
    current_year_sales,
    LAG(current_year_sales, 1) OVER (ORDER BY year) AS prior_year_sales,
    ROUND(current_year_sales - LAG(current_year_sales, 1) OVER (ORDER BY year), 2) AS yoy_absolute_growth,
    ROUND(
        (current_year_sales - LAG(current_year_sales, 1) OVER (ORDER BY year)) 
        / LAG(current_year_sales, 1) OVER (ORDER BY year) * 100, 
        2
    ) AS yoy_growth_percentage
FROM annual_sales
ORDER BY year ASC;

-- ------------------------------------------------------------------------------
-- 3. MONTHLY SEASONALITY ANALYSIS (AGGREGATED ACROSS ALL YEARS)
-- ------------------------------------------------------------------------------
-- Business Question: Across all 4 years combined, which calendar months generate the highest sales?
-- Explanation: Identifies macro seasonal buying cycles by grouping across all 12 calendar months.

SELECT 
    month,
    month_name,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2)     AS total_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
        2
    ) AS percentage_of_total_revenue
FROM sales
GROUP BY month, month_name
ORDER BY month ASC;

-- ------------------------------------------------------------------------------
-- 4. 48-MONTH CHRONOLOGICAL SALES TREND & MoM GROWTH
-- ------------------------------------------------------------------------------
-- Business Question: What is the month-by-month sales trajectory across all 48 operating months,
--                    and how did each month perform compared to the previous month?
-- Explanation: Tracks full timeline and calculates Month-over-Month (MoM) growth using LAG().

WITH monthly_trend AS (
    SELECT 
        year,
        month,
        year_month,
        COUNT(DISTINCT order_id) AS order_count,
        ROUND(SUM(sales), 2)     AS monthly_sales
    FROM sales
    GROUP BY year, month, year_month
)
SELECT 
    year_month,
    year,
    month,
    order_count,
    monthly_sales,
    LAG(monthly_sales, 1) OVER (ORDER BY year_month) AS prior_month_sales,
    ROUND(monthly_sales - LAG(monthly_sales, 1) OVER (ORDER BY year_month), 2) AS mom_dollar_change,
    ROUND(
        (monthly_sales - LAG(monthly_sales, 1) OVER (ORDER BY year_month)) 
        / LAG(monthly_sales, 1) OVER (ORDER BY year_month) * 100, 
        2
    ) AS mom_growth_percentage
FROM monthly_trend
ORDER BY year_month ASC;

-- ------------------------------------------------------------------------------
-- 5. HIGHEST SALES YEAR (DYNAMIC IDENTIFICATION)
-- ------------------------------------------------------------------------------
-- Business Question: Which single calendar year generated the highest total revenue?
-- Explanation: Dynamically ranks years by sales and isolates the top performing year.

SELECT 
    year,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(DISTINCT order_id) AS total_orders,
    'Highest Sales Year' AS performance_label
FROM sales
GROUP BY year
ORDER BY total_sales DESC
LIMIT 1;

-- ------------------------------------------------------------------------------
-- 6. LOWEST SALES YEAR (DYNAMIC IDENTIFICATION)
-- ------------------------------------------------------------------------------
-- Business Question: Which single calendar year had the lowest total sales revenue?
-- Explanation: Dynamically finds the year with the minimum annual revenue.

SELECT 
    year,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(DISTINCT order_id) AS total_orders,
    'Lowest Sales Year' AS performance_label
FROM sales
GROUP BY year
ORDER BY total_sales ASC
LIMIT 1;

-- ------------------------------------------------------------------------------
-- 7. QUARTERLY SALES PERFORMANCE & SEASONAL SURGE
-- ------------------------------------------------------------------------------
-- Business Question: How do quarterly revenue and order volumes evolve across fiscal quarters (Q1-Q4)?
-- Explanation: Uses QUARTER(order_date) to analyze quarterly demand surges, particularly in Q4.

SELECT 
    year,
    CONCAT('Q', QUARTER(order_date)) AS fiscal_quarter,
    COUNT(DISTINCT order_id)         AS total_orders,
    ROUND(SUM(sales), 2)             AS quarterly_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER (PARTITION BY year) * 100, 
        2
    ) AS pct_of_annual_sales
FROM sales
GROUP BY year, QUARTER(order_date), CONCAT('Q', QUARTER(order_date))
ORDER BY year ASC, fiscal_quarter ASC;

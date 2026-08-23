-- ==============================================================================
-- 06_GEOGRAPHIC_ANALYSIS.SQL
-- Project: E-Commerce Sales Analysis
-- Database Engine: MySQL 8.0+
-- Description: Geographic sales analytics covering regional revenue distribution,
--              state-level performance rankings, top/bottom states, and top
--              cities/states partitioned within each territory.
-- ==============================================================================

USE ecommerce_sales;

-- ------------------------------------------------------------------------------
-- 1. SALES BY REGION & REVENUE SHARE
-- ------------------------------------------------------------------------------
-- Business Question: What is the sales volume, order count, and revenue share of each geographic region?
-- Explanation: Summarizes performance across the 4 major US operating regions (West, East, Central, South).

SELECT 
    region,
    COUNT(DISTINCT order_id)    AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales), 2)        AS total_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
        2
    ) AS revenue_contribution_pct,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM sales
GROUP BY region
ORDER BY total_sales DESC;

-- ------------------------------------------------------------------------------
-- 2. REGIONAL RANKING & METRIC BENCHMARKS
-- ------------------------------------------------------------------------------
-- Business Question: How do regions rank by total revenue and transaction volume?
-- Explanation: Uses RANK() and DENSE_RANK() window functions to establish regional standing.

SELECT 
    region,
    ROUND(SUM(sales), 2)                                 AS total_sales,
    COUNT(DISTINCT order_id)                             AS total_orders,
    DENSE_RANK() OVER (ORDER BY SUM(sales) DESC)         AS revenue_rank,
    DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT order_id) DESC) AS order_volume_rank
FROM sales
GROUP BY region
ORDER BY revenue_rank ASC;

-- ------------------------------------------------------------------------------
-- 3. STATE-LEVEL SALES BREAKDOWN (ALL 49 STATES)
-- ------------------------------------------------------------------------------
-- Business Question: How does revenue distribute across all states in the business footprint?
-- Explanation: Aggregates total sales, customer count, and order count for every state.

SELECT 
    state,
    region,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT order_id)    AS total_orders,
    ROUND(SUM(sales), 2)        AS total_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
        2
    ) AS pct_of_total_national_sales
FROM sales
GROUP BY state, region
ORDER BY total_sales DESC;

-- ------------------------------------------------------------------------------
-- 4. TOP 10 STATES BY SALES
-- ------------------------------------------------------------------------------
-- Business Question: Which top 10 states drive the largest share of national revenue?
-- Explanation: Identifies the 10 highest-grossing states using descending sales ranking.

SELECT 
    state,
    region,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2)     AS total_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
        2
    ) AS pct_of_national_sales
FROM sales
GROUP BY state, region
ORDER BY total_sales DESC
LIMIT 10;

-- ------------------------------------------------------------------------------
-- 5. BOTTOM 10 STATES BY SALES
-- ------------------------------------------------------------------------------
-- Business Question: Which 10 states contribute the lowest sales revenue?
-- Explanation: Isolates the bottom 10 states by sales volume to uncover under-penetrated markets.

SELECT 
    state,
    region,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2)     AS total_sales,
    ROUND(
        SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
        2
    ) AS pct_of_national_sales
FROM sales
GROUP BY state, region
ORDER BY total_sales ASC
LIMIT 10;

-- ------------------------------------------------------------------------------
-- 6. TOP PERFORMING STATE WITHIN EACH REGION
-- ------------------------------------------------------------------------------
-- Business Question: Which single state leads sales generation within each of the 4 regions?
-- Explanation: Uses ROW_NUMBER() partitioned by region to extract the #1 state for each territory.

WITH ranked_regional_states AS (
    SELECT 
        region,
        state,
        ROUND(SUM(sales), 2) AS state_sales,
        ROW_NUMBER() OVER (
            PARTITION BY region 
            ORDER BY SUM(sales) DESC
        ) AS state_rank_in_region
    FROM sales
    GROUP BY region, state
)
SELECT 
    region,
    state AS top_state,
    state_sales
FROM ranked_regional_states
WHERE state_rank_in_region = 1
ORDER BY state_sales DESC;

-- ------------------------------------------------------------------------------
-- 7. TOP 3 PERFORMING CITIES WITHIN EACH REGION
-- ------------------------------------------------------------------------------
-- Business Question: Which are the top 3 revenue-generating cities within each geographic region?
-- Explanation: Uses DENSE_RANK() partitioned by region to pinpoint critical metropolitan hubs.

WITH ranked_cities AS (
    SELECT 
        region,
        city,
        state,
        ROUND(SUM(sales), 2) AS city_sales,
        DENSE_RANK() OVER (
            PARTITION BY region 
            ORDER BY SUM(sales) DESC
        ) AS city_rank_in_region
    FROM sales
    GROUP BY region, city, state
)
SELECT 
    region,
    city_rank_in_region,
    city,
    state,
    city_sales
FROM ranked_cities
WHERE city_rank_in_region <= 3
ORDER BY region ASC, city_rank_in_region ASC;

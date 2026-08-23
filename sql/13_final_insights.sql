-- ==============================================================================
-- 13_FINAL_INSIGHTS.SQL
-- Project: E-Commerce Sales Analysis
-- Database Engine: MySQL 8.0+
-- Description: Dynamic executive insights engine synthesizing key business findings
--              directly from the dataset without hard-coded numbers. Identifies
--              strongest year, yearly growth, leading category, top sub-category,
--              lead region, top state, dominant segment, champion product, top customer,
--              and primary shipping channel.
-- ==============================================================================

USE ecommerce_sales;

-- ------------------------------------------------------------------------------
-- 1. STRONGEST SALES YEAR & HISTORICAL GROWTH TRAJECTORY
-- ------------------------------------------------------------------------------
-- Business Question: Which calendar year achieved peak sales, and what was its YoY growth rate?
-- Explanation: Uses window functions and dynamic ordering to pinpoint the highest-grossing year.

WITH yearly_performance AS (
    SELECT 
        year,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(SUM(sales), 2)     AS annual_sales,
        LAG(ROUND(SUM(sales), 2), 1) OVER (ORDER BY year ASC) AS prior_year_sales
    FROM sales
    GROUP BY year
)
SELECT 
    'Strongest Sales Year' AS insight_dimension,
    year                   AS top_dimension_value,
    annual_sales           AS metric_value,
    CONCAT(
        'Peak revenue year generating $', FORMAT(annual_sales, 2), 
        ' across ', FORMAT(total_orders, 0), ' orders with ', 
        ROUND((annual_sales - prior_year_sales) / prior_year_sales * 100, 2), 
        '% YoY growth.'
    ) AS strategic_finding
FROM yearly_performance
ORDER BY annual_sales DESC
LIMIT 1;

-- ------------------------------------------------------------------------------
-- 2. STRONGEST PRODUCT CATEGORY & REVENUE SHARE
-- ------------------------------------------------------------------------------
-- Business Question: Which product category contributes the highest revenue, and what is its portfolio share?
-- Explanation: Computes total category sales and percentage share across the catalog.

WITH category_summary AS (
    SELECT 
        category,
        ROUND(SUM(sales), 2) AS category_revenue,
        ROUND(
            SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
            2
        ) AS revenue_share_pct
    FROM sales
    GROUP BY category
)
SELECT 
    'Top Product Category' AS insight_dimension,
    category               AS top_dimension_value,
    category_revenue       AS metric_value,
    CONCAT(
        category, ' leads the portfolio with $', FORMAT(category_revenue, 2), 
        ' representing ', revenue_share_pct, '% of total gross sales.'
    ) AS strategic_finding
FROM category_summary
ORDER BY category_revenue DESC
LIMIT 1;

-- ------------------------------------------------------------------------------
-- 3. STRONGEST SUB-CATEGORY & CONTRIBUTION
-- ------------------------------------------------------------------------------
-- Business Question: Which specific sub-category generates the highest total sales volume?
-- Explanation: Identifies the top-grossing sub-category and its share of the total business.

WITH subcategory_summary AS (
    SELECT 
        sub_category,
        category,
        ROUND(SUM(sales), 2) AS subcategory_sales,
        ROUND(
            SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
            2
        ) AS revenue_share_pct
    FROM sales
    GROUP BY sub_category, category
)
SELECT 
    'Top Sub-Category' AS insight_dimension,
    sub_category       AS top_dimension_value,
    subcategory_sales  AS metric_value,
    CONCAT(
        sub_category, ' (', category, ') is the highest-grossing sub-category generating $', 
        FORMAT(subcategory_sales, 2), ' (', revenue_share_pct, '% of total company sales).'
    ) AS strategic_finding
FROM subcategory_summary
ORDER BY subcategory_sales DESC
LIMIT 1;

-- ------------------------------------------------------------------------------
-- 4. STRONGEST GEOGRAPHIC REGION
-- ------------------------------------------------------------------------------
-- Business Question: Which geographic region is the primary revenue engine for the business?
-- Explanation: Ranks the 4 operating regions by sales volume and calculates market share.

WITH regional_summary AS (
    SELECT 
        region,
        ROUND(SUM(sales), 2) AS regional_sales,
        ROUND(
            SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
            2
        ) AS revenue_share_pct,
        COUNT(DISTINCT order_id) AS total_orders
    FROM sales
    GROUP BY region
)
SELECT 
    'Top Geographic Region' AS insight_dimension,
    region                  AS top_dimension_value,
    regional_sales          AS metric_value,
    CONCAT(
        region, ' Region leads national sales at $', FORMAT(regional_sales, 2), 
        ' (', revenue_share_pct, '% revenue share across ', FORMAT(total_orders, 0), ' orders).'
    ) AS strategic_finding
FROM regional_summary
ORDER BY regional_sales DESC
LIMIT 1;

-- ------------------------------------------------------------------------------
-- 5. STRONGEST STATE
-- ------------------------------------------------------------------------------
-- Business Question: Which individual state generates the highest cumulative sales?
-- Explanation: Identifies the #1 state market across all 49 operating states.

WITH state_summary AS (
    SELECT 
        state,
        region,
        ROUND(SUM(sales), 2) AS state_sales,
        ROUND(
            SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
            2
        ) AS revenue_share_pct
    FROM sales
    GROUP BY state, region
)
SELECT 
    'Top State Market' AS insight_dimension,
    state              AS top_dimension_value,
    state_sales        AS metric_value,
    CONCAT(
        state, ' (', region, ') is the #1 state market generating $', 
        FORMAT(state_sales, 2), ' (', revenue_share_pct, '% of total revenue).'
    ) AS strategic_finding
FROM state_summary
ORDER BY state_sales DESC
LIMIT 1;

-- ------------------------------------------------------------------------------
-- 6. STRONGEST CUSTOMER SEGMENT
-- ------------------------------------------------------------------------------
-- Business Question: Which customer segment represents the largest proportion of total sales?
-- Explanation: Evaluates revenue and customer share across Consumer, Corporate, and Home Office.

WITH segment_summary AS (
    SELECT 
        segment,
        ROUND(SUM(sales), 2) AS segment_sales,
        ROUND(
            SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
            2
        ) AS revenue_share_pct,
        COUNT(DISTINCT customer_id) AS customer_count
    FROM sales
    GROUP BY segment
)
SELECT 
    'Top Customer Segment' AS insight_dimension,
    segment                AS top_dimension_value,
    segment_sales          AS metric_value,
    CONCAT(
        segment, ' segment drives $', FORMAT(segment_sales, 2), 
        ' (', revenue_share_pct, '% of sales) across ', FORMAT(customer_count, 0), ' customers.'
    ) AS strategic_finding
FROM segment_summary
ORDER BY segment_sales DESC
LIMIT 1;

-- ------------------------------------------------------------------------------
-- 7. TOP BEST-SELLING PRODUCT (CHAMPION SKU)
-- ------------------------------------------------------------------------------
-- Business Question: Which single product SKU generated the highest total revenue in catalog history?
-- Explanation: Dynamically isolates the #1 top-grossing product across all 1,861 SKUs.

WITH product_summary AS (
    SELECT 
        product_id,
        product_name,
        category,
        sub_category,
        ROUND(SUM(sales), 2) AS product_sales,
        ROUND(
            SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
            2
        ) AS revenue_share_pct
    FROM sales
    GROUP BY product_id, product_name, category, sub_category
)
SELECT 
    'Top Revenue Product SKU' AS insight_dimension,
    product_name              AS top_dimension_value,
    product_sales             AS metric_value,
    CONCAT(
        'SKU [', product_id, '] generated $', FORMAT(product_sales, 2), 
        ' (', category, ' - ', sub_category, '), representing ', revenue_share_pct, '% of catalog revenue.'
    ) AS strategic_finding
FROM product_summary
ORDER BY product_sales DESC
LIMIT 1;

-- ------------------------------------------------------------------------------
-- 8. TOP INDIVIDUAL CUSTOMER (HIGHEST LIFETIME SPEND)
-- ------------------------------------------------------------------------------
-- Business Question: Who is the #1 highest-spending individual customer?
-- Explanation: Identifies the customer account with the largest cumulative sales contribution.

WITH customer_summary AS (
    SELECT 
        customer_id,
        customer_name,
        segment,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(SUM(sales), 2)     AS total_spend,
        ROUND(
            SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
            2
        ) AS pct_of_company_revenue
    FROM sales
    GROUP BY customer_id, customer_name, segment
)
SELECT 
    'Top Lifetime Customer' AS insight_dimension,
    customer_name           AS top_dimension_value,
    total_spend             AS metric_value,
    CONCAT(
        customer_name, ' (ID: ', customer_id, ', ', segment, ') placed ', 
        total_orders, ' orders totaling $', FORMAT(total_spend, 2), 
        ' (', pct_of_company_revenue, '% of company revenue).'
    ) AS strategic_finding
FROM customer_summary
ORDER BY total_spend DESC
LIMIT 1;

-- ------------------------------------------------------------------------------
-- 9. DOMINANT SHIPPING MODE PERFORMANCE
-- ------------------------------------------------------------------------------
-- Business Question: Which shipping method handles the vast majority of customer orders?
-- Explanation: Evaluates order fulfillment distribution across all shipping tiers.

WITH shipping_summary AS (
    SELECT 
        ship_mode,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(
            COUNT(DISTINCT order_id) / SUM(COUNT(DISTINCT order_id)) OVER () * 100, 
            2
        ) AS order_share_pct,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(
            SUM(sales) / SUM(SUM(sales)) OVER () * 100, 
            2
        ) AS revenue_share_pct
    FROM sales
    GROUP BY ship_mode
)
SELECT 
    'Dominant Shipping Mode' AS insight_dimension,
    ship_mode                AS top_dimension_value,
    total_sales              AS metric_value,
    CONCAT(
        ship_mode, ' handles ', FORMAT(total_orders, 0), ' orders (', 
        order_share_pct, '% of order volume) generating $', FORMAT(total_sales, 2), 
        ' (', revenue_share_pct, '% of revenue).'
    ) AS strategic_finding
FROM shipping_summary
ORDER BY total_orders DESC
LIMIT 1;

-- ------------------------------------------------------------------------------
-- 10. CONSOLIDATED EXECUTIVE INSIGHTS SCORECARD (DYNAMIC TABLE)
-- ------------------------------------------------------------------------------
-- Business Question: Can all critical strategic findings be combined into a single unified summary report?
-- Explanation: Uses UNION ALL over dynamic metric CTEs to generate a comprehensive executive findings table.

WITH 
top_year AS (
    SELECT 'Strongest Year' AS kpi_name, CAST(year AS CHAR) AS leader_name, ROUND(SUM(sales), 2) AS revenue
    FROM sales GROUP BY year ORDER BY revenue DESC LIMIT 1
),
top_cat AS (
    SELECT 'Strongest Category' AS kpi_name, category AS leader_name, ROUND(SUM(sales), 2) AS revenue
    FROM sales GROUP BY category ORDER BY revenue DESC LIMIT 1
),
top_subcat AS (
    SELECT 'Strongest Sub-Category' AS kpi_name, sub_category AS leader_name, ROUND(SUM(sales), 2) AS revenue
    FROM sales GROUP BY sub_category ORDER BY revenue DESC LIMIT 1
),
top_reg AS (
    SELECT 'Strongest Region' AS kpi_name, region AS leader_name, ROUND(SUM(sales), 2) AS revenue
    FROM sales GROUP BY region ORDER BY revenue DESC LIMIT 1
),
top_st AS (
    SELECT 'Strongest State' AS kpi_name, state AS leader_name, ROUND(SUM(sales), 2) AS revenue
    FROM sales GROUP BY state ORDER BY revenue DESC LIMIT 1
),
top_seg AS (
    SELECT 'Strongest Customer Segment' AS kpi_name, segment AS leader_name, ROUND(SUM(sales), 2) AS revenue
    FROM sales GROUP BY segment ORDER BY revenue DESC LIMIT 1
),
top_prod AS (
    SELECT 'Top Revenue Product' AS kpi_name, product_name AS leader_name, ROUND(SUM(sales), 2) AS revenue
    FROM sales GROUP BY product_id, product_name ORDER BY revenue DESC LIMIT 1
),
top_cust AS (
    SELECT 'Top Revenue Customer' AS kpi_name, customer_name AS leader_name, ROUND(SUM(sales), 2) AS revenue
    FROM sales GROUP BY customer_id, customer_name ORDER BY revenue DESC LIMIT 1
),
top_ship AS (
    SELECT 'Dominant Shipping Mode' AS kpi_name, ship_mode AS leader_name, ROUND(SUM(sales), 2) AS revenue
    FROM sales GROUP BY ship_mode ORDER BY COUNT(DISTINCT order_id) DESC LIMIT 1
)
SELECT 
    kpi_name,
    leader_name,
    revenue AS total_sales_usd,
    ROUND(revenue / (SELECT SUM(sales) FROM sales) * 100, 2) AS pct_of_company_revenue
FROM (
    SELECT * FROM top_year
    UNION ALL SELECT * FROM top_cat
    UNION ALL SELECT * FROM top_subcat
    UNION ALL SELECT * FROM top_reg
    UNION ALL SELECT * FROM top_st
    UNION ALL SELECT * FROM top_seg
    UNION ALL SELECT * FROM top_prod
    UNION ALL SELECT * FROM top_cust
    UNION ALL SELECT * FROM top_ship
) AS consolidated_executive_insights;

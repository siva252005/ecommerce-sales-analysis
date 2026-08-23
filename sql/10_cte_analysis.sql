-- ==============================================================================
-- 10_CTE_ANALYSIS.SQL
-- Project: E-Commerce Sales Analysis
-- Database Engine: MySQL 8.0+
-- Description: Advanced analytical queries structured with Common Table Expressions (CTEs)
--              to perform multi-step business modeling: category benchmark comparisons,
--              multi-year trajectories, Pareto product concentration, customer value tiers,
--              and regional cross-tabulations.
-- ==============================================================================

USE ecommerce_sales;

-- ------------------------------------------------------------------------------
-- 1. CATEGORY CONTRIBUTION & BENCHMARK VARIANCE CTE
-- ------------------------------------------------------------------------------
-- Business Question: How does each sub-category perform relative to its parent category average
--                    and the company-wide average sub-category sales?
-- Explanation: Uses chained CTEs to calculate parent category baselines and compute variance from the mean.

WITH subcategory_metrics AS (
    SELECT 
        category,
        sub_category,
        COUNT(DISTINCT product_id) AS sku_count,
        COUNT(DISTINCT order_id)   AS order_count,
        ROUND(SUM(sales), 2)       AS total_sales
    FROM sales
    GROUP BY category, sub_category
),
category_benchmarks AS (
    SELECT 
        category,
        ROUND(AVG(total_sales), 2) AS avg_subcategory_sales_in_category
    FROM subcategory_metrics
    GROUP BY category
),
company_benchmark AS (
    SELECT 
        ROUND(AVG(total_sales), 2) AS overall_avg_subcategory_sales
    FROM subcategory_metrics
)
SELECT 
    sm.category,
    sm.sub_category,
    sm.sku_count,
    sm.order_count,
    sm.total_sales,
    cb.avg_subcategory_sales_in_category,
    ROUND(sm.total_sales - cb.avg_subcategory_sales_in_category, 2) AS variance_from_category_avg,
    comp.overall_avg_subcategory_sales,
    ROUND(sm.total_sales - comp.overall_avg_subcategory_sales, 2)   AS variance_from_company_avg
FROM subcategory_metrics sm
JOIN category_benchmarks cb ON sm.category = cb.category
CROSS JOIN company_benchmark comp
ORDER BY sm.category ASC, sm.total_sales DESC;

-- ------------------------------------------------------------------------------
-- 2. MULTI-YEAR COMPREHENSIVE PERFORMANCE TRACKER CTE
-- ------------------------------------------------------------------------------
-- Business Question: What is the consolidated multi-year performance scorecard tracking
--                    revenue, growth rate, customer acquisition/retention, order count, and AOV?
-- Explanation: Chains annual aggregations with lag calculations in a clean, reusable CTE pipeline.

WITH annual_aggregates AS (
    SELECT 
        year,
        COUNT(DISTINCT customer_id)                     AS active_customers,
        COUNT(DISTINCT order_id)                        AS total_orders,
        COUNT(row_id)                                   AS total_items,
        ROUND(SUM(sales), 2)                            AS total_revenue,
        ROUND(AVG(sales), 2)                            AS avg_item_price,
        ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
    FROM sales
    GROUP BY year
),
growth_calculations AS (
    SELECT 
        year,
        active_customers,
        total_orders,
        total_items,
        total_revenue,
        avg_item_price,
        avg_order_value,
        LAG(total_revenue, 1) OVER (ORDER BY year) AS prior_year_revenue,
        LAG(total_orders, 1) OVER (ORDER BY year)  AS prior_year_orders
    FROM annual_aggregates
)
SELECT 
    year,
    active_customers,
    total_orders,
    ROUND(
        (total_orders - prior_year_orders) / prior_year_orders * 100, 
        2
    ) AS order_growth_pct,
    total_revenue,
    prior_year_revenue,
    ROUND(total_revenue - prior_year_revenue, 2) AS revenue_growth_dollars,
    ROUND(
        (total_revenue - prior_year_revenue) / prior_year_revenue * 100, 
        2
    ) AS revenue_growth_pct,
    avg_order_value
FROM growth_calculations
ORDER BY year ASC;

-- ------------------------------------------------------------------------------
-- 3. PARETO 80/20 PRODUCT REVENUE CONCENTRATION CTE
-- ------------------------------------------------------------------------------
-- Business Question: Does the 80/20 Pareto principle apply to the product catalog,
--                    and what proportion of cumulative revenue is driven by top SKUs?
-- Explanation: Chains product-level ranking CTEs with running total window calculations.

WITH product_totals AS (
    SELECT 
        product_id,
        product_name,
        category,
        ROUND(SUM(sales), 2) AS total_product_sales
    FROM sales
    GROUP BY product_id, product_name, category
),
product_cumulative AS (
    SELECT 
        product_id,
        product_name,
        category,
        total_product_sales,
        ROW_NUMBER() OVER (ORDER BY total_product_sales DESC) AS product_rank,
        COUNT(*) OVER () AS total_catalog_skus,
        SUM(total_product_sales) OVER (ORDER BY total_product_sales DESC) AS running_cumulative_sales,
        SUM(total_product_sales) OVER () AS grand_total_catalog_sales
    FROM product_totals
),
pareto_metrics AS (
    SELECT 
        product_id,
        product_name,
        category,
        product_rank,
        total_product_sales,
        running_cumulative_sales,
        ROUND(product_rank / total_catalog_skus * 100, 2) AS catalog_percentile,
        ROUND(running_cumulative_sales / grand_total_catalog_sales * 100, 2) AS cumulative_revenue_pct
    FROM product_cumulative
)
SELECT 
    product_rank,
    product_name,
    category,
    total_product_sales,
    running_cumulative_sales,
    catalog_percentile,
    cumulative_revenue_pct,
    CASE 
        WHEN cumulative_revenue_pct <= 50 THEN 'Top 50% Revenue Contributor'
        WHEN cumulative_revenue_pct <= 80 THEN '50-80% Revenue Contributor'
        ELSE 'Long-Tail (Remaining 20%)'
    END AS pareto_tier
FROM pareto_metrics
WHERE product_rank <= 25 OR product_rank % 200 = 0
ORDER BY product_rank ASC;

-- ------------------------------------------------------------------------------
-- 4. CUSTOMER VALUE TIER SEGMENTATION CTE (HIGH, MID, LOW TIERS)
-- ------------------------------------------------------------------------------
-- Business Question: How are customers segmented by lifetime spend tiers, and what is each tier's revenue share?
-- Explanation: Classifies 793 customers into High-Value (>$5,000), Mid-Value ($2,000-$5,000),
--              and Low-Value (<$2,000) cohorts via CTE aggregation.

WITH customer_summary AS (
    SELECT 
        customer_id,
        customer_name,
        segment,
        COUNT(DISTINCT order_id) AS order_count,
        ROUND(SUM(sales), 2)     AS total_spend
    FROM sales
    GROUP BY customer_id, customer_name, segment
),
customer_tier_assignment AS (
    SELECT 
        customer_id,
        customer_name,
        segment,
        order_count,
        total_spend,
        CASE 
            WHEN total_spend >= 5000 THEN '1. Platinum Tier ($5,000+)'
            WHEN total_spend >= 2000 THEN '2. Gold Tier ($2,000 - $4,999)'
            WHEN total_spend >= 1000 THEN '3. Silver Tier ($1,000 - $1,999)'
            ELSE '4. Bronze Tier (< $1,000)'
        END AS customer_value_tier
    FROM customer_summary
)
SELECT 
    customer_value_tier,
    COUNT(customer_id)                      AS total_customers,
    ROUND(
        COUNT(customer_id) / SUM(COUNT(customer_id)) OVER () * 100, 
        2
    ) AS pct_of_customer_base,
    ROUND(SUM(total_spend), 2)              AS total_tier_sales,
    ROUND(
        SUM(total_spend) / SUM(SUM(total_spend)) OVER () * 100, 
        2
    ) AS pct_of_total_company_sales,
    ROUND(AVG(total_spend), 2)              AS avg_spend_per_customer_in_tier,
    ROUND(AVG(order_count), 2)              AS avg_orders_per_customer_in_tier
FROM customer_tier_assignment
GROUP BY customer_value_tier
ORDER BY customer_value_tier ASC;

-- ------------------------------------------------------------------------------
-- 5. REGIONAL CATEGORY PERFORMANCE PIVOT CTE
-- ------------------------------------------------------------------------------
-- Business Question: How does revenue for each product category break down across all 4 geographic regions?
-- Explanation: Constructs a cross-tabulated regional matrix using CTEs and conditional aggregations.

WITH regional_category_sales AS (
    SELECT 
        region,
        category,
        ROUND(SUM(sales), 2) AS category_sales
    FROM sales
    GROUP BY region, category
)
SELECT 
    region,
    MAX(CASE WHEN category = 'Technology' THEN category_sales ELSE 0 END)      AS technology_sales,
    MAX(CASE WHEN category = 'Furniture' THEN category_sales ELSE 0 END)       AS furniture_sales,
    MAX(CASE WHEN category = 'Office Supplies' THEN category_sales ELSE 0 END) AS office_supplies_sales,
    SUM(category_sales)                                                        AS total_region_sales
FROM regional_category_sales
GROUP BY region
ORDER BY total_region_sales DESC;

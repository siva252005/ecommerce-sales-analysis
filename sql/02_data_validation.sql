-- ==============================================================================
-- 02_DATA_VALIDATION.SQL
-- Project: E-Commerce Sales Analysis
-- Database Engine: MySQL 8.0+
-- Description: Comprehensive data quality and sanity checks verifying row count,
--              key integrity, missing values, distinct entity counts, date ranges,
--              and statistical distribution.
-- ==============================================================================

USE ecommerce_sales;

-- ------------------------------------------------------------------------------
-- 1. TOTAL ROW COUNT CHECK
-- ------------------------------------------------------------------------------
-- Business Question: Does the imported table contain the exact expected 9,800 records?
-- Explanation: Verifies that no records were dropped or truncated during the ETL load.

SELECT 
    COUNT(*) AS total_rows,
    CASE 
        WHEN COUNT(*) = 9800 THEN 'PASSED: Total row count matches expected 9,800'
        ELSE 'FAILED: Row count mismatch'
    END AS validation_status
FROM sales;

-- ------------------------------------------------------------------------------
-- 2. DUPLICATE PRIMARY KEY & RECORD CHECK
-- ------------------------------------------------------------------------------
-- Business Question: Are there any duplicate row IDs or redundant identical transactions?
-- Explanation: Checks for primary key uniqueness and flags any duplicate order line items.

-- Check 2A: Row ID uniqueness (Primary Key)
SELECT 
    row_id, 
    COUNT(*) AS occurrence_count
FROM sales
GROUP BY row_id
HAVING COUNT(*) > 1;

-- Check 2B: Line-item duplicate check (Same order, same customer, same product, same date)
SELECT 
    order_id,
    customer_id,
    product_id,
    order_date,
    COUNT(*) AS duplicate_line_count
FROM sales
GROUP BY order_id, customer_id, product_id, order_date
HAVING COUNT(*) > 1;

-- ------------------------------------------------------------------------------
-- 3. MISSING & NULL VALUES AUDIT
-- ------------------------------------------------------------------------------
-- Business Question: Which columns contain NULL or empty values, and do they align with data expectations?
-- Explanation: Audits all 22 columns. Postal Code is expected to contain 11 missing records,
-- while all business-critical fields (Order ID, Dates, Sales, Customer, Product) must have 0 NULLs.

SELECT 
    SUM(CASE WHEN row_id IS NULL THEN 1 ELSE 0 END)        AS null_row_ids,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END)      AS null_order_ids,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END)    AS null_order_dates,
    SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END)     AS null_ship_dates,
    SUM(CASE WHEN ship_mode IS NULL THEN 1 ELSE 0 END)     AS null_ship_modes,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END)   AS null_customer_ids,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS null_customer_names,
    SUM(CASE WHEN segment IS NULL THEN 1 ELSE 0 END)       AS null_segments,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END)       AS null_countries,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END)          AS null_cities,
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END)         AS null_states,
    SUM(CASE WHEN postal_code IS NULL THEN 1 ELSE 0 END)   AS null_postal_codes,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END)        AS null_regions,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END)    AS null_product_ids,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END)      AS null_categories,
    SUM(CASE WHEN sub_category IS NULL THEN 1 ELSE 0 END)  AS null_sub_categories,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END)  AS null_product_names,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END)         AS null_sales,
    SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END)          AS null_years,
    SUM(CASE WHEN month IS NULL THEN 1 ELSE 0 END)         AS null_months,
    SUM(CASE WHEN month_name IS NULL THEN 1 ELSE 0 END)    AS null_month_names,
    SUM(CASE WHEN year_month IS NULL THEN 1 ELSE 0 END)    AS null_year_months
FROM sales;

-- ------------------------------------------------------------------------------
-- 4. DISTINCT ENTITY COUNTS
-- ------------------------------------------------------------------------------
-- Business Question: What are the unique counts of orders, customers, products, categories, states, and cities?
-- Explanation: Establishes high-level cardinality benchmarks for the dataset.

SELECT 
    COUNT(DISTINCT order_id)     AS unique_orders,      -- Expected: 4,922
    COUNT(DISTINCT customer_id)  AS unique_customers,   -- Expected: 793
    COUNT(DISTINCT product_id)   AS unique_products,    -- Expected: 1,861
    COUNT(DISTINCT category)     AS unique_categories,  -- Expected: 3
    COUNT(DISTINCT sub_category) AS unique_sub_categories, -- Expected: 17
    COUNT(DISTINCT region)       AS unique_regions,     -- Expected: 4
    COUNT(DISTINCT state)        AS unique_states,      -- Expected: 49
    COUNT(DISTINCT city)         AS unique_cities       -- Expected: 529
FROM sales;

-- ------------------------------------------------------------------------------
-- 5. DATE RANGE & TEMPORAL INTEGRITY CHECK
-- ------------------------------------------------------------------------------
-- Business Question: What is the operating date range of the dataset, and are there invalid shipping dates?
-- Explanation: Checks minimum and maximum dates, and asserts that ship_date is always on or after order_date.

SELECT 
    MIN(order_date) AS min_order_date,
    MAX(order_date) AS max_order_date,
    MIN(ship_date)  AS min_ship_date,
    MAX(ship_date)  AS max_ship_date,
    DATEDIFF(MAX(order_date), MIN(order_date)) AS total_operating_days,
    SUM(CASE WHEN ship_date < order_date THEN 1 ELSE 0 END) AS invalid_shipping_dates
FROM sales;

-- ------------------------------------------------------------------------------
-- 6. SALES DISTRIBUTION & NUMERICAL SANITY
-- ------------------------------------------------------------------------------
-- Business Question: What are the summary statistics of the sales column, and are there negative/zero values?
-- Explanation: Computes minimum, maximum, average, standard deviation, and total sales across the dataset.

SELECT 
    MIN(sales)                       AS min_sales,
    MAX(sales)                       AS max_sales,
    ROUND(AVG(sales), 2)             AS avg_sales,
    ROUND(STDDEV(sales), 2)          AS stddev_sales,
    ROUND(SUM(sales), 2)             AS total_sales,
    SUM(CASE WHEN sales <= 0 THEN 1 ELSE 0 END) AS non_positive_sales_count
FROM sales;

-- ------------------------------------------------------------------------------
-- 7. CALENDAR ATTRIBUTE CONSISTENCY CHECK
-- ------------------------------------------------------------------------------
-- Business Question: Do the year, month, month_name, and year_month columns match order_date correctly?
-- Explanation: Validates date feature engineering against raw SQL date functions.

SELECT 
    SUM(CASE WHEN year != YEAR(order_date) THEN 1 ELSE 0 END)           AS invalid_years,
    SUM(CASE WHEN month != MONTH(order_date) THEN 1 ELSE 0 END)         AS invalid_months,
    SUM(CASE WHEN month_name != MONTHNAME(order_date) THEN 1 ELSE 0 END) AS invalid_month_names,
    SUM(CASE WHEN year_month != DATE_FORMAT(order_date, '%Y-%m') THEN 1 ELSE 0 END) AS invalid_year_months
FROM sales;

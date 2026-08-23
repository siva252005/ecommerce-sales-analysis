-- ==============================================================================
-- 03_BUSINESS_KPIS.SQL
-- Project: E-Commerce Sales Analysis
-- Database Engine: MySQL 8.0+
-- Description: Core executive business metrics and Key Performance Indicators (KPIs)
--              including Total Revenue, Order Counts, Customer Counts, Product Breadth,
--              Average Order Value (AOV), and Revenue per Customer.
-- ==============================================================================

USE ecommerce_sales;

-- ------------------------------------------------------------------------------
-- 1. TOTAL SALES (REVENUE)
-- ------------------------------------------------------------------------------
-- Business Question: What is the total cumulative revenue generated across all historical orders?
-- Explanation: Sums the sales column across all 9,800 order line items.

SELECT 
    ROUND(SUM(sales), 2) AS total_revenue
FROM sales;

-- ------------------------------------------------------------------------------
-- 2. TOTAL UNIQUE ORDERS
-- ------------------------------------------------------------------------------
-- Business Question: How many distinct orders have been placed in total?
-- Explanation: Uses COUNT(DISTINCT order_id) because single orders frequently contain multiple product line items.

SELECT 
    COUNT(DISTINCT order_id) AS total_orders
FROM sales;

-- ------------------------------------------------------------------------------
-- 3. TOTAL UNIQUE CUSTOMERS
-- ------------------------------------------------------------------------------
-- Business Question: How many unique individual customers have made purchases?
-- Explanation: Counts distinct customer IDs across the entire sales history.

SELECT 
    COUNT(DISTINCT customer_id) AS total_unique_customers
FROM sales;

-- ------------------------------------------------------------------------------
-- 4. TOTAL UNIQUE PRODUCTS
-- ------------------------------------------------------------------------------
-- Business Question: How many unique products are in the company's active sales catalog?
-- Explanation: Counts distinct product IDs sold across all categories.

SELECT 
    COUNT(DISTINCT product_id) AS total_unique_products
FROM sales;

-- ------------------------------------------------------------------------------
-- 5. AVERAGE SALES PER LINE ITEM
-- ------------------------------------------------------------------------------
-- Business Question: What is the average sales amount per individual line-item transaction?
-- Explanation: Calculates arithmetic mean of the sales column.

SELECT 
    ROUND(AVG(sales), 2) AS avg_sales_per_line_item
FROM sales;

-- ------------------------------------------------------------------------------
-- 6. AVERAGE ORDER VALUE (AOV)
-- ------------------------------------------------------------------------------
-- Business Question: What is the Average Order Value (AOV) generated per customer order?
-- Explanation: Divides total cumulative revenue by the count of distinct orders.

SELECT 
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM sales;

-- ------------------------------------------------------------------------------
-- 7. AVERAGE ITEMS PER ORDER (BASKET SIZE)
-- ------------------------------------------------------------------------------
-- Business Question: What is the average number of product line items included per order?
-- Explanation: Computes total line-item rows divided by distinct order IDs.

SELECT 
    ROUND(COUNT(row_id) / COUNT(DISTINCT order_id), 2) AS avg_items_per_order
FROM sales;

-- ------------------------------------------------------------------------------
-- 8. AVERAGE REVENUE PER CUSTOMER (ARPC)
-- ------------------------------------------------------------------------------
-- Business Question: What is the average lifetime gross revenue generated per unique customer?
-- Explanation: Divides total sales by total distinct customer count.

SELECT 
    ROUND(SUM(sales) / COUNT(DISTINCT customer_id), 2) AS avg_revenue_per_customer
FROM sales;

-- ------------------------------------------------------------------------------
-- 9. EXECUTIVE KPI SUMMARY CARD
-- ------------------------------------------------------------------------------
-- Business Question: Can we view all high-level business health metrics in a single consolidated executive view?
-- Explanation: Combines all foundational KPIs into a unified single-row scorecard for executive reporting.

SELECT 
    ROUND(SUM(sales), 2)                             AS total_revenue,
    COUNT(DISTINCT order_id)                         AS total_orders,
    COUNT(DISTINCT customer_id)                      AS total_customers,
    COUNT(DISTINCT product_id)                       AS total_products,
    COUNT(row_id)                                    AS total_line_items,
    ROUND(AVG(sales), 2)                             AS avg_line_item_sales,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2)  AS average_order_value,
    ROUND(COUNT(row_id) / COUNT(DISTINCT order_id), 2) AS avg_items_per_order,
    ROUND(SUM(sales) / COUNT(DISTINCT customer_id), 2) AS avg_revenue_per_customer
FROM sales;

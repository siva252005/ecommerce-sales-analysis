-- ==============================================================================
-- 01_DATABASE_SETUP.SQL
-- Project: E-Commerce Sales Analysis
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. DATABASE CREATION
-- ------------------------------------------------------------------------------
-- Purpose: Initialize a clean, dedicated database instance for the analytics project.

CREATE DATABASE IF NOT EXISTS ecommerce_sales;
USE ecommerce_sales;

-- ------------------------------------------------------------------------------
-- 2. TABLE SCHEMA DEFINITION
-- ------------------------------------------------------------------------------
-- Purpose: Create the 'sales' table with appropriate data types for all 22 columns.
-- Notes:
--   - 'sales' is stored as DECIMAL(10, 4) to ensure floating-point precision.
--   - 'postal_code' allows NULL values for records where postal code is missing.
--   - Indexes are created on key analytical dimensions to optimize query performance.

DROP TABLE IF EXISTS sales;

CREATE TABLE sales (
    row_id          INT PRIMARY KEY,
    order_id        VARCHAR(25)     NOT NULL,
    order_date      DATE            NOT NULL,
    ship_date       DATE            NOT NULL,
    ship_mode       VARCHAR(25)     NOT NULL,
    customer_id     VARCHAR(25)     NOT NULL,
    customer_name   VARCHAR(100)    NOT NULL,
    segment         VARCHAR(25)     NOT NULL,
    country         VARCHAR(50)     NOT NULL,
    city            VARCHAR(50)     NOT NULL,
    state           VARCHAR(50)     NOT NULL,
    postal_code     VARCHAR(20)     NULL,
    region          VARCHAR(25)     NOT NULL,
    product_id      VARCHAR(25)     NOT NULL,
    category        VARCHAR(50)     NOT NULL,
    sub_category    VARCHAR(50)     NOT NULL,
    product_name    VARCHAR(255)    NOT NULL,
    sales           DECIMAL(10, 4)  NOT NULL,
    year            INT             NOT NULL,
    month           INT             NOT NULL,
    month_name      VARCHAR(20)     NOT NULL,
    year_month      VARCHAR(10)     NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------------------------
-- 3. PERFORMANCE INDEXES
-- ------------------------------------------------------------------------------
-- Purpose: Accelerate filtering, joins, aggregations, and window function partitioning.

CREATE INDEX idx_sales_order_date   ON sales(order_date);
CREATE INDEX idx_sales_customer_id  ON sales(customer_id);
CREATE INDEX idx_sales_product_id   ON sales(product_id);
CREATE INDEX idx_sales_category     ON sales(category, sub_category);
CREATE INDEX idx_sales_region_state ON sales(region, state);
CREATE INDEX idx_sales_segment      ON sales(segment);
CREATE INDEX idx_sales_year_month   ON sales(year_month);

-- ------------------------------------------------------------------------------
-- 4. DATA INGESTION (LOAD DATA LOCAL INFILE)
-- ------------------------------------------------------------------------------
-- Purpose: Bulk-load the cleaned dataset (sales_cleaned.csv) directly into MySQL.
--
-- PREREQUISITE CLIENT/SERVER CONFIGURATION:
-- In MySQL 8.0+, LOAD DATA LOCAL INFILE is disabled by default for security.
-- Follow these steps to enable it before running the query below:
--
-- 1. Server Configuration:
--    Execute: SET GLOBAL local_infile = 1;
--    (Or add 'local_infile=1' under [mysqld] in your my.ini / my.cnf configuration file).
--
-- 2. Client Connection Configuration:
--    - MySQL CLI: Connect with `mysql --local-infile=1 -u root -p`
--    - MySQL Workbench: Edit Connection -> Advanced -> Others -> Add: OPT_LOCAL_INFILE=1
--    - Python/DBeaver: Enable 'allowLoadLocalInfile=true' in driver connection properties.
--
-- 3. Path Adjustment:
--    Replace '/path/to/ecommerce-sales-analysis/data/sales_cleaned.csv' with your absolute path.
--    Use forward slashes ('/') in paths even on Windows systems (e.g., 'C:/ecommerce-sales-analysis/data/sales_cleaned.csv').

/*
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/ecommerce-sales-analysis/data/sales_cleaned.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
    row_id,
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    @v_postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    sales,
    year,
    month,
    month_name,
    year_month
)
SET postal_code = NULLIF(TRIM(@v_postal_code), '');
*/

-- ------------------------------------------------------------------------------
-- 5. ALTERNATIVE IMPORT METHODS
-- ------------------------------------------------------------------------------
-- Method A: MySQL Workbench Table Data Import Wizard
--   1. Right-click 'sales' table under `ecommerce_sales` schema in MySQL Workbench.
--   2. Select 'Table Data Import Wizard'.
--   3. Browse and select `data/sales_cleaned.csv`.
--   4. Verify column data type mappings match the table definition and complete import.
--
-- Method B: Standard LOAD DATA INFILE (Server-Side)
--   Place `sales_cleaned.csv` in MySQL's secure directory (check with `SHOW VARIABLES LIKE 'secure_file_priv';`):
--
--   LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_cleaned.csv'
--   INTO TABLE sales
--   FIELDS TERMINATED BY ','
--   OPTIONALLY ENCLOSED BY '"'
--   LINES TERMINATED BY '\r\n'
--   IGNORE 1 LINES
--   (row_id, order_id, order_date, ship_date, ship_mode, customer_id, customer_name,
--    segment, country, city, state, @v_postal_code, region, product_id, category,
--    sub_category, product_name, sales, year, month, month_name, year_month)
--   SET postal_code = NULLIF(TRIM(@v_postal_code), '');

-- ------------------------------------------------------------------------------
-- 6. QUICK INGESTION VERIFICATION
-- ------------------------------------------------------------------------------
-- Confirm table was populated with expected 9,800 rows:
SELECT COUNT(*) AS total_imported_rows FROM sales;

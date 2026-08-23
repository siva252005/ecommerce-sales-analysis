# 📊 Phase 4: SQL Analytics — E-Commerce Sales Analysis

Welcome to the **SQL Analytics Engine** for the E-Commerce Sales Analysis portfolio project. This module contains 13 modular, production-ready MySQL scripts that perform comprehensive data validation, key metric extraction, temporal modeling, merchandise performance tracking, customer segmentation, and executive insight generation.

---

## 🏗️ Architecture & Database Setup

### 1. Database & Table Schema
The analytics suite runs on **MySQL 8.0+** using the `ecommerce_sales` database and a single normalized analytical table `sales`.

```sql
CREATE DATABASE IF NOT EXISTS ecommerce_sales;
USE ecommerce_sales;
```

### 2. Data Dictionary (22 Columns)

| Column Name | MySQL Data Type | Constraint / Nullability | Description |
| :--- | :--- | :--- | :--- |
| `row_id` | `INT` | `PRIMARY KEY` | Unique identifier for each line item transaction (1 to 9,800) |
| `order_id` | `VARCHAR(25)` | `NOT NULL` | Alphanumeric transaction order identifier (4,922 unique orders) |
| `order_date` | `DATE` | `NOT NULL` | Date when customer placed the order (2015-01-03 to 2018-12-30) |
| `ship_date` | `DATE` | `NOT NULL` | Date when order was dispatched / shipped |
| `ship_mode` | `VARCHAR(25)` | `NOT NULL` | Fulfillment speed class (`Standard Class`, `Second Class`, `First Class`, `Same Day`) |
| `customer_id` | `VARCHAR(25)` | `NOT NULL` | Unique customer alphanumeric code (793 distinct customers) |
| `customer_name` | `VARCHAR(100)` | `NOT NULL` | Full legal name of customer |
| `segment` | `VARCHAR(25)` | `NOT NULL` | Market customer segment (`Consumer`, `Corporate`, `Home Office`) |
| `country` | `VARCHAR(50)` | `NOT NULL` | Country of sale (`United States`) |
| `city` | `VARCHAR(50)` | `NOT NULL` | City where order was delivered (529 unique cities) |
| `state` | `VARCHAR(50)` | `NOT NULL` | State of delivery (49 US states) |
| `postal_code` | `VARCHAR(20)` | `NULL` | Delivery postal code (contains 11 non-imputed NULL values) |
| `region` | `VARCHAR(25)` | `NOT NULL` | US geographic territory (`West`, `East`, `Central`, `South`) |
| `product_id` | `VARCHAR(25)` | `NOT NULL` | Unique product SKU identifier (1,861 unique products) |
| `category` | `VARCHAR(50)` | `NOT NULL` | Top-level merchandise category (`Technology`, `Furniture`, `Office Supplies`) |
| `sub_category` | `VARCHAR(50)` | `NOT NULL` | Detailed product classification (17 sub-categories) |
| `product_name` | `VARCHAR(255)` | `NOT NULL` | Full descriptive item title |
| `sales` | `DECIMAL(10, 4)` | `NOT NULL` | Transaction gross revenue amount in USD ($0.44 to $22,638.48) |
| `year` | `INT` | `NOT NULL` | Extracted calendar order year (`2015`, `2016`, `2017`, `2018`) |
| `month` | `INT` | `NOT NULL` | Calendar month integer (`1` to `12`) |
| `month_name` | `VARCHAR(20)` | `NOT NULL` | Full calendar month string (`January` to `December`) |
| `year_month` | `VARCHAR(10)` | `NOT NULL` | Formatted chronological period string (`YYYY-MM`) |

### 3. Performance Indexing Strategy
To optimize filtering, multi-tier window function partitions, and grouping operations across the dataset:
- `idx_sales_order_date` (`order_date`): Accelerates temporal filtering and date-range slicing.
- `idx_sales_customer_id` (`customer_id`): Speeds up customer-level aggregations and RFM segmentation.
- `idx_sales_product_id` (`product_id`): Accelerates SKU lookups and catalog ranking.
- `idx_sales_category` (`category`, `sub_category`): Composite index for hierarchical merchandise queries.
- `idx_sales_region_state` (`region`, `state`): Composite index for geographic rollups.
- `idx_sales_segment` (`segment`): Optimizes market segment aggregations.
- `idx_sales_year_month` (`year_month`): Accelerates chronological MoM and YoY trend queries.

---

## 🚀 Step-by-Step Data Ingestion Guide

### Method 1: MySQL CLI (`LOAD DATA LOCAL INFILE`)
1. **Enable Local Infile on Server**:
   ```sql
   SET GLOBAL local_infile = 1;
   ```
2. **Connect to MySQL with Local Infile Enabled**:
   ```bash
   mysql --local-infile=1 -u root -p
   ```
3. **Execute Ingestion Script**:
   ```sql
   USE ecommerce_sales;
   
   LOAD DATA LOCAL INFILE 'C:/ecommerce-sales-analysis/data/sales_cleaned.csv'
   INTO TABLE sales
   FIELDS TERMINATED BY ','
   OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\r\n'
   IGNORE 1 LINES
   (
       row_id, order_id, order_date, ship_date, ship_mode, customer_id, customer_name,
       segment, country, city, state, @v_postal_code, region, product_id, category,
       sub_category, product_name, sales, year, month, month_name, year_month
   )
   SET postal_code = NULLIF(TRIM(@v_postal_code), '');
   ```

### Method 2: MySQL Workbench Table Data Import Wizard
1. Open MySQL Workbench and expand `ecommerce_sales`.
2. Right-click the `sales` table and select **Table Data Import Wizard**.
3. Browse and select `data/sales_cleaned.csv`.
4. Keep default column mappings and complete the import.

---

## 📁 SQL Script Catalog & Business Coverage

| Script File | Focus Area | Primary Business Questions Addressed | Advanced SQL Techniques Used |
| :--- | :--- | :--- | :--- |
| **`01_database_setup.sql`** | Infrastructure | How is the analytical environment initialized, constrained, indexed, and populated? | DDL, Data Typing, Composite Indexing, `LOAD DATA LOCAL INFILE` |
| **`02_data_validation.sql`** | Data Quality | Is row count exactly 9,800? Are there duplicate orders, dates, or invalid sales amounts? | Integrity Auditing, Conditional Aggregations (`CASE WHEN`), Null Audits |
| **`03_business_kpis.sql`** | Executive KPIs | What are the total sales ($2.26M), order count (4,922), unique customers (793), and AOV ($459.48)? | Scalar Aggregations, Distinct Counting, Executive Scorecard CTE |
| **`04_time_analysis.sql`** | Temporal & Growth | How did revenue grow year-over-year? What is the 48-month trend? Which year had peak revenue? | Window Functions (`LAG`), YoY/MoM % Growth, Seasonality Rollups |
| **`05_category_analysis.sql`** | Merchandise Breakdown | Which categories lead sales? What are the top 5 and bottom 5 sub-categories? | Window Functions (`SUM() OVER()`, `DENSE_RANK()`), Within-Category Contribution |
| **`06_geographic_analysis.sql`** | Territory Performance | How do regions and states rank by sales? Which city/state leads each region? | Partitioned Rankings (`ROW_NUMBER() / DENSE_RANK() OVER (PARTITION BY region)`), State Share % |
| **`07_customer_analysis.sql`** | Customer Intelligence | Who are the top 10 spenders? How is revenue split across Consumer, Corporate, and Home Office? | Customer Segmentation, Benchmark Subqueries, Spend Distribution Tiers |
| **`08_product_analysis.sql`** | Catalog & SKU Dynamics | Which top 10 products drive maximum sales? What are the top 3 items in each category? | Catalog Leaderboards, Partitioned SKU Rankings, Merchandising Matrix |
| **`09_shipping_analysis.sql`** | Logistics & Operations | What is the revenue and order share per shipping mode? What is the average fulfillment time in days? | `DATEDIFF()`, Logistics Volume Comparison, Regional Preference Cross-Tabs |
| **`10_cte_analysis.sql`** | Multi-Step Modeling | How does sub-category sales compare to company benchmarks? How does the 80/20 Pareto rule apply? | Chained CTE Pipelines, Running Totals, RFM Value Tiers, Matrix Pivots |
| **`11_window_functions.sql`** | Window Functions Deep Dive | How do `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LAG`, and `LEAD` operate on actual business scenarios? | Complete Window Function Showcase: Offset, Ranking, and Partition Aggregates |
| **`12_advanced_business_analysis.sql`** | Advanced Analytics | What are YTD cumulative sales? Dual-axis MoM/YoY growth? Top 3 customers per region? | Multi-Tier Partitioning, Rolling Running Totals, Dual Lag Offsets, Outlier Filtering |
| **`13_final_insights.sql`** | Automated Findings | What is the single strongest year, category, sub-category, region, state, customer, and product? | Dynamic Executive Scorecard, `UNION ALL`, Self-Calculating Insight Engine |

---

## 🧠 Advanced SQL Concepts Demonstrated

### 1. Common Table Expressions (CTEs)
CTEs (`WITH cte_name AS (...)`) are used extensively across scripts `04`, `07`, `10`, `12`, and `13` to break complex business questions into readable, maintainable, and modular logical steps:
- Chaining multiple CTEs to compute intermediate benchmarks before calculating deviations.
- Isolating baseline averages (e.g., overall average customer spend) and cross-joining with customer-level aggregations.

### 2. Analytical Window Functions

#### Ranking Functions (`ROW_NUMBER` vs `RANK` vs `DENSE_RANK`)
- **`ROW_NUMBER()`**: Deterministically picks the exact top item per group without ties (used in `06` for #1 state per region and in `08` for top flagship SKU per sub-category).
- **`RANK()`**: Assigns equal rank for ties, skipping consecutive rank numbers (e.g., 1, 2, 2, 4).
- **`DENSE_RANK()`**: Assigns equal rank for ties without skipping rank numbers (e.g., 1, 2, 2, 3), ideal for top-3 leaderboards and customer spending tiers.

#### Value Offset Functions (`LAG` & `LEAD`)
- **`LAG(column, offset)`**: Accesses historical periods to compute Period-over-Period growth rates:
  $$\text{YoY Growth \%} = \frac{\text{Sales}_{\text{Current}} - \text{Sales}_{\text{Prior}}}{\text{Sales}_{\text{Prior}}} \times 100$$
- **`LEAD(column, offset)`**: Accesses subsequent forward rows to forecast trajectory or compute gap analysis.

#### Window Aggregations
- **`SUM(...) OVER ()`**: Computes grand totals across the entire table without collapsing detail rows into a single group.
- **`SUM(...) OVER (PARTITION BY category)`**: Computes category-level totals to calculate within-category contribution percentages.
- **`SUM(...) OVER (ORDER BY year_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`**: Generates cumulative running balances over time.

---

## 📈 Key Business Findings & Executive Summary

All findings below are dynamically computed from the actual database in `13_final_insights.sql`:

```
========================================================================================================
                               EXECUTIVE INSIGHTS SCORECARD
========================================================================================================
KPI Dimension                  Champion / Leader               Sales (USD)       % of Total Revenue
--------------------------------------------------------------------------------------------------------
Strongest Sales Year           2018                            $722,052.02       31.93%
Strongest Product Category     Technology                      $827,455.87       36.59%
Strongest Sub-Category         Phones                          $327,782.45       14.49%
Strongest Geographic Region    West Region                     $710,219.68       31.40%
Strongest State Market         California                      $446,306.46       19.73%
Strongest Customer Segment     Consumer                        $1,148,061.47     50.76%
Top Revenue Product SKU        Canon imageCLASS 2200 Copier    $61,599.82        2.72%
Top Lifetime Customer          Sean Miller                     $25,043.05        1.11%
Dominant Shipping Mode         Standard Class (2,945 orders)   $1,340,830.50     59.29%
========================================================================================================
```

### Strategic Narrative:
1. **Accelerating Growth Trajectory**: Annual sales expanded from **$479,856** in 2015 to **$722,052** in 2018 (+50.5% overall expansion), driven by strong acceleration in 2017 (+30.6% YoY) and 2018 (+20.3% YoY).
2. **Q4 Seasonality Concentration**: Sales systematically surge in **November ($345,649)** and **December ($321,523)**, accounting for nearly **30%** of all historical annual revenue.
3. **Core Merchandise Powerhouse**: **Technology ($827.5K, 36.6%)** and **Furniture ($728.7K, 32.2%)** drive the majority of sales, with **Phones ($327.8K)** and **Chairs ($322.8K)** representing the top 2 sub-categories.
4. **Geographic Foothold in the West**: The **West Region ($710.2K, 31.4%)** and **East Region ($669.5K, 29.6%)** represent over 60% of total revenue. **California ($446.3K)** and **New York ($306.4K)** are the two powerhouse states.
5. **Consumer Segment Dominance**: **Consumers** generate **$1.15M (50.8%)** of all sales across 5,101 order lines, while **Corporate ($688.5K, 30.4%)** and **Home Office ($425.0K, 18.8%)** represent high-AOV business clients.
6. **Logistics Efficiency**: **Standard Class** is the default fulfillment method chosen for **59.8%** of orders, maintaining an average delivery window of 5.0 days.

---

## 💼 Data Analyst Portfolio & Interview Discussion Points

When presenting this project in a Data Analyst interview or portfolio review, highlight the following design decisions:

1. **Why MySQL 8.0+ Window Functions over Self-Joins?**
   - *Discussion*: Traditional SQL (MySQL 5.7) required costly self-joins and subqueries to calculate running totals and period-over-period lags. Window functions execute in a single scan with $O(N \log N)$ complexity, making the pipeline scalable and readable.
2. **Data Integrity & Preserving Raw Values**:
   - *Discussion*: The dataset contained 11 missing postal codes. Instead of filling them with synthetic values (which could distort geographic data), they were explicitly preserved as `NULL` and validated in `02_data_validation.sql` without impacting city/state/region rollups.
3. **Preventing Artificial Metric Invention**:
   - *Discussion*: Since the cleaned dataset does not include a verified cost or profit column, no fictitious profit calculations were fabricated. The focus was kept on verified metrics: Revenue, Order Volume, AOV, Customer Lifetime Spend, and Unit Economics.
4. **Modularity & GitHub Readiness**:
   - *Discussion*: Rather than one monolithic SQL file, the analysis is separated into 13 cleanly structured scripts, each answering specific stakeholder questions with clear comments, standard aliases, and execution explanations.

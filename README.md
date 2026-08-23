# 🛒 E-Commerce Sales Analysis Dashboard

An end-to-end data analytics portfolio project transforming raw e-commerce transaction records into verified business intelligence through **Python (Pandas, NumPy, Matplotlib, Seaborn)**, **SQL (MySQL 8.0+)**, and **Power BI**.

---

## 📖 Project Overview

This project analyzes historical retail transaction data from a US-based e-commerce store operating across 49 states. The objective is to identify revenue trajectories, analyze customer purchasing behavior, evaluate merchandise category dynamics, diagnose regional performance, and deliver data-backed strategic recommendations for commercial growth.

By establishing a structured data pipeline—from automated data cleaning and exploratory data analysis (EDA) to advanced relational SQL modeling and executive dashboard prototyping—this project demonstrates how raw transactional logs are systematically transformed into actionable executive decision frameworks.

---

## 🎯 Business Objectives

The analysis addresses core commercial questions across five critical business dimensions:

1. **Temporal Trends & Growth**: How has sales revenue evolved year-over-year from 2015 to 2018? What seasonal patterns and monthly demand surges impact operations?
2. **Merchandise & Category Dynamics**: Which product categories and sub-categories generate the largest share of revenue? Which product lines represent underperforming long-tail inventory?
3. **Product Performance**: Which individual flagship SKUs drive catalog-wide revenue concentration?
4. **Geographic Distribution**: Which territories and states represent the primary revenue engines? Where are the underpenetrated regional markets?
5. **Customer Segmentation & Unit Economics**: How is sales volume distributed across Consumer, Corporate, and Home Office segments? Who are the top lifetime value accounts?
6. **Logistics & Fulfillment**: Which shipping modes are most frequently selected, and how does fulfillment speed impact order distribution?

---

## 📂 Dataset Architecture

The analysis is based on the cleaned transactional dataset ([`data/sales_cleaned.csv`](data/sales_cleaned.csv)), containing **9,800 rows** and **22 columns** with zero synthetic inflation.

| Attribute Dimension | Columns Included | Description & Constraints |
| :--- | :--- | :--- |
| **Transaction Identifiers** | `row_id`, `order_id` | Unique row identifier (1–9,800) and alphanumeric order code (4,922 unique orders) |
| **Temporal Data** | `order_date`, `ship_date`, `year`, `month`, `month_name`, `year_month` | Operating period from **2015-01-03 to 2018-12-30** (4 calendar years / 48 operating months) |
| **Customer Demographics** | `customer_id`, `customer_name`, `segment` | 793 distinct customer accounts across `Consumer`, `Corporate`, and `Home Office` |
| **Geographic Footprint** | `country`, `city`, `state`, `postal_code`, `region` | United States market covering 49 states, 529 cities, and 4 regions (`West`, `East`, `Central`, `South`). 11 missing postal codes preserved as `NULL` |
| **Product & Merchandising** | `product_id`, `category`, `sub_category`, `product_name` | 1,861 unique SKUs across 3 major categories (`Technology`, `Furniture`, `Office Supplies`) and 17 sub-categories |
| **Financial Metric** | `sales` | Transaction gross revenue in USD ranging from **$0.44 to $22,638.48** (Total: **$2,261,536.78**) |

> [!NOTE]
> In accordance with data integrity best practices, no unverified Profit metric has been fabricated, as the underlying dataset contains strictly verified gross Sales transactions.

---

## 🔄 Project Workflow Pipeline

```
Raw Transactional Data (data/sales.csv)
   │
   ▼
Phase 1: Data Cleaning & Preprocessing (Python / Pandas)
   ├── Handled missing values & validated 11 NULL postal codes
   ├── Converted date strings to datetime objects
   └── Created feature-engineered temporal columns (Year, Month, Year-Month)
   │
   ▼
Phase 2: Exploratory Data Analysis (EDA) (Python / Matplotlib / Seaborn)
   ├── Statistical distribution & outlier analysis
   ├── Monthly seasonality curves & category rollups
   └── Top SKU and customer Pareto distributions
   │
   ▼
Phase 3: Relational SQL Analytics (MySQL 8.0+)
   ├── Normalized database schema & indexing strategy (01_database_setup.sql)
   ├── Automated data quality & sanity checks (02_data_validation.sql)
   ├── Executive KPIs, YoY / MoM growth with LAG() & LEAD() (03–09)
   └── Multi-step CTE modeling, window rankings & dynamic insights (10–13)
   │
   ▼
Phase 4: Business Intelligence Data Modeling (Power BI Desktop)
   ├── Imported sales_cleaned.csv and created DateTable dimension
   ├── Configured active 1:* relationship (DateTable[Date] -> sales[order_date])
   ├── Built DAX KPI measures (Total Sales, Orders, Customers, AOV)
   └── Prototyped 2-Page Executive Dashboard Layout (Visual build in progress)
   │
   ▼
Phase 5: Strategic Business Recommendations
   └── Data-driven decisions for merchandising, regional expansion & customer retention
```

---

## 🛠️ Technologies Used

| Category | Tools & Libraries | Application in Project |
| :--- | :--- | :--- |
| **Programming & Data Processing** | `Python 3.10+`, `Pandas`, `NumPy` | Data ingestion, cleaning, date standardization, schema profiling |
| **Exploratory Visualization** | `Matplotlib`, `Seaborn` | Distribution plots, correlation heatmaps, seasonal trend curves |
| **Relational Database & SQL** | `MySQL 8.0+` | Database DDL, indexing, data validation, CTEs, Window Functions |
| **Business Intelligence** | `Microsoft Power BI Desktop`, `DAX`, `Power Query (M)` | Tabular data modeling, Star Schema, DAX KPI measures, dashboard prototyping |
| **Environment & Version Control** | `Jupyter Notebook`, `Git`, `GitHub` | Interactive analysis documentation and modular version control |

---

## 🔬 Implementation Phases & Current Project Status

### 🟩 Phase 1 — Data Preparation & Cleaning ✅ (Completed)
Performed in Python ([`notebook/sales_analysis.ipynb`](notebook/sales_analysis.ipynb)):
* **Missing Value Audit**: Identified 11 missing `Postal Code` entries (all located in Burlington, Vermont). Maintained these records as `NULL` without synthetic imputation since postal code is not required for state- and regional-level rollups.
* **Type Normalization**: Converted `Order Date` and `Ship Date` from object strings to ISO `YYYY-MM-DD` datetime formats.
* **Feature Engineering**: Extracted temporal dimensions (`Year`, `Month`, `Month Name`, `Year-Month`) to ensure seamless chronological sorting in SQL and Power BI.
* **ETL Export**: Saved the clean, validated dataset as [`data/sales_cleaned.csv`](data/sales_cleaned.csv) (9,800 rows $\times$ 22 columns).

---

### 🟨 Phase 2 — Exploratory Data Analysis (EDA) ✅ (Completed)
Conducted comprehensive statistical and visual profiling in Python:
* Analyzed sales distributions (Mean: **$230.77**, Median: **$54.49**, Max: **$22,638.48**).
* Evaluated order volume density across calendar months, confirming strong seasonal concentration in Q4.
* Mapped customer purchasing frequencies, revealing that **50.8%** of transactions originate from individual retail consumers.

---

### 🟦 Phase 3 — Python Business Analysis Insights ✅ (Completed)
Major findings established during Python EDA:
* **Strong Overall Growth**: Gross revenue expanded from **$479,856** in 2015 to **$722,052** in 2018 (+50.5% total growth).
* **Q4 Holiday Surge**: November ($345.6K) and December ($321.5K) consistently generate peak sales across all four operating years.
* **Regional Dominance**: The West region leads with **$710.2K** (31.4% share), followed closely by the East region with **$669.5K** (29.6% share).

---

### 🟧 Phase 4 — SQL Analytics (MySQL 8.0+) ✅ (Completed)

The [`sql/`](sql/) directory contains 13 production-grade MySQL scripts covering end-to-end data validation and business analytics:

| Script File | Focus Area | Key Business Questions & Techniques |
| :--- | :--- | :--- |
| **[`01_database_setup.sql`](sql/01_database_setup.sql)** | DDL & Ingestion | Schema definition (22 columns), composite indexes, and `LOAD DATA LOCAL INFILE` scripts |
| **[`02_data_validation.sql`](sql/02_data_validation.sql)** | Data Quality | Verification of 9,800 rows, duplicate checks, NULL audits, and date integrity checks |
| **[`03_business_kpis.sql`](sql/03_business_kpis.sql)** | Executive KPIs | Total Sales ($2.26M), Orders (4,922), Customers (793), Products (1,861), AOV ($459.48) |
| **[`04_time_analysis.sql`](sql/04_time_analysis.sql)** | Temporal Analysis | Annual performance, YoY growth with `LAG()`, monthly seasonality, and 48-month trend |
| **[`05_category_analysis.sql`](sql/05_category_analysis.sql)** | Merchandising | Category revenue share (`SUM() OVER()`), Top 5 / Bottom 5 sub-categories, category ranking |
| **[`06_geographic_analysis.sql`](sql/06_geographic_analysis.sql)** | Geography | Regional market shares, state rankings (all 49 states), and Top 10 / Bottom 10 states |
| **[`07_customer_analysis.sql`](sql/07_customer_analysis.sql)** | Customer Intel | Segment contributions, Top 10 spenders, customer rankings with `DENSE_RANK()`, frequency tiers |
| **[`08_product_analysis.sql`](sql/08_product_analysis.sql)** | Catalog Dynamics | Top 10 / Bottom 10 SKUs, catalog ranking (1,861 SKUs), and top 3 products per category |
| **[`09_shipping_analysis.sql`](sql/09_shipping_analysis.sql)** | Logistics | Shipping mode volume shares, turnaround time in days (`DATEDIFF`), regional preferences |
| **[`10_cte_analysis.sql`](sql/10_cte_analysis.sql)** | Advanced CTEs | Category benchmark variance CTE, multi-year tracker CTE, Pareto 80/20 CTE, RFM tiers |
| **[`11_window_functions.sql`](sql/11_window_functions.sql)** | Window Masterclass | Demonstrating `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `LAG()`, `LEAD()`, and `NTILE(10)` |
| **[`12_advanced_business_analysis.sql`](sql/12_advanced_business_analysis.sql)** | Advanced Metrics | YTD running totals, dual-axis MoM/YoY growth, Top 3 per region, transactions above average |
| **[`13_final_insights.sql`](sql/13_final_insights.sql)** | Dynamic Insights | Dynamic SQL summary query computing all key findings directly from database tables |

*For complete technical documentation, see [`sql/README.md`](sql/README.md).*

---

### 🟪 Phase 5 — Power BI Data Model & Dashboard Status

The Power BI data model has been created and saved directly in **Microsoft Power BI Desktop** ([`dashboard/sales_dashboard.pbix`](dashboard/sales_dashboard.pbix)).

#### Current Completed State:
* **Dataset Import**: Ingested all 9,800 rows and 22 attributes from [`data/sales_cleaned.csv`](data/sales_cleaned.csv).
* **Calendar Dimension (`DateTable`)**: Created dedicated DAX Calendar table spanning 2015-01-01 to 2018-12-31 with chronological sorting rules.
* **Relationship**: Established active 1-to-many relationship (`DateTable[Date] 1 ---> * sales_cleaned[Order Date]`).
* **DAX KPI Measures**: Authored core measures including `Total Sales`, `Total Orders`, `Total Customers`, and `Average Order Value`.
* **Supporting Documentation**: Complete DAX measures, M code, theme JSON, and architecture guides are available under [`docs/power_bi/`](docs/power_bi/).

#### Planned / In-Progress 2-Page Dashboard Layout:
* **Page 1: Executive Sales Overview**: Top KPI cards, 48-month chronological sales trend line chart, sales by category, sales by region, customer segment donut chart, Top 5 states bar chart, and global slicers (`Year`, `Region`, `Category`, `Segment`).
* **Page 2: Product & Customer Analysis**: Top 10 products by sales, Top 10 customers by lifetime spend, Sub-Category drill-down hierarchy (`Category` $\rightarrow$ `Sub-Category`), shipping mode volume breakdown, and Regional Category Cross-Tabulation Matrix.

---

## 📸 Dashboard Previews (Design Prototypes)

### Page 1: Executive Sales Overview (Design Prototype)
![Page 1: Executive Sales Overview](images/dashboard_preview.png)

### Page 2: Product & Customer Analysis (Design Prototype)
![Page 2: Product & Customer Analysis](images/product_customer_dashboard_preview.png)

---

## 📈 Key Business Insights

All metrics below have been strictly calculated and verified across Python, SQL, and Power BI models:

```
========================================================================================================
                               EXECUTIVE INSIGHTS SUMMARY
========================================================================================================
KPI Dimension                  Leader / Finding                Verified Metric   % Share / Benchmark
--------------------------------------------------------------------------------------------------------
Cumulative Revenue             Gross Store Revenue             $2,261,536.78     100.00%
Total Order Volume             Distinct Purchase Orders        4,922 Orders      9,800 Line Items
Active Customer Base           Unique Customer Accounts        793 Accounts      $2,851.87 Avg / Cust
Catalog Breadth                Active Product SKUs             1,861 Products    17 Sub-Categories
Average Order Value (AOV)      Revenue per Distinct Order      $459.48           1.99 Items / Order
--------------------------------------------------------------------------------------------------------
Strongest Sales Year           2018                            $722,052.02       31.93% (+20.30% YoY)
Lowest Sales Year              2016                            $459,436.01       20.32% (-4.26% YoY)
Strongest Product Category     Technology                      $827,455.87       36.59%
Second Product Category        Furniture                       $728,658.58       32.22%
Third Product Category         Office Supplies                 $705,422.33       31.19%
Top Sub-Category (#1)          Phones (Technology)             $327,782.45       14.49%
Top Sub-Category (#2)          Chairs (Furniture)              $322,822.73       14.27%
Top Sub-Category (#3)          Storage (Office Supplies)       $219,343.39        9.70%
Strongest Geographic Region    West Region                     $710,219.68       31.40%
Second Geographic Region       East Region                     $669,518.73       29.60%
Top State Market (#1)          California (West)               $446,306.46       19.73%
Top State Market (#2)          New York (East)                 $306,361.15       13.55%
Top State Market (#3)          Texas (Central)                 $168,572.53        7.45%
Strongest Customer Segment     Consumer                        $1,148,061.47     50.76% (5,101 Lines)
Second Customer Segment        Corporate                       $688,494.07       30.44% (2,953 Lines)
Third Customer Segment         Home Office                     $424,982.24       18.79% (1,746 Lines)
Top Revenue Product SKU        Canon imageCLASS 2200 Copier    $61,599.82         2.72% (Technology)
Top Lifetime Customer          Sean Miller                     $25,043.05         1.11% (Consumer)
Dominant Shipping Mode         Standard Class                  $1,340,830.50     59.29% (59.83% Orders)
========================================================================================================
```

---

## 💡 Strategic Business Recommendations

Based on empirical data findings, the following strategic actions are recommended:

1. **Capitalize on Q4 Holiday Surges**: With November and December contributing nearly **30% of total annual sales**, the supply chain and fulfillment teams must secure high-velocity inventory buffers (specifically Technology and Office Supplies) by late Q3 to mitigate stockouts.
2. **Double Down on High-Margin Technology Flagships**: Technology accounts for **36.6%** of revenue, led by Phones ($327.8K) and Copiers. Bundling lower-performing accessories with flagship hardware can boost basket depth beyond the current 1.99 items/order.
3. **Targeted Expansion in the South Region**: The South region contributes only **17.2% ($389.2K)** of national revenue. Investigating regional pricing, marketing presence, and shipping lead times in high-potential southern states can unlock underpenetrated market share.
4. **Tailored Retention for the Consumer Segment**: Consumers generate **50.8% ($1.15M)** of total revenue across 5,101 transactions. Introducing a structured customer loyalty program and personalized re-engagement campaigns can lift repeat purchase rates and average order values.
5. **Inventory Rationalization for Long-Tail Sub-Categories**: The bottom 5 sub-categories (Fasteners $3.0K, Labels $12.3K, Envelopes $16.1K, Art $26.7K, Supplies $46.4K) collectively generate less than **5% of total sales**. Re-evaluating holding costs and SKU breadth in these categories will optimize working capital.

---

## 🧠 SQL Concepts Demonstrated

The SQL analytical suite incorporates foundational and advanced query constructs:

* **Core Aggregations & Grouping**: `SELECT`, `WHERE`, `GROUP BY`, `ORDER BY`, `HAVING`, `COUNT(DISTINCT ...)`, `SUM()`, `AVG()`, `MIN()`, `MAX()`, `STDDEV()`
* **Conditional Logic**: Multi-branch `CASE WHEN ... THEN ... ELSE ... END` statements for data quality auditing and custom tier segmentation
* **Common Table Expressions (CTEs)**: Single and multi-step chained `WITH` clauses for modular business logic, benchmark comparisons, and Pareto analysis
* **Ranking Window Functions**:
  - `ROW_NUMBER()`: Unique sequential ordering for selecting top-1 flagship SKUs per group
  - `RANK()`: Ordinal ranking with gaps for competition leaderboards
  - `DENSE_RANK()`: Consecutive tie-breaking ranking for top-N regional and category queries
  - `NTILE(10)`: Customer spending decile segmentation
* **Value Navigation Window Functions**:
  - `LAG()`: Period-over-period delta and percentage growth calculations (YoY and MoM)
  - `LEAD()`: Forward-looking period comparisons and trend gap analysis
* **Partitioned Aggregations**: `SUM(...) OVER (PARTITION BY category)` and `SUM(...) OVER ()` for dynamic portfolio contribution share percentages without self-joins
* **Cumulative Window Math**: Running totals via `SUM(...) OVER (ORDER BY year_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`

---

## 🏗️ Repository Structure

```
ecommerce-sales-analysis/
│
├── data/
│   ├── sales.csv                              # Original raw dataset
│   └── sales_cleaned.csv                      # Cleaned dataset (9,800 rows × 22 columns)
│
├── notebook/
│   └── sales_analysis.ipynb                   # Jupyter notebook with complete Python EDA
│
├── sql/
│   ├── 01_database_setup.sql                  # Schema DDL, indexing, and data loading
│   ├── 02_data_validation.sql                 # Data quality, duplicate, and null audit checks
│   ├── 03_business_kpis.sql                   # Core business KPIs and executive scorecard
│   ├── 04_time_analysis.sql                   # Yearly, monthly, seasonal, and YoY/MoM growth
│   ├── 05_category_analysis.sql               # Category and sub-category performance rankings
│   ├── 06_geographic_analysis.sql             # Regional shares, state rankings, and city hubs
│   ├── 07_customer_analysis.sql               # Segment analytics, top customers, and RFM tiers
│   ├── 08_product_analysis.sql                # Top/bottom SKUs and within-category leaders
│   ├── 09_shipping_analysis.sql               # Shipping modes, turnaround time, and preferences
│   ├── 10_cte_analysis.sql                    # Multi-step CTE business models and Pareto 80/20
│   ├── 11_window_functions.sql                # Comprehensive window function masterclass
│   ├── 12_advanced_business_analysis.sql      # Running totals, dual growth, and benchmark queries
│   ├── 13_final_insights.sql                  # Dynamic SQL engine computing key findings
│   └── README.md                              # Master SQL documentation and query catalog
│
├── dashboard/
│   └── sales_dashboard.pbix                   # Power BI Desktop report file (Model, DateTable, Measures)
│
├── docs/
│   └── power_bi/
│       ├── DAX_Measures.dax                   # Production DAX measures library
│       ├── Date_Table.dax                     # Calendar dimension DAX generation script
│       ├── PowerQuery_M_Code.m                # Power Query (M) ETL ingestion script
│       ├── theme.json                         # Custom corporate Power BI theme
│       └── README.md                          # Master Power BI architecture & layout guide
│
├── images/
│   ├── dashboard_preview.png                  # Executive Sales Overview render
│   └── product_customer_dashboard_preview.png # Product & Customer Analysis render
│
└── README.md                                  # Main project documentation
```

---

## 🚀 How to Run the Project

### 1. Python Environment Setup
```bash
# Clone the repository
git clone https://github.com/siva252005/ecommerce-sales-analysis.git
cd ecommerce-sales-analysis

# Install required Python packages
pip install pandas numpy matplotlib seaborn jupyter

# Launch Jupyter Notebook
jupyter notebook notebook/sales_analysis.ipynb
```

### 2. MySQL Database Setup
1. Open MySQL CLI or MySQL Workbench.
2. Execute [`sql/01_database_setup.sql`](sql/01_database_setup.sql) to create `ecommerce_sales` database and `sales` table.
3. Ingest data using the `LOAD DATA LOCAL INFILE` script provided in `01_database_setup.sql` pointing to [`data/sales_cleaned.csv`](data/sales_cleaned.csv).
4. Run scripts [`02_data_validation.sql`](sql/02_data_validation.sql) through [`13_final_insights.sql`](sql/13_final_insights.sql) to reproduce all analytical queries.

### 3. Power BI Desktop Exploration
1. Open [`dashboard/sales_dashboard.pbix`](dashboard/sales_dashboard.pbix) directly in **Microsoft Power BI Desktop**.
2. Inspect the tabular model and verified relationship (`DateTable[Date] 1 ---> * sales_cleaned[Order Date]`).
3. Explore the pre-built DAX measures in the Data pane.
4. Reference [`docs/power_bi/README.md`](docs/power_bi/README.md) and [`docs/power_bi/theme.json`](docs/power_bi/theme.json) for visual styling and report page design specifications.

---

## 💼 How I Would Explain This Project in an Interview

### 🎙️ 60–90 Second Executive Pitch
> *"In this project, I built an end-to-end e-commerce sales analytics suite analyzing $2.26 million in revenue across 9,800 transactions and 4,922 orders from 2015 to 2018. 
> 
> I started by cleaning and engineering temporal features in Python using Pandas, ensuring date normalization and strict data integrity without fabricating missing data. Next, I designed a MySQL 8.0 relational database schema with performance indexing and authored 13 analytical SQL scripts leveraging multi-step CTEs, window functions (like LAG, LEAD, and DENSE_RANK), and partitioned aggregations to uncover revenue growth trends, merchandise Pareto distributions, and customer spending tiers. 
> 
> In Power BI Desktop, I engineered a Star Schema tabular data model with an active 1-to-many relationship between a dedicated DAX DateTable and the sales dataset, authored core DAX KPI measures for AOV and volume, and developed 2-page dashboard layout prototypes for executive and product/customer analysis. 
> 
> The analysis revealed three pivotal findings: an accelerating growth trajectory reaching $722K in 2018 (+20.3% YoY), a recurring Q4 seasonal surge where November and December generate nearly 30% of annual revenue, and significant geographic concentration where California and New York drive a third of national sales. These insights directly informed strategic recommendations for inventory pre-buffering, loyalty program structuring, and regional marketing expansion."*

---

### ❓ 10 Likely Interview Questions & Concise Technical Answers

#### 1. Why did you choose not to impute the 11 missing Postal Code values?
> **Answer**: *"The 11 missing postal codes were all associated with Burlington, Vermont. Because our core geographic analysis focused on state- and regional-level rollups rather than ZIP-code routing, imputing synthetic values could introduce false precision. Preserving them as `NULL` maintained data integrity without impacting state or regional totals."*

#### 2. Why is there no Profit metric in your analysis?
> **Answer**: *"The cleaned raw dataset only contained verified gross sales transactions and lacked explicit unit cost or discount-adjusted margin fields. Rather than inventing arbitrary cost assumptions, I adhered to data governance standards by focusing on verified commercial KPIs: Revenue, Order Volume, AOV, Customer Lifetime Spend, and Unit Economics."*

#### 3. How did you handle Year-over-Year (YoY) growth calculations in SQL?
> **Answer**: *"I used Common Table Expressions (CTEs) combined with the `LAG()` window function ordered by `year`. `LAG(current_sales, 1)` fetched the preceding year's sales into the current row context, enabling dynamic calculation of dollar variance and percentage growth without complex self-joins."*

#### 4. What is the difference between `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`, and where did you apply them?
> **Answer**: *" `ROW_NUMBER()` generates a strict sequential integer (1, 2, 3) regardless of ties; I used it to select the #1 flagship SKU per sub-category. `RANK()` leaves gaps after tied values (1, 2, 2, 4), while `DENSE_RANK()` assigns consecutive integers after ties (1, 2, 2, 3); I used `DENSE_RANK()` for Top 3 customer and product leaderboards to ensure tied performers share the same tier without skipping subsequent ranks."*

#### 5. Why did you build a dedicated DAX `DateTable` instead of using Power BI's automatic date hierarchy?
> **Answer**: *"Automatic date hierarchies create hidden tables for every date column, bloating file size and limiting model flexibility. A dedicated DAX `DateTable` enables standard Time-Intelligence functions, explicit $1:*$ relationships with `sales_cleaned[Order Date]`, and custom sorting such as ordering `Month Name` by `Month Number` and `Year-Month` chronologically."*

#### 6. What did the Pareto analysis reveal about the product catalog?
> **Answer**: *"Using a running cumulative total window function over product sales, the Pareto query demonstrated that the top 20% of catalog SKUs generate over 70% of total revenue. Flagship products like the Canon imageCLASS 2200 Copier ($61.6K) heavily influence top-line numbers, indicating high revenue sensitivity to core product availability."*

#### 7. How did you resolve the Q4 seasonality pattern in the data?
> **Answer**: *"By aggregating sales across calendar months and evaluating chronological 48-month trends, we observed that November ($345.6K) and December ($321.5K) systematically outperform other months by 40–60%. This points to intense holiday retail seasonality, suggesting that inventory procurement and marketing campaigns should ramp up in early Q3."*

#### 8. What is the difference between `Average Sales` and `Average Order Value (AOV)` in your project?
> **Answer**: *"`Average Sales` ($230.77) is the arithmetic mean across all 9,800 individual line-item transactions (`AVG(sales)`). `Average Order Value` ($459.48) is total revenue divided by the 4,922 distinct orders (`SUM(sales) / COUNT(DISTINCT order_id)`), capturing the total basket value per checkout transaction."*

#### 9. How did you optimize query performance in MySQL?
> **Answer**: *"I created targeted composite and single-column indexes on key analytical attributes: `order_date`, `customer_id`, `product_id`, `(category, sub_category)`, `(region, state)`, and `segment`. This accelerated window function partitioning, grouping, and date-range filtering across the 9,800 rows."*

#### 10. If you had access to shipping cost data, how would you expand this project?
> **Answer**: *"I would compute net contribution margin per shipping tier (`sales - shipping_cost`), analyze whether 'Same Day' and 'First Class' expedite options yield higher customer retention, and evaluate logistics route profitability across remote vs. metropolitan state hubs."*

---

## 📌 Conclusion

This project demonstrates a production-grade analytics lifecycle—combining rigorous data cleaning in Python, deep relational modeling in MySQL, and structured tabular data modeling in Power BI Desktop to transform raw transaction records into verified, high-impact business intelligence.

# Olist E-commerce Revenue & Customer Insights

## Project Overview
This project analyzes the Brazilian Olist e-commerce dataset with PostgreSQL to explore sales performance, customer behavior, product and seller performance, and delivery operations.

**Tools:** PostgreSQL, pgAdmin 4, SQL  
**Next phase:** Power BI dashboard and DAX measures

## Business Objectives
- Measure item revenue and order activity over time.
- Understand customer spending and repeat-purchase behavior.
- Identify top-performing products and sellers.
- Analyze payment methods and customer reviews.
- Evaluate delivery time and late-delivery performance.
- Validate imported data and table relationships.

## Dataset
Source: [Brazilian E-Commerce Public Dataset by Olist on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

The dataset contains related files for customers, orders, order items, payments, reviews, products, sellers, and product-category translations.

**Attribution and license:** Attribute the dataset to Olist. The dataset is provided under **CC BY-NC-SA 4.0**; review the license terms before redistributing the dataset or using it commercially.

## Database Structure
Data was imported into PostgreSQL database `ecommerce_analytics`, schema `olist`.

| Table | Imported rows | Purpose |
|---|---:|---|
| `customers` | 99,441 | Customer records and unique-customer identifiers |
| `orders` | 99,441 | Order status and purchase/delivery timestamps |
| `order_items` | 112,650 | Products, sellers, item prices and freight |
| `order_payments` | 103,886 | Payment types, installments and payment values |
| `order_reviews` | 99,224 | Customer review records and scores |
| `products` | 32,951 | Product details and category identifiers |
| `sellers` | 3,095 | Seller records |
| `category_translation` | 71 | Product-category translations |

### Key relationships
- `orders.customer_id` → `customers.customer_id`
- `order_items.order_id` → `orders.order_id`
- `order_items.product_id` → `products.product_id`
- `order_items.seller_id` → `sellers.seller_id`
- `order_payments.order_id` → `orders.order_id`
- `order_reviews.order_id` → `orders.order_id`
- `products.product_category_name` → `category_translation.product_category_name`

## Project Workflow
1. Created PostgreSQL tables and imported the source data.
2. Checked row counts and key relationships.
3. Investigated missing values and repeated review IDs.
4. Analyzed business questions using joins, aggregations, CTEs, window functions, date functions, and conditional logic.
5. Combined major business metrics into an executive summary.
6. Prepared for Power BI data modeling and dashboard development.

## Data Validation Highlights
- Verified row counts across all eight imported tables.
- The relationship checks found no orders without matching customer records and no order-item records with missing matching products or sellers.
- Found 3 orders without payment rows and 942 orders without review rows.
- Identified 8 orders marked `delivered` with a missing customer-delivery timestamp; these were flagged for investigation.
- `order_reviews.review_id` was not unique across all rows. Repeated IDs should not be deleted without confirming that the records are true duplicates.
- Delivery metrics were calculated for delivered orders with both actual and estimated delivery dates available.

## Business Questions Analyzed
- How does revenue change month over month?
- What is cumulative revenue over time?
- Which payment methods account for the most payment value?
- What proportion of customers place repeat orders?
- Which products generate the highest revenue within each category?
- Which sellers generate the highest item sales?
- How do review scores vary by order status?
- What is the average delivery time?
- What share of eligible delivered orders arrived late?
- How do customer spending segments compare?
- What does an executive-level summary reveal about sales and operations?

## Key Findings

### Executive summary
| Metric | Result |
|---|---:|
| Total item revenue | R$ 13,591,643.70 |
| Distinct orders containing items | 98,666 |
| Unique customers who placed orders | 96,096 |
| Distinct products sold | 32,951 |
| Active sellers with item records | 3,095 |
| Delivered orders with required delivery dates | 96,470 |
| Average purchase-to-delivery time | 12.56 days |
| Late-delivery rate among eligible delivered orders | 8.11% |

**Metric definitions:** The final executive query uses `COUNT(DISTINCT order_id)` for orders containing items, giving 98,666 distinct orders. The `order_items` table contains 112,650 item records because an order can contain multiple items. The late-delivery rate was verified as 7,826 late orders out of 96,470 eligible delivered orders (8.11%).

### Monthly revenue
- November 2017 recorded item revenue of approximately R$1.01 million, with month-over-month growth of 52.10% compared with October 2017.
- December 2017 revenue declined by 26.36% compared with November 2017.
- Cumulative revenue used a window frame from `UNBOUNDED PRECEDING` through `CURRENT ROW` to calculate a running total.

### Payment methods
- Credit cards accounted for the largest total payment value in the analyzed payment records.
- Vouchers had the lowest average payment value among the defined payment methods in the recorded output.
- Payment record counts should not be interpreted as distinct order counts.

### Customer behavior
- The repeat-customer analysis identified 96,096 unique customers, of whom 2,997 were classified as repeat customers, approximately 3.00% under the query's customer definition.
- Under the selected spending thresholds (low: below R$100; medium: R$100 to below R$500; high: R$500 or more), medium-spending customers were the largest segment and contributed the highest segment revenue.
- These thresholds are analyst-defined and can be adjusted for business needs.

### Delivery performance
- Average purchase-to-delivery time was 12.56 days for eligible delivered orders.
- The verified late-delivery calculation found 7,826 late orders out of 96,470 eligible delivered orders, a rate of 8.11%.
- Delivery performance can be further examined by month, seller, and product category.

## SQL Skills Demonstrated
- `INNER JOIN` and `LEFT JOIN`
- `GROUP BY`, `HAVING`, and aggregate functions
- Common Table Expressions (CTEs)
- Window functions such as `LAG`, `DENSE_RANK`, and running totals
- `CASE WHEN` customer segmentation
- Date/time functions such as `DATE_TRUNC` and `EXTRACT`
- Conditional aggregation with `FILTER`
- Data-quality checks for nulls, missing relationships, and repeated identifiers
- Revenue, customer, product, seller, and delivery KPI calculations

## Repository Files
- `01_create_tables.sql` — table definitions
- `02_data_validation.sql` — row counts and data-quality checks
- `03_Business_analysis.sql` — business questions and analytical queries

Place these scripts in the repository alongside this README. Do not commit passwords, private credentials, or unlicensed raw data.

## How to Reproduce
1. Download the dataset from the Kaggle source above and review its license.
2. Create a PostgreSQL database named `ecommerce_analytics`.
3. Create the `olist` schema and tables using `01_create_tables.sql`.
4. Import the source CSV files into the corresponding tables.
5. Run `02_data_validation.sql` to validate row counts and relationships.
6. Run selected queries in `03_Business_analysis.sql`.
7. Re-run the final executive summary and verify its metrics before publishing.
8. Connect Power BI to PostgreSQL or import validated tables, create a suitable data model, and build report pages and DAX measures.

## Next Phase: Power BI
Planned report sections:
- Executive overview: revenue, orders, customers, sellers, and delivery KPIs
- Sales trends: monthly revenue, month-over-month growth, and cumulative revenue
- Customer insights: one-time versus repeat customers and spending segments
- Product and seller performance: category and seller comparisons
- Delivery and reviews: delivery duration, late-delivery rate, and review-score analysis

Power BI measures and visuals will be checked against SQL outputs to keep metrics consistent.

## Limitations
- This is historical data, not live business performance.
- Item revenue from `order_items.price` excludes freight and differs from total payment value.
- Missing payment, review, or delivery records require careful interpretation.
- Spending segments use illustrative thresholds, not statistically optimized cutoffs.
- Re-run the final SQL scripts after changes and keep README figures aligned with the latest query outputs.

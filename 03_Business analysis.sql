--Business Question no 1: Total no of orders
SELECT COUNT(*)AS total_orders
FROM olist.orders;

--Business Question 2: Unique Customers
SELECT COUNT(DISTINCT customer_id)AS unique_customers
FROM olist.customers;

/*
Business Insight:
The dataset contains 99,441 total orders and same no of 
distinct customer_id values.
We will use customer_unique_id later to identify repeat customers.
*/

--Business Question 3: Total payment value
SELECT ROUND(SUM(payment_value)::numeric,2)AS total_payment_value
FROM olist.order_payments;
/*
Business Insight-
The dataset contains a total payment value of 16,008,872.12 in the datasets.
This is not necessarily accounting revenue or profit.
*/
--Business Question 4 — What is the average payment value per payment record
SELECT 
   ROUND(AVG(payment_value)::numeric,2)AS average_value
   FROM olist.order_payments;
/*
Business Insight:
The average payment value per payment record is 154.10.
This measures the average recorded payment amount,
not the average order value.
*/

-- Business Question 5: Highest payment value
SELECT 
   MAX(payment_value)AS highest_payment_record
   FROM olist.order_payments;
   
/*
Business Insight:
The highest individual payment value is 13,664.08.
Further investigation would identify the associated order
and explain the reason for this high-value payment.
*/

-- Business Question 6: Orders by status
SELECT order_status,COUNT(*)AS total_order
FROM olist.orders
GROUP BY order_status
ORDER BY total_order DESC;
/*
Business Insight:
Approximately 97% of orders are marked as delivered.
The remaining orders have other statuses, providing
an opportunity to investigate order completion performance.
*/

-- Business Question 7: Revenue by product category/ Top 10 Categories by sale.
SELECT COALESCE(
   ct.product_category_name_english,
   p.product_category_name, 'Unknown'
   )AS product_category, ROUND(SUM(oi.price)::numeric,2)AS total_sales
FROM olist.order_items oi
JOIN olist.products p
ON oi.product_id = p.product_id
LEFT JOIN olist.category_translation ct
ON p.product_category_name = ct.product_category_name
GROUP BY product_category
ORDER BY total_sales DESC
LIMIT 10;
/*
Business Insight:
Health & Beauty ranks first in item sales,
followed by Watches & Gifts and Bed, Bath & Table.
These categories are key contributors to sales value.
*/
-- Business Question 8: Order status distribution
SELECT order_status, COUNT(*)AS total_orders,
ROUND(COUNT(*) / SUM(COUNT(*))OVER() * 100 ,2)AS percentage_of_orders
FROM olist.orders
GROUP BY order_status
ORDER BY total_orders DESC;
/*
Business Insight:
97.02% of orders are marked as delivered.
Canceled orders account for 0.63%, while 0.61%
are unavailable.
*/

-- Business Question 9: Monthly sales perfomance
SELECT DATE_TRUNC(
  'month',o.order_purchase_timestamp)::date AS order_month,
  COUNT(DISTINCT o.order_id)AS total_orders,
  ROUND(SUM(oi.price)::numeric,2)AS total_sales,
  ROUND(SUM(oi.price) / count(DISTINCT o.order_id)::numeric,2)AS average_sales
FROM olist.orders o
JOIN olist.order_items oi
ON o.order_id = oi.order_id
GROUP BY order_month
ORDER BY order_month;

/*
Business Insight:
Monthly order volume and item sales increased substantially
during 2017, with November recording 7,451 orders and
1,010,271.37 in item sales. September 2018 appears incomplete,
so it should be treated cautiously in trend analysis.
*/

-- Business Question 10: Payment Method Analysis
SELECT
    payment_type,
    COUNT(*) AS total_payment_records,
    ROUND(SUM(payment_value)::numeric, 2) AS total_payment_value,
    ROUND(AVG(payment_value)::numeric, 2) AS average_payment_value
FROM olist.order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;
/*
Business Insight:
Credit cards contribute the highest payment value,
followed by Boleto. Voucher payments have the lowest
average payment value among defined payment methods.
*/

--Business Question 11 — Customer purchase behavior
WITH customers_orders AS (
 SELECT c.customer_unique_id,
 COUNT(DISTINCT order_id)AS total_orders
 FROM olist.customers c
 JOIN olist.orders o
 ON c.customer_id = o.customer_id
 GROUP BY c.customer_unique_id
)
 SELECT COUNT(*)AS total_unique_customers,
 COUNT(*)FILTER (WHERE total_orders = 1)AS one_time_customer,
 COUNT(*)FILTER (WHERE total_orders > 1)AS repeat_customer,
 ROUND(COUNT(*)FILTER (WHERE total_orders > 1) * 100 /  COUNT(*),2)
        AS repeat_customer_percentage
 FROM customers_orders;

/*
Business Insight:
Approximately 97% of unique customers placed only one order,
while 3% made repeat purchases. Improving customer retention
may help encourage more repeat purchases.
*/

-- Business Question 12: Top 10 customers by spending
WITH customer_spending AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(p.payment_value) AS total_spending
    FROM olist.customers c
    JOIN olist.orders o
        ON c.customer_id = o.customer_id
    JOIN olist.order_payments p
        ON o.order_id = p.order_id
    GROUP BY c.customer_unique_id
)
SELECT
    customer_unique_id,
    total_orders,
    ROUND(total_spending::numeric, 2) AS total_spending
FROM customer_spending
ORDER BY total_spending DESC
LIMIT 10;
/*
 The highest-spending customer contributed 13,664.08 in total payment
 value from one order, while the second-highest customer spent 9,553.02 across
 three orders. This suggests that high customer spending can come from either 
 a single high-value order or multiple purchases.
*/

--Business Question 13: Seller ranking and overall average comparison
WITH seller_performance AS(
  SELECT seller_id, COUNT(*)AS total_items,
   ROUND(SUM(price)::numeric,2)AS total_sales,
   ROUND(AVG(price)::numeric, 2) AS avg_item_price
  FROM olist.order_items 
  GROUP BY seller_id
),
ranked_sellers AS(
  SELECT seller_id,total_items,
    total_sales, avg_item_price,
    DENSE_RANK()OVER(ORDER BY total_sales DESC)
      AS sellers_rank,
    ROUND(AVG(total_sales)OVER()::numeric,2)AS overall_avg_sales
  FROM seller_performance
)
SELECT seller_id,total_sales,total_items,
      avg_item_price,overall_avg_sales,sellers_rank,
      ROUND((total_sales - overall_avg_sales)::numeric,2)AS sales_vs_average
FROM ranked_sellers
ORDER BY sellers_rank
LIMIT 10;

/*
Business Insight:
The top-ranked seller generated 229,472.63 in item sales
from 1,156 items, while the second seller generated
222,776.05 from only 410 items, with a higher average
item price of 543.36 versus 198.51. This indicates that
high seller revenue can result from either higher sales
volume or higher-priced items.
*/

-- Business Question 14: Review Scores by Order Status
SELECT o.order_status,
    COUNT(r.review_id)AS total_reviews,
	ROUND(AVG(r.review_score)::numeric,2)AS average_review_score
FROM olist.order_reviews r
JOIN olist.orders o
ON r.order_id = o.order_id
GROUP BY order_status
ORDER BY average_review_score DESC;
/*
Business Insight-Delivered orders have a strong average review score 
of 4.16 across 96,361 reviews. Orders in non-delivered statuses generally
have lower average scores, with processing orders scoring 1.28, suggesting 
that delays or unsuccessful order completion may be associated with customer
dissatisfaction.
*/

--Business Question 15: Delivery Performance
SELECT COUNT(*)AS total_orders,
    COUNT(*)FILTER(WHERE order_delivered_customer_date
    > order_estimated_delivery_date)AS late_orders,
    ROUND(COUNT(*)FILTER(WHERE order_delivered_customer_date
    > order_estimated_delivery_date) * 100 / COUNT(*)::numeric,2)
	         AS late_orders_percentage
FROM olist.orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_estimated_delivery_date IS NOT NULL;
/*
Business Insight- Approximately 8.11% of delivered orders
were delivered after their estimated delivery dates. This suggests
that most deliveries met the estimated date, but late deliveries 
remain an area for improvement.
*/

--Business Question 16: Average Delivery Time
SELECT ROUND(AVG(EXTRACT(EPOCH FROM(
    order_delivered_customer_date - order_purchase_timestamp
    )) / 86400)::numeric,2)
FROM olist.orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_purchase_timestamp IS NOT NULL;

/*
Business Insight:
The average delivery time is 12.56 days from purchase
to customer delivery. The business can use this metric
to monitor delivery efficiency and identify opportunities
to reduce delivery time.
*/

-- Business Question 17: Delivery Delays by Month
SELECT 
  DATE_TRUNC('month',order_purchase_timestamp)::date AS order_month,
  COUNT(*)AS total_orders_delivered,
  COUNT(*)FILTER(WHERE order_delivered_customer_date > 
    order_estimated_delivery_date)AS delayed_orders,
  ROUND(COUNT(*)FILTER(WHERE order_delivered_customer_date
  > order_estimated_delivery_date) * 100 / COUNT(*),2)
     AS late_orders_percentage
FROM olist.orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_estimated_delivery_date IS NOT NULL
GROUP BY order_month
ORDER BY order_month;
/*
Business Insight:
Delivery delays increased significantly in early 2018,
reaching 21% in March 2018 (1,496 delayed orders
out of 7,003 delivered orders).
November 2017 also showed a high delay rate of 14%,
indicating fluctuations in delivery performance.
*/

-- Business Question 18: Payment Method Analysis
SELECT payment_type,
   COUNT(*)AS total_payment_records,
   ROUND(SUM(payment_value),2)AS total_payments,
   ROUND(AVG(payment_value),2)AS average_payments
FROM olist.order_payments
GROUP BY payment_type
ORDER BY total_payments DESC;

/*
Business Insight:
Credit cards generate the highest total payment value
(12.54 million) and average payment value (163.32).
Boleto ranks second in total value, while vouchers
have the lowest average payment value among defined methods.
*/

-- Business Question 19: Top 3 Products Within Each Category
 WITH product_revenue AS(
   SELECT COALESCE(
      ct.product_category_name_english,
       p.product_category_name,
      'unknown'
      )AS product_category,oi.product_id,
	  ROUND(SUM(oi.price)::numeric,2)AS total_revenue
   FROM olist.order_items oi
   JOIN olist.products p
   ON oi.product_id = p.product_id
   JOIN olist.category_translation ct
   ON ct.product_category_name = p.product_category_name
   GROUP BY product_category,oi.product_id
 ),
 ranked_products AS(
   SELECT product_category, 
       product_id, total_revenue,
	   DENSE_RANK()OVER(PARTITION BY product_category 
	   ORDER BY total_revenue DESC)AS product_rank
   FROM product_revenue
	  )
SELECT product_category,product_id,
       total_revenue
FROM ranked_products
WHERE product_rank <= 3
ORDER BY product_category, total_revenue DESC;

/*
Business Insight:
Product revenue varies across products within each category.
Identifying the top 3 revenue-generating products per category
helps businesses prioritize popular products and optimize
inventory and category-level sales strategies.
*/

-- Business Question 20: Month-over-Month Revenue Growth and cumulative revenue
WITH monthly_revenue AS(
  SELECT DATE_TRUNC('month',order_purchase_timestamp)
                    AS order_month,
		ROUND(SUM(oi.price)::numeric,2)AS monthly_revenue
  FROM olist.orders o
  JOIN olist.order_items oi
  ON o.order_id = oi.order_id
  GROUP BY order_month
 ),
revenue_comparison AS(
   SELECT order_month,monthly_revenue,
        LAG(monthly_revenue)OVER(ORDER BY order_month)
		       AS previous_month_revenue,
	ROUND(SUM(monthly_revenue)OVER(ORDER BY order_month 
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2)
	       AS cumulative_revenue
   FROM monthly_revenue
) 
SELECT order_month, monthly_revenue,
       previous_month_revenue,
    ROUND(
	(monthly_revenue - previous_month_revenue) / 
	NULLIF(previous_month_revenue,0) * 100 ::numeric,2)
	 AS mom_growth_percentage,cumulative_revenue
FROM revenue_comparison
ORDER BY order_month;

/*
Business Insight:
Monthly revenue fluctuated considerably, with November 2017
showing strong growth of 52.10%, followed by a 26.36% decline
in December. Cumulative revenue helps track overall sales
performance over time.
*/

--Business Question 21: Customer spending Segmentation
WITH customer_spending AS(
  SELECT c.customer_unique_id,
     ROUND(SUM(p.payment_value)::numeric,2)AS total_spending
  FROM olist.customers c
  JOIN olist.orders o
  ON c.customer_id = o.customer_id
  JOIN olist.order_payments p
  ON o.order_id = p.order_id
  GROUP BY c.customer_unique_id
  ),
  customer_segments AS(
     SELECT customer_unique_id,total_spending,
     CASE
	  WHEN total_spending < 100 THEN 'low spending'
	  WHEN total_spending < 500 THEN 'medium spending'
	  ELSE 'high spending'
	  END AS spending_segment
   FROM customer_spending
	 )
SELECT spending_segment,
       COUNT(*)AS total_customers,
       ROUND(AVG(total_spending),2)AS customer_avg_spending,
	   ROUND(SUM(total_spending),2)AS segment_revenue
FROM customer_segments
GROUP BY spending_segment
ORDER BY CASE spending_segment
       WHEN 'low spending' THEN 1
       WHEN 'medium spending' THEN 2
       WHEN 'high spending' THEN 3
	 END;
  
/*
Business Insight:
Medium-spending customers contribute the highest segment
revenue (R$ 9.15 million). High-spending customers have the
highest average spending (R$ 929.95), making them valuable
for customer retention strategies.
*/ 
	   
--Business Question 22: Executive-Level Business Summary
WITH revenue_summary AS(
   SELECT ROUND(SUM(price),2)AS total_item_revenue,
         COUNT(DISTINCT order_id)AS orders_with_items
   FROM olist.order_items
  ),
customer_summary AS(
   SELECT 
     COUNT(DISTINCT customer_unique_id)AS total_customers
   FROM olist.customers c
   JOIN olist.orders o
   ON o.customer_id = c.customer_id
  ),
 product_summary AS(
    SELECT
	   COUNT(DISTINCT product_id)AS products_sold
	FROM olist.order_items
  ),
seller_summary AS(
    SELECT
        COUNT(DISTINCT seller_id) AS active_sellers
    FROM olist.order_items
  ),
delivery_summary AS(
    SELECT COUNT(DISTINCT order_id)AS delivered_orders_analyzed,
	  ROUND(AVG(EXTRACT(EPOCH FROM(
	  order_delivered_customer_date - order_purchase_timestamp))/86400)
	     ::numeric,2)AS avg_delivery_days,
	 ROUND(
    100.0 * COUNT(*) FILTER (
        WHERE order_delivered_customer_date
              > order_estimated_delivery_date
    ) / NULLIF(COUNT(*), 0),2
) AS late_delivery_percentage
    FROM olist.orders o
    WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
	AND order_estimated_delivery_date IS NOT NULL
	    )
SELECT 
   r.total_item_revenue,
    r.orders_with_items,
    c.total_customers,
    p.products_sold,
    s.active_sellers,
    d.delivered_orders_analyzed,
    d.avg_delivery_days,
    d.late_delivery_percentage
FROM revenue_summary r
CROSS JOIN customer_summary c
CROSS JOIN product_summary p
CROSS JOIN seller_summary s
CROSS JOIN delivery_summary d;

/*
Business Insight:
This executive summary combines item revenue, customer reach,
product and seller activity, and delivery performance.
It helps management assess sales performance and identify
opportunities to improve customer experience and operations.
*/



















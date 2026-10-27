--Validate the Relationship
-- Verify that every order is associated with a valid customer.
SELECT COUNT(*) AS orders_without_customers
FROM olist.orders o
LEFT JOIN olist.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

--Validation 2: Check order item relationship
--verify that every order item references an existing products and
--existing sellers.Result Count should be Zero.
 SELECT COUNT(*)AS items_without_products
 FROM olist.order_items oi
 LEFT JOIN olist.products p
 ON oi.product_id = p.product_id
 WHERE p.product_id IS NULL;

 SELECT COUNT(*)AS items_without_sellers
 FROM olist.order_items oi
 LEFT JOIN olist.sellers s
 ON oi.seller_id = s.seller_id
 WHERE s.seller_id IS NULL;

--validation 3: Identify orders that do not have a matching payment 
--records or matching review records.
--Note: An order may have multiple payment rows and no review rows
--A non-zero result may not automatically a data error.

SELECT COUNT(*)AS orders_without_payments
FROM olist.orders o
LEFT JOIN olist.order_payments p
    ON o.order_id = p.order_id
WHERE p.order_id IS NULL;

SELECT COUNT(*) AS orders_without_reviews
FROM olist.orders o
LEFT JOIN olist.order_reviews r
    ON o.order_id = r.order_id
WHERE r.order_id IS NULL;

--Validation 4: Check primary-key uniqueness
SELECT 'customers' AS table_name,
   COUNT(*) AS total_rows, COUNT(DISTINCT customer_id) AS unique_keys
   FROM olist.customers
UNION ALL
SELECT 'orders',
   COUNT(*), COUNT(DISTINCT order_id)
   FROM olist.orders
UNION ALL
SELECT 'products',
   COUNT(*), COUNT(DISTINCT product_id)
   FROM olist.products
UNION ALL
SELECT 'sellers',
   COUNT(*), COUNT(DISTINCT seller_id)
   FROM olist.sellers
UNION ALL
SELECT 'order_reviews',
   COUNT(*), COUNT(DISTINCT review_id)
FROM olist.order_reviews
ORDER BY table_name;

--Key finding: The first four tables have unique values in the selected
key columns. In order_reviews, there are 814 fewer distinct review_id
values than total rows, indicating repeated review IDs.

--Validation 5: Investigate Duplicate Review IDs
SELECT review_id,
COUNT(*) AS total_reviews, COUNT(DISTINCT order_id) AS distinct_orders
FROM olist.order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY total_reviews DESC,review_id
LIMIT 20;

--Finding:
The same review_id appears against multiple order_id values.
In the investigated example, one review_id is associated
with three different orders.

--Action:
Preserve the source records and investigate further
before deciding how to handle review_id uniqueness.

--Validation 6: check null values in orders
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE order_status IS NULL) AS null_order_status,
    COUNT(*) FILTER (WHERE order_purchase_timestamp IS NULL)
        AS null_purchase_timestamp,
    COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL)
        AS null_delivery_date
FROM olist.orders;

--Validation 7: Missing Delivery Dates by Order Status
SELECT order_status, COUNT(*) AS total_orders,
    COUNT(*) FILTER ( WHERE order_delivered_customer_date IS NULL
    ) AS missing_delivery_dates
FROM olist.orders
GROUP BY order_status
ORDER BY missing_delivery_dates DESC;

--Finding:
Most missing delivery dates occur in orders that are
not marked as delivered, which may be expected.

--Action:
Investigate these 8 records before deciding whether
they represent data-quality issues.

--Validation 8: Inspect the eight exceptions
SELECT order_id,order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM olist.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

--Validation 9 — Check duplicate order items
SELECT
    order_id, order_item_id,
    COUNT(*) AS duplicate_count
FROM olist.order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

--Finding:
No duplicate combinations of order_id and order_item_id
were found in the order_items table.

--Conclusion:
The composite key is unique across the imported records.

-- Validation 10: Check unusual price and freight values
SELECT
    COUNT(*) FILTER (WHERE price <= 0) AS invalid_price_rows,
    COUNT(*) FILTER (WHERE freight_value < 0) AS negative_freight_rows,
    COUNT(*) FILTER (WHERE freight_value = 0) AS zero_freight_rows
FROM olist.order_items;

--Finding:
Prices and freight values show no negative-value issues.
383 Zero freight values require no automatic correction because
they may be legitimate.

-- Validation 11: Check unusual payment values
SELECT COUNT(*) FILTER (WHERE payment_value <= 0)
           AS non_positive_payment_rows,
	  COUNT(*) FILTER (WHERE payment_value IS NULL)
	       AS null_payment_value,
	   COUNT(*)AS total_rows
FROM olist.order_payments;

--Finding:
Investigate the 9 non-positive payment records before
deciding whether any correction is required.











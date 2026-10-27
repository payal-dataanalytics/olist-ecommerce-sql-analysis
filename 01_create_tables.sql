-- After creating schema named 'olist' tables are formed.
 CREATE TABLE olist.customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);
CREATE TABLE olist.orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,

    CONSTRAINT fk_orders_customers
        FOREIGN KEY (customer_id)
        REFERENCES olist.customers(customer_id)
);
CREATE TABLE olist.products(
  product_id VARCHAR(50) PRIMARY KEY,
  product_category_name VARCHAR(100) NOT NULL,
  product_name_length INTEGER,
  product_description_length INTEGER,
  product_photos_qty INTEGER,
  product_weight_gm INTEGER,
  product_length_cm INTEGER,
  product_height_cm INTEGER,
  product_width_cm INTEGER
);
CREATE TABLE olist.sellers(
  seller_id VARCHAR(50) PRIMARY KEY,
  seller_zip_code_prefix INTEGER,
  seller_city VARCHAR(100),
  seller_state CHAR(2)
);
CREATE TABLE olist.order_items (
    order_id VARCHAR(50) NOT NULL,
    order_item_id INTEGER NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    seller_id VARCHAR(50) NOT NULL,
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2),

    CONSTRAINT pk_order_items
        PRIMARY KEY (order_id, order_item_id),

    CONSTRAINT fk_items_orders
        FOREIGN KEY (order_id)
        REFERENCES olist.orders(order_id),

    CONSTRAINT fk_items_products
        FOREIGN KEY (product_id)
        REFERENCES olist.products(product_id),

    CONSTRAINT fk_items_sellers
        FOREIGN KEY (seller_id)
        REFERENCES olist.sellers(seller_id)
);
CREATE TABLE olist.order_payments(
    order_id VARCHAR(50)NOT NULL,
	payment_sequential INTEGER NOT NULL,
	payment_type VARCHAR(30),
	payment_installments INTEGER,
	payment_value NUMERIC(10,2),

	CONSTRAINT pk_order_payments
        PRIMARY KEY (order_id, payment_sequential),

    CONSTRAINT fk_payments_orders
        FOREIGN KEY (order_id)
        REFERENCES olist.orders(order_id)
);
CREATE TABLE olist.order_reviews (
    review_id VARCHAR(50) NOT NULL,
    order_id VARCHAR(50) NOT NULL,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,

    CONSTRAINT pk_order_reviews
        PRIMARY KEY (review_id),

    CONSTRAINT fk_reviews_orders
        FOREIGN KEY (order_id)
        REFERENCES olist.orders(order_id),

    CONSTRAINT chk_review_score
        CHECK (review_score BETWEEN 1 AND 5)
);
CREATE TABLE olist.category_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100) NOT NULL
);

--After successful verify the table
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'olist'
ORDER BY table_name;

--Verify the import table
SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM olist.customers
UNION ALL
SELECT 'orders', COUNT(*) FROM olist.orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM olist.order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM olist.order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM olist.order_reviews
UNION ALL
SELECT 'products', COUNT(*) FROM olist.products
UNION ALL
SELECT 'sellers', COUNT(*) FROM olist.sellers
UNION ALL
SELECT 'category_translation', COUNT(*) FROM olist.category_translation
ORDER BY table_name;

--Validate the Relationship
-- Verify that every order is associated with a valid customer.
SELECT COUNT(*) AS orders_without_customers
FROM olist.orders o
LEFT JOIN olist.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
















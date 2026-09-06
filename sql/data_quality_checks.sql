--=======================================================
-- 1. ROW COUNT CHECKS
-- ======================================================
SELECT 
    'customers' AS table_name,
    COUNT(*) AS row_count,
    93582 AS expected_rows
FROM customers
UNION ALL

SELECT 
    'products',
    COUNT(*),
    32336
FROM products

UNION ALL

SELECT 
    'sellers',
    COUNT(*),
    3095
FROM sellers

UNION ALL

SELECT 
    'orders',
    COUNT(*),
    95088
FROM orders

UNION ALL

SELECT 
    'order_items',
    COUNT(*),
    112267
FROM order_items

UNION ALL

SELECT 
    'order_payments',
    COUNT(*),
    103848
FROM order_payments

UNION ALL

SELECT 
    'order_reviews',
    COUNT(*),
    102986
FROM order_reviews

UNION ALL

SELECT 
    'geolocations',
    COUNT(*),
    610158
FROM geolocations;
--=======================================================
-- 1. PRIMARY KEY CHECKS
-- ======================================================
SELECT
    'orders -> customers' AS relationship,
    COUNT(*) AS orphan_count
FROM orders
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM customers
    )

UNION ALL

SELECT
    'order_items -> orders',
    COUNT(*)
FROM order_items
WHERE order_id NOT IN (
    SELECT order_id
    FROM orders
)

UNION ALL

SELECT
    'order_items -> products',
    COUNT(*)
FROM order_items
WHERE product_id NOT IN (
    SELECT product_id
    FROM products
)

UNION ALL

SELECT
    'order_items -> sellers',
    COUNT(*)
FROM order_items
WHERE seller_id NOT IN (
    SELECT seller_id
    FROM sellers
)

UNION ALL

SELECT
    'order_payments -> order_id',
    COUNT(*)
FROM order_payments
WHERE order_id NOT IN (
    SELECT order_id
    FROM orders
)

UNION ALL

SELECT
    'order_reviews -> order_id',
    COUNT(*)
FROM order_reviews
WHERE order_id NOT IN (
    SELECT order_id
    FROM orders
);
--=======================================================
-- 2. NULL / Missing Values
-- ======================================================
SELECT 
    'customers' AS table,
    COUNT(*)
FROM customers
WHERE(
    customers.zip_code IS NULL OR
    customers.city IS NULL OR
    customers.state IS NULL
    )
UNION ALL

SELECT
    'products',
    COUNT(*)
FROM products
WHERE (
    products.name_length IS NULL OR
    products.description_length IS NULL OR
    products.photo_quantity IS NULL OR
    products.weight_g IS NULL OR 
    products.length_cm IS NULL OR
    products.heigth_cm IS NULL OR
    products.width_cm IS NULL
)

UNION ALL

SELECT
    'sellers',
    COUNT(*)
FROM sellers
WHERE (
    sellers.zip_code IS NULL OR
    sellers.city IS NULL OR
    sellers.state IS NULL
    )

UNION ALL

SELECT
    'orders',
    COUNT(*)
FROM orders
WHERE (
    orders.purchase_time IS NULL
)

UNION ALL

SELECT
    'order_items',
    COUNT(*)
FROM order_items
WHERE (
    order_items.shipping_limit IS NULL OR
    order_items.price IS NULL OR
    order_items.freight_value IS NULL
)

UNION ALL

SELECT
    'order_payments',
    COUNT(*)
FROM order_payments
WHERE (
    order_payments.payment_value IS NULL
)

UNION ALL

SELECT
    'order_reviews',
    COUNT(*)
FROM order_reviews
WHERE (
    order_reviews.review_score IS NULL OR
    order_reviews.creation_timestamp IS NULL
)

UNION ALL

SELECT
    'geolocations',
    COUNT(*)
FROM geolocations
WHERE (
    geolocations.city IS NULL OR 
    geolocations.state IS NULL
)





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


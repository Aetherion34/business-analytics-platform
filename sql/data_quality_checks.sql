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
-- 2. PRIMARY KEY CHECKS
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
-- 3. NULL / Missing Values
-- ======================================================
SELECT 
    'customers' AS table,
    COUNT(*) AS Missing_values
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
);
--=======================================================
--4. Range / Invalid Values
-- ======================================================
SELECT 
    'products' AS table,
    COUNT(*) AS Invalid_values
FROM products
WHERE (
    products.name_length < 0 OR
    products.description_length < 0 OR
    products.photo_quantity < 0
)

UNION ALL

SELECT
    'orders',
    COUNT(*)
FROM orders
WHERE (
    orders.purchase_time < orders.approval_time OR
    orders.approval_time < orders.carrier_delivery_time OR
    orders.carrier_delivery_time < orders.order_delivery_time OR
    orders.order_delivery_time < orders.estimated_delivery_time
)

UNION ALL

SELECT
    'order_reviews',
    COUNT(*)
FROM order_reviews  
WHERE (
    order_reviews.creation_timestamp < order_reviews.answer_timestamp
)

UNION ALL

SELECT
    'geolocations',
    COUNT(*)
FROM geolocations  
WHERE (
    geolocations.latitude NOT BETWEEN -90 AND 90 OR
    geolocations.longitude NOT BETWEEN -180 AND 180 
);
--=======================================================
-- 5. Categorical Values 
-- ======================================================
WITH valid_states(state) AS (

    VALUES 
        ('AC'), ('AL'), ('AP'), ('AM'), ('BA'), ('CE'), ('DF'),
        ('ES'), ('GO'), ('MA'), ('MT'), ('MS'), ('MG'), ('PA'),
        ('PB'), ('PR'), ('PE'), ('PI'), ('RJ'), ('RN'), ('RS'),
        ('RO'), ('RR'), ('SC'), ('SP'), ('SE'), ('TO')

),

valid_status(status) AS (

    VALUES 
        ('created'), ('approved'), ('processing'), ('shipped'),
        ('delivered'), ('canceled'), ('unavailable'), ('invoiced')

),

valid_payment_types(payment_type) AS (

    VALUES 
        ('credit_card'), ('boleto'), ('voucher'),
        ('debit_card'), ('not_defined')

)

SELECT
    'customers' AS table_name,
    COUNT(*) AS invalid_category
FROM customers
WHERE customers.state NOT IN (
    SELECT state
    FROM valid_states
)

UNION ALL

SELECT
    'sellers',
    COUNT(*)
FROM sellers
WHERE sellers.state NOT IN (
    SELECT state
    FROM valid_states
)

UNION ALL

SELECT
    'orders',
    COUNT(*)
FROM orders
WHERE orders.order_status NOT IN (
    SELECT status
    FROM valid_status
)

UNION ALL

SELECT
    'order_payments',
    COUNT(*)
FROM order_payments
WHERE order_payments.payment_type NOT IN (
    SELECT payment_type
    FROM valid_payment_types
)

UNION ALL

SELECT
    'geolocations',
    COUNT(*)
FROM geolocations
WHERE geolocations.state NOT IN (
    SELECT state
    FROM valid_states
);
--=======================================================
-- 6. Business Rules Checks
-- ======================================================
SELECT 
    'order_without_items' AS table,
    COUNT(*)
FROM orders
WHERE (
    orders.order_id NOT IN (
        SELECT order_id
        FROM order_items
    )
)

UNION ALL

SELECT 
    'order_without_payments',
    COUNT(*)
FROM orders
WHERE (
    orders.order_id NOT IN (
        SELECT order_id
        FROM order_payments
    )
)

UNION ALL

SELECT 
    'delivered_without_delivery_date',
    COUNT(*)
FROM orders
WHERE (
    orders.order_status = 'delivered' AND
    orders.order_delivery_time IS NULL
)

UNION ALL
SELECT
    'payment consistency',
    COUNT(*)
FROM (
    SELECT  
        order_totals.order_id AS ID,
        order_totals.order_total AS expected_client_total_payment,
        payment_totals.total_payments AS client_total_payment
    FROM (
        SELECT
            order_items.order_id AS order_id,
            sum(order_items.price + order_items.freight_value) AS order_total
        FROM order_items
        GROUP BY order_id
    ) AS order_totals
    JOIN (
        SELECT
            order_payments.order_id AS order_id,
            sum(order_payments.payment_value) AS total_payments
        FROM order_payments
        GROUP BY order_id
    )AS payment_totals
    ON order_totals.order_id = payment_totals.order_id
)
AS payments_confrontation
WHERE ABS(
    payments_confrontation.expected_client_total_payment - payments_confrontation.client_total_payment
) > 0.01;
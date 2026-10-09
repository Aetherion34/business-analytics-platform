-- =======================================================
-- 1. ROW COUNT CHECKS
-- =======================================================

WITH expected_order_seller AS (
    SELECT
        COUNT(DISTINCT (oi.order_id, oi.seller_id)) AS expected_rows
    FROM order_items oi
),

expected_order_analytics AS (
    SELECT
        COUNT(DISTINCT oi.order_id) AS expected_rows
    FROM order_items oi
),

expected_delivery_analytics AS (
    SELECT
        COUNT(DISTINCT oi.order_id) AS expected_rows
    FROM order_items oi
),

expected_seller_analytics AS (
    SELECT
        COUNT(DISTINCT oi.seller_id) AS expected_rows
    FROM order_items oi
),

expected_category_analytics AS (
    SELECT
        COUNT(DISTINCT p.category) AS expected_rows
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
),

expected_canceled_order_analytics AS (
    SELECT
        COUNT(DISTINCT o.order_id) AS expected_rows
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'canceled'
),

expected_customer_analytics AS (
    SELECT
        COUNT(*) AS expected_rows
    FROM customers
),

expected_product_analytics AS (
    SELECT
        COUNT(*) AS expected_rows
    FROM products
),

expected_review_analytics AS (
    SELECT
        COUNT(*) AS expected_rows
    FROM (
        SELECT DISTINCT
            oi.order_id,
            oi.seller_id,
            r.review_id
        FROM order_items oi
        LEFT JOIN order_reviews r
            ON oi.order_id = r.order_id
    ) AS review_pairs
),

expected_payment_analytics AS (
    SELECT
        COUNT(*) AS expected_rows
    FROM (
        SELECT
            op.order_id AS order_id
        FROM order_payments op
        JOIN (
            SELECT
                oi.order_id AS order_id
            FROM order_items oi
            GROUP BY oi.order_id
        ) sq
            ON op.order_id = sq.order_id
    ) correct_rows
)

SELECT
    'order_seller_analytics' AS table_name,
    eos.expected_rows,
    (SELECT COUNT(*) FROM order_seller_analytics) AS actual_rows,
    eos.expected_rows
        - (SELECT COUNT(*) FROM order_seller_analytics) AS difference,
    CASE
        WHEN eos.expected_rows =
            (SELECT COUNT(*) FROM order_seller_analytics)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status
FROM expected_order_seller eos

UNION ALL

SELECT
    'order_analytics' AS table_name,
    eoa.expected_rows,
    (SELECT COUNT(*) FROM order_analytics) AS actual_rows,
    eoa.expected_rows
        - (SELECT COUNT(*) FROM order_analytics) AS difference,
    CASE
        WHEN eoa.expected_rows =
            (SELECT COUNT(*) FROM order_analytics)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status
FROM expected_order_analytics eoa

UNION ALL

SELECT
    'delivery_analytics' AS table_name,
    eda.expected_rows,
    (SELECT COUNT(*) FROM delivery_analytics) AS actual_rows,
    eda.expected_rows
        - (SELECT COUNT(*) FROM delivery_analytics) AS difference,
    CASE
        WHEN eda.expected_rows =
            (SELECT COUNT(*) FROM delivery_analytics)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status
FROM expected_delivery_analytics eda

UNION ALL

SELECT
    'seller_analytics' AS table_name,
    esa.expected_rows,
    (SELECT COUNT(*) FROM seller_analytics) AS actual_rows,
    esa.expected_rows
        - (SELECT COUNT(*) FROM seller_analytics) AS difference,
    CASE
        WHEN esa.expected_rows =
            (SELECT COUNT(*) FROM seller_analytics)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status
FROM expected_seller_analytics esa

UNION ALL

SELECT
    'category_analytics' AS table_name,
    eca.expected_rows,
    (SELECT COUNT(*) FROM category_analytics) AS actual_rows,
    eca.expected_rows
        - (SELECT COUNT(*) FROM category_analytics) AS difference,
    CASE
        WHEN eca.expected_rows =
            (SELECT COUNT(*) FROM category_analytics)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status
FROM expected_category_analytics eca

UNION ALL

SELECT
    'canceled_order_analytics' AS table_name,
    ecoa.expected_rows,
    (SELECT COUNT(*) FROM canceled_order_analytics) AS actual_rows,
    ecoa.expected_rows
        - (SELECT COUNT(*) FROM canceled_order_analytics) AS difference,
    CASE
        WHEN ecoa.expected_rows =
            (SELECT COUNT(*) FROM canceled_order_analytics)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status
FROM expected_canceled_order_analytics ecoa

UNION ALL

SELECT
    'customer_analytics' AS table_name,
    ecu.expected_rows,
    (SELECT COUNT(*) FROM customer_analytics) AS actual_rows,
    ecu.expected_rows
        - (SELECT COUNT(*) FROM customer_analytics) AS difference,
    CASE
        WHEN ecu.expected_rows =
            (SELECT COUNT(*) FROM customer_analytics)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status
FROM expected_customer_analytics ecu

UNION ALL

SELECT
    'product_analytics' AS table_name,
    epa.expected_rows,
    (SELECT COUNT(*) FROM product_analytics) AS actual_rows,
    epa.expected_rows
        - (SELECT COUNT(*) FROM product_analytics) AS difference,
    CASE
        WHEN epa.expected_rows =
            (SELECT COUNT(*) FROM product_analytics)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status
FROM expected_product_analytics epa

UNION ALL

SELECT
    'review_analytics' AS table_name,
    era.expected_rows,
    (SELECT COUNT(*) FROM review_analytics) AS actual_rows,
    era.expected_rows
        - (SELECT COUNT(*) FROM review_analytics) AS difference,
    CASE
        WHEN era.expected_rows =
            (SELECT COUNT(*) FROM review_analytics)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status
FROM expected_review_analytics era

UNION ALL

SELECT
    'payment_analytics' AS table_name,
    epma.expected_rows,
    (SELECT COUNT(*) FROM payment_analytics) AS actual_rows,
    epma.expected_rows
        - (SELECT COUNT(*) FROM payment_analytics) AS difference,
    CASE
        WHEN epma.expected_rows =
            (SELECT COUNT(*) FROM payment_analytics)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status
FROM expected_payment_analytics epma;

-- =======================================================
-- 3. NULLs
-- =======================================================

SELECT
    'order_seller_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM order_seller_analytics osa
WHERE
    osa.order_id IS NULL OR
    osa.seller_id IS NULL OR
    osa.seller_order_value IS NULL

UNION ALL

SELECT
    'order_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM order_analytics oa
WHERE
    oa.order_id IS NULL OR
    oa.order_status IS NULL OR
    oa.order_value IS NULL OR
    oa.purchase_time IS NULL OR
    oa.customer_state IS NULL OR
    oa.item_counts IS NULL

UNION ALL

SELECT
    'delivery_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM delivery_analytics da
WHERE
    da.order_id IS NULL OR
    da.customer_id IS NULL OR
    da.purchase_time IS NULL OR
    da.customer_state IS NULL OR
    da.order_weight IS NULL OR
    da.order_status IS NULL

UNION ALL

SELECT
    'seller_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM seller_analytics sa
WHERE
    sa.seller_id IS NULL OR
    sa.seller_state IS NULL

UNION ALL

SELECT
    'category_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM category_analytics ca
WHERE
    ca.category_name IS NULL

UNION ALL

SELECT
    'canceled_order_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM canceled_order_analytics coa
WHERE
    coa.order_id IS NULL OR
    coa.purchase_time IS NULL OR
    coa.customer_state IS NULL

UNION ALL

SELECT
    'customer_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM customer_analytics cua
WHERE
    cua.customer_id IS NULL

UNION ALL

SELECT
    'product_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM product_analytics pa
WHERE
    pa.product_id IS NULL OR
    pa.product_weight_kg IS NULL

UNION ALL

SELECT
    'review_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM review_analytics ra
WHERE
    ra.order_id IS NULL OR
    ra.customer_id IS NULL OR
    ra.seller_id IS NULL OR
    ra.purchase_time IS NULL

UNION ALL

SELECT
    'payment_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM payment_analytics pma
WHERE
    pma.order_id IS NULL OR
    pma.payment_method IS NULL OR
    pma.payment_sequential IS NULL OR
    pma.installment_count IS NULL OR
    pma.average_installment_value IS NULL;
-- =======================================================
-- 4. Range / Domain Checks
-- =======================================================
SELECT
    



-- =======================================================
-- 5. Temporal Consistency
-- =======================================================


-- =======================================================
-- 6. Referential Integrity
-- =======================================================

-- =======================================================
-- 7. Cross-Table Consistency
-- =======================================================

-- =======================================================
-- 8. Aggregation Consistency
-- =======================================================

-- =======================================================
-- 9. Business Logic Checks
-- =======================================================

-- =======================================================
-- 10. Entity Coverage / Completeness
-- =======================================================

-- =======================================================
-- 11. Final DQ Summary
-- =======================================================
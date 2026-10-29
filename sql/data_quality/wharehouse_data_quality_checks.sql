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
FROM order_analytics coa
WHERE
    oa.order_id IS NULL OR
    oa.order_status IS NULL OR
    oa.order_value IS NULL OR
    oa.purchase_time IS NULL OR
    o
    OR coa.order_value < 0
    
UNION ALL

a.customer_state IS NULL OR
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
    'order_seller_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM order_seller_analytics osa
WHERE
    NOT EXISTS (
        SELECT 1
        FROM dq.valid_states sbq
        WHERE osa.seller_state = sbq.state
    )
    OR osa.seller_order_value < 0
    OR osa.distance_km < 0

UNION ALL

SELECT
    'order_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM order_analytics oa
WHERE
    NOT EXISTS (
        SELECT 1
        FROM dq.valid_order_statuses sbq
        WHERE oa.order_status = sbq.order_status
    )
    OR oa.order_value < 0
    OR oa.purchase_time < TIMESTAMP '2016-09-04 21:15:19'
    OR oa.purchase_time > TIMESTAMP '2018-08-29 15:00:37'
    OR NOT EXISTS (
        SELECT 1
        FROM dq.valid_states sbq2
        WHERE oa.customer_state = sbq2.state
    )
    OR oa.item_counts < 0
    OR oa.average_distance_km < 0

UNION ALL

SELECT
    'delivery_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM delivery_analytics da
WHERE
    NOT EXISTS (
        SELECT 1
        FROM dq.valid_states sbq
        WHERE da.customer_state = sbq.state
    )
    OR da.order_weight < 0
    OR da.delivery_days = 0
    OR NOT EXISTS (
        SELECT 1
        FROM dq.valid_order_statuses sbq2
        WHERE da.order_status = sbq2.order_status
    )

UNION ALL

SELECT
    'seller_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM seller_analytics sa
WHERE
    sa.total_orders < 0
    OR sa.canceled_orders < 0
    OR sa.total_sales_value < 0
    OR sa.total_items_sold < 0
    OR sa.average_review_score < 0
    OR sa.average_review_score > 5

UNION ALL

SELECT
    'category_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM category_analytics ca
WHERE
    ca.total_category_value < 0
    OR ca.total_category_units_sold < 0

UNION ALL

SELECT
    'canceled_order_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM canceled_order_analytics coa
WHERE
    coa.purchase_time < TIMESTAMP '2016-09-04 21:15:19'
    OR coa.purchase_time > TIMESTAMP '2018-08-29 15:00:37'
    OR NOT EXISTS (
        SELECT 1
        FROM dq.valid_states sbq
        WHERE coa.customer_state = sbq.state
    )
    OR coa.order_value < 0

UNION ALL

SELECT
    'customer_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM customer_analytics ca
WHERE
    ca.total_orders < 0
    OR ca.total_spending < 0
    OR ca.total_items_purchased < 0
    OR ca.last_purchase_time < TIMESTAMP '2016-09-04 21:15:19'
    OR ca.last_purchase_time > TIMESTAMP '2018-08-29 15:00:37'
    OR ca.average_days_between_orders < 0

UNION ALL

SELECT
    'product_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM product_analytics pa
WHERE
    pa.total_units_sold < 0
    OR pa.total_sales_value < 0
    OR pa.average_price < 0
    OR pa.average_review_score < 0
    OR pa.average_review_score > 5
    OR pa.product_weight_kg < 0

UNION ALL

SELECT
    'review_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM review_analytics ra
WHERE
    ra.review_score < 1
    OR ra.review_score > 5
    OR NOT EXISTS (
        SELECT 1
        FROM dq.valid_states sbq
        WHERE ra.customer_state = sbq.state
    )
    OR ra.purchase_time < TIMESTAMP '2016-09-04 21:15:19'
    OR ra.purchase_time > TIMESTAMP '2018-08-29 15:00:37'

UNION ALL

SELECT
    'payment_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM payment_analytics pa
WHERE
    NOT EXISTS (
        SELECT 1
        FROM dq.valid_payment_methods sbq
        WHERE pa.payment_method = sbq.payment_method
    )
    OR pa.payment_sequential < 1
    OR pa.installment_count < 1
    OR pa.average_installment_value < 0;

-- =======================================================
-- 5. Temporal Consistency
-- =======================================================
SELECT
    'delivery_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM delivery_analytics da
WHERE 
    da.estimated_delivery_time >= da.purchase_time
    OR da.delivery_time >= da.purchase_time

-- =======================================================
-- 6. Referential Integrity
-- =======================================================
SELECT
    'order_seller_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM order_seller_analytics osa
WHERE 
    NOT EXISTS(
        SELECT 1
        FROM orders o
        WHERE o.order_id = osa.order_id
    )
    OR NOT EXISTS(
        SELECT 1
        FROM sellers s
        WHERE s.seller_id = osa.seller_id
    )

UNION ALL

SELECT
    'order_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM order_analytics oa
WHERE 
    NOT EXISTS(
        SELECT 1
        FROM orders o
        WHERE o.order_id = oa.order_id
    )

UNION ALL

SELECT
    'delivery_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM delivery_analytics da
WHERE
    NOT EXISTS(
        SELECT 1
        FROM orders o
        WHERE o.order_id = da.order_id
    )
    OR NOT EXISTS(
        SELECT 1
        FROM orders o
        WHERE o.customer_id = da.customer_id
    )

UNION ALL

SELECT
    'seller_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM seller_analytics sa
WHERE
    NOT EXISTS(
        SELECT 1
        FROM sellers s
        WHERE s.seller_id = sa.seller_id
    )

UNION ALL

SELECT
    'canceled_order_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM canceled_order_analytics coa
WHERE
    NOT EXISTS(
        SELECT 1
        FROM orders o
        WHERE o.order_id = coa.order_id
    )

UNION ALL

SELECT
    'customer_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM customer_analytics ca
WHERE
    NOT EXISTS(
        SELECT 1
        FROM customers c
        WHERE c.customer_id = ca.customer_id
    )

UNION ALL

SELECT
    'product_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM product_analytics pa
WHERE
    NOT EXISTS(
        SELECT 1
        FROM products p
        WHERE p.product_id = pa.product_id
    )

UNION ALL

SELECT
    'review_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM review_analytics ra
WHERE
    NOT EXISTS (
        SELECT 1
        FROM orders o
        WHERE o.order_id = ra.order_id
    )

    OR NOT EXISTS (
        SELECT 1
        FROM orders o
        WHERE o.order_id = ra.order_id
        AND o.customer_id = ra.customer_id
    )

    OR NOT EXISTS (
        SELECT 1
        FROM order_items oi
        WHERE oi.order_id = ra.order_id
        AND oi.seller_id = ra.seller_id
    )OR (
        ra.review_id IS NOT NULL
        AND NOT EXISTS (
            SELECT 1
            FROM order_reviews ow
            WHERE ow.review_id = ra.review_id
        )
    )

UNION ALL

SELECT
    'payment_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM payment_analytics pa
WHERE
    NOT EXISTS(
        SELECT 1
        FROM orders o
        WHERE o.order_id = pa.order_id
    );


-- =======================================================
-- 8. Aggregation Consistency
-- =======================================================
WITH order_seller_cte AS (
    SELECT
        oi.order_id AS order_id,
        oi.seller_id AS seller_id,
        SUM(oi.price) AS seller_value
    FROM order_items oi
    GROUP BY oi.seller_id, oi.order_id
)
SELECT
    'order_seller_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM order_seller_analytics osa
JOIN order_seller_cte oscte
    ON oscte.order_id = osa.order_id
    AND oscte.seller_id = osa.seller_id
WHERE 
    osa.seller_order_value <> oscte.seller_value

UNION ALL

WITH order_cte AS (
    SELECT
        oi.order_id AS order_id,
        SUM(oi.price) AS order_total_value,
        COUNT(oi.order_id) AS items
    FROM order_items oi
    GROUP BY oi.order_id

),
order_distances AS (
    SELECT
        osa.order_id AS order_id,
        AVG(osa.distance_km) AS avg_distance
    FROM order_seller_analytics osa
    GROUP BY osa.order_id
)
SELECT
    'order_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM order_analytics oa
JOIN order_cte octe
ON octe.order_id = oa.order_id
JOIN order_distances odistance
ON odistance.order_id = oa.order_id
WHERE
    octe.order_total_value <> oa.order_value
    OR octe.items <> oa.item_counts
    OR odistance.avg_distance <> oa.average_distance_km

UNION ALL


WITH sellers_cte AS (
    SELECT
        COUNT(DISTINCT oi.order_id) AS total_orders,
        COUNT(DISTINCT oi.order_id
            CASE WHEN o.order_status = 'canceled'
            THEN oi.order_id
            END) AS canceled_status,
        SUM(oi.price) AS seller_revenue,
        COUNT(oi.order_id) AS item_counts
    FROM order_items oi
    JOIN orders o
    ON o.order_id = oi.order_id
    GROUP BY oi.seller_id
),

WITH sellers_avg_reviews AS (
    SELECT
        sbq.seller_id AS seller_id,
        AVG(sbq.average_review) AS average_seller_review
    FROM (
        SELECT  
            oi.order_id,
            AVG(ow.review_score) AS average_review,
            oi.seller_id
        FROM order_items oi
        LEFT JOIN order_reviews ow
        ON oi.order_id = ow.order_id
        GROUP BY
            oi.order_id,
            oi.seller_id

    ) sbq
    GROUP BY sbq.seller_id

)
SELECT
    'seller_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM seller_analytics sa
JOIN sellers_cte cte1
ON cte1.seller_id = sa.seller_id

JOIN sellers_avg_reviews cte2
ON cte2.seller_id = sa.seller_id
WHERE
    sa.total_orders <> cte1.total_orders,       
    sa.canceled_orders <> cte1.canceled_status,     
    sa.total_sales_value <> cte1.seller_revenue,   
    sa.total_items_sold <> cte1.item_counts,    
    sa.average_review_score <> cte2.average_seller_review

UNION ALL

WITH category_cte AS(
    SELECT
    p.category AS category_name,
    SUM(oi.price) AS total_category_value,
    COUNT(oi.order_id) AS total_category_units_sold
    FROM order_items oi
)

SELECT
    'category_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM category_analytics ca
JOIN category_cte cte1
ON cte.category_name = ca.category_name
WHERE 
    cte1.category_name <> ca.category_name,                   
    cte1.total_category_value <> ca.total_category_value,         
    cte1.total_category_units_sold <> ca.total_category_units_sold

UNION ALL

WITH customers_cte AS (
    SELECT
        o.customer_id AS customer_id,
        SUM(oi.price) AS total_spending,
        COUNT(DISTINCT oi.order_id) total_orders,
        COUNT(oi.order_id) total_items_purchased,
    FROM order_items oi
    JOIN orders o
    ON o.order_id = oi.order_id
    GROUP BY o.customer_id
),
order_history_cte AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.purchase_time,
        LAG(o.purchase_time, 1)
        OVER(PARTITION BY o.customer_id ORDER BY o.purchase_time ASC) AS prev_purchase_time
    FROM orders o

)
SELECT
    'customer_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM customer_analytics cua
JOIN customers_cte cte1
ON cua.customer_id = cte1.customer_id
JOIN order_history_cte cte2
ON cua.customer_id = cte2.customer_id
WHERE
    cua.customer_id <> cte1.customer_id           
    cua.total_orders <> cte1.total_orders          
    cua.total_spending <> cte1.total_spending        
    cua.total_items_purchased <> cte1.total_items_purchased
    cua.average_days_between_orders <> ROUND(
        COALESCE(
            AVG(
                EXTRACT(
                    EPOCH FROM (
                        cte2.purchase_time:: timestamp - cte2.previous_purchase_time:: timestamp
                    )
                ) / 86400
            ),
            0
        )::NUMERIC,
        1
    )

UNION ALL

WITH average_review_cte AS (  
    SELECT
        orw.order_id AS order_id,
        AVG(orw.review_score) AS review_score
    FROM order_reviews orw
    GROUP BY
        orw.order_id
),
product_cte AS (
    SELECT
        p.product_id,
        COUNT(oi.order_id) AS total_units_sold
        SUM(oi.price) AS total_sales_value
        AVG(oi.price) AS average_price    
        AVG(cte1.review_score) AS average_review_score
    FROM products p
    JOIN average_review_cte cte1
    ON oi.order_id = cte1.order_id
)

SELECT
    'product_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM product_analytics pa
JOIN product_cte ct1
ON cte1.product_id = pa.product_id
WHERE
    cte1.total_units_sold <> pa.total_units_sold 
    cte1.total_sales_value <> pa.total_sales_value
    cte1.average_price <> pa.average_price    
    cte1.average_review_score <> pa.average_review_score

UNION ALL

WITH payment_cte AS (
    SELECT
        oi.order_id AS order_id,
        SUM(oi.price) AS order_value
    FROM order_items oi
    GROUP BY
        oi.order_id
)

SELECT
    'payment_analytics' AS table_name,
    COUNT(*) AS invalid_rows
FROM payment_analytics pmna
JOIN payment_cte cte1
ON cte1.order_id = pmna.order_id
WHERE 
    pmna.average_installment_value <> ROUND(
        (
            cte1.order_value /
            NULLIF(pmna.payment_installments, 0)
        )::NUMERIC,
        2
    );

-- =======================================================
-- 9. Business Logic Checks
-- =======================================================

-- =======================================================
-- 10. Entity Coverage / Completeness
-- =======================================================

-- =======================================================
-- 11. Final DQ Summary
-- =======================================================
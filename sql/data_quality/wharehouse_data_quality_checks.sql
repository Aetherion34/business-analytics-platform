-- =======================================================
-- DATA QUALITY VALIDATION
-- PostgreSQL
--
-- Every check is stored in the temporary dq_results table.
-- invalid_rows = number of records that violate the check.
-- For row-count checks, invalid_rows = ABS(expected_rows - actual_rows).
-- Duplicate checks count excess duplicate records (n - 1 per duplicated key).
--
-- IMPORTANT:
-- - Uses the user's renamed source columns in orders:
--   purchase_time, approval_time, carrier_delivery_time,
--   order_delivery_time, estimated_delivery_time.
-- - payment_analytics grain: one row per order_id + payment_sequential.
-- - average_installment_value = order item value / payment installments.
-- =======================================================

DROP TABLE IF EXISTS pg_temp.dq_results;

CREATE TEMP TABLE dq_results (
    section_name TEXT NOT NULL,
    check_name TEXT NOT NULL,
    invalid_rows BIGINT NOT NULL,
    check_status TEXT NOT NULL DEFAULT 'PENDING'
) ON COMMIT PRESERVE ROWS;


-- =======================================================
-- 1. ROW COUNT CHECKS
-- =======================================================

WITH expected_counts AS (
    SELECT
        'order_seller_analytics_row_count' AS check_name,
        COUNT(*)::BIGINT AS expected_rows
    FROM (
        SELECT DISTINCT order_id, seller_id
        FROM order_items
    ) x

    UNION ALL

    SELECT
        'order_analytics_row_count',
        COUNT(DISTINCT order_id)::BIGINT
    FROM order_items

    UNION ALL

    SELECT
        'delivery_analytics_row_count',
        COUNT(DISTINCT order_id)::BIGINT
    FROM order_items

    UNION ALL

    SELECT
        'seller_analytics_row_count',
        COUNT(DISTINCT seller_id)::BIGINT
    FROM order_items

    UNION ALL

    SELECT
        'category_analytics_row_count',
        COUNT(DISTINCT p.category)::BIGINT
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id

    UNION ALL

    SELECT
        'canceled_order_analytics_row_count',
        COUNT(DISTINCT o.order_id)::BIGINT
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'canceled'

    UNION ALL

    SELECT
        'customer_analytics_row_count',
        COUNT(*)::BIGINT
    FROM customers

    UNION ALL

    SELECT
        'product_analytics_row_count',
        COUNT(*)::BIGINT
    FROM products

    UNION ALL

    SELECT
        'review_analytics_row_count',
        COUNT(*)::BIGINT
    FROM (
        SELECT DISTINCT oi.order_id, oi.seller_id, r.review_id
        FROM order_items oi
        LEFT JOIN order_reviews r ON r.order_id = oi.order_id
    ) review_pairs

    UNION ALL

    SELECT
        'payment_analytics_row_count',
        COUNT(*)::BIGINT
    FROM order_payments op
    WHERE EXISTS (
        SELECT 1
        FROM order_items oi
        WHERE oi.order_id = op.order_id
    )
),
actual_counts AS (
    SELECT 'order_seller_analytics_row_count' AS check_name,
           COUNT(*)::BIGINT AS actual_rows
    FROM order_seller_analytics

    UNION ALL
    SELECT 'order_analytics_row_count', COUNT(*)::BIGINT
    FROM order_analytics

    UNION ALL
    SELECT 'delivery_analytics_row_count', COUNT(*)::BIGINT
    FROM delivery_analytics

    UNION ALL
    SELECT 'seller_analytics_row_count', COUNT(*)::BIGINT
    FROM seller_analytics

    UNION ALL
    SELECT 'category_analytics_row_count', COUNT(*)::BIGINT
    FROM category_analytics

    UNION ALL
    SELECT 'canceled_order_analytics_row_count', COUNT(*)::BIGINT
    FROM canceled_order_analytics

    UNION ALL
    SELECT 'customer_analytics_row_count', COUNT(*)::BIGINT
    FROM customer_analytics

    UNION ALL
    SELECT 'product_analytics_row_count', COUNT(*)::BIGINT
    FROM product_analytics

    UNION ALL
    SELECT 'review_analytics_row_count', COUNT(*)::BIGINT
    FROM review_analytics

    UNION ALL
    SELECT 'payment_analytics_row_count', COUNT(*)::BIGINT
    FROM payment_analytics
)
INSERT INTO dq_results (section_name, check_name, invalid_rows, check_status)
SELECT
    'Row Count Checks',
    e.check_name,
    ABS(e.expected_rows - a.actual_rows),
    CASE
        WHEN e.expected_rows = a.actual_rows THEN 'PASS'
        ELSE 'FAIL'
    END
FROM expected_counts e
JOIN actual_counts a USING (check_name);


-- =======================================================
-- 2. DUPLICATE CHECKS
-- invalid_rows counts duplicate rows beyond the first row
-- for each key, rather than counting duplicate key groups.
-- =======================================================

INSERT INTO dq_results (section_name, check_name, invalid_rows)
SELECT 'Duplicate Checks', 'order_seller_analytics_duplicate_key',
       COALESCE(SUM(n - 1), 0)::BIGINT
FROM (
    SELECT COUNT(*) AS n
    FROM order_seller_analytics
    GROUP BY order_id, seller_id
    HAVING COUNT(*) > 1
) x

UNION ALL
SELECT 'Duplicate Checks', 'order_analytics_duplicate_key',
       COALESCE(SUM(n - 1), 0)::BIGINT
FROM (
    SELECT COUNT(*) AS n
    FROM order_analytics
    GROUP BY order_id
    HAVING COUNT(*) > 1
) x

UNION ALL
SELECT 'Duplicate Checks', 'delivery_analytics_duplicate_key',
       COALESCE(SUM(n - 1), 0)::BIGINT
FROM (
    SELECT COUNT(*) AS n
    FROM delivery_analytics
    GROUP BY order_id
    HAVING COUNT(*) > 1
) x

UNION ALL
SELECT 'Duplicate Checks', 'seller_analytics_duplicate_key',
       COALESCE(SUM(n - 1), 0)::BIGINT
FROM (
    SELECT COUNT(*) AS n
    FROM seller_analytics
    GROUP BY seller_id
    HAVING COUNT(*) > 1
) x

UNION ALL
SELECT 'Duplicate Checks', 'category_analytics_duplicate_key',
       COALESCE(SUM(n - 1), 0)::BIGINT
FROM (
    SELECT COUNT(*) AS n
    FROM category_analytics
    GROUP BY category_name
    HAVING COUNT(*) > 1
) x

UNION ALL
SELECT 'Duplicate Checks', 'canceled_order_analytics_duplicate_key',
       COALESCE(SUM(n - 1), 0)::BIGINT
FROM (
    SELECT COUNT(*) AS n
    FROM canceled_order_analytics
    GROUP BY order_id
    HAVING COUNT(*) > 1
) x

UNION ALL
SELECT 'Duplicate Checks', 'customer_analytics_duplicate_key',
       COALESCE(SUM(n - 1), 0)::BIGINT
FROM (
    SELECT COUNT(*) AS n
    FROM customer_analytics
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) x

UNION ALL
SELECT 'Duplicate Checks', 'product_analytics_duplicate_key',
       COALESCE(SUM(n - 1), 0)::BIGINT
FROM (
    SELECT COUNT(*) AS n
    FROM product_analytics
    GROUP BY product_id
    HAVING COUNT(*) > 1
) x

UNION ALL
SELECT 'Duplicate Checks', 'review_analytics_duplicate_key',
       COALESCE(SUM(n - 1), 0)::BIGINT
FROM (
    SELECT COUNT(*) AS n
    FROM review_analytics
    GROUP BY order_id, seller_id, review_id
    HAVING COUNT(*) > 1
) x

UNION ALL
SELECT 'Duplicate Checks', 'payment_analytics_duplicate_key',
       COALESCE(SUM(n - 1), 0)::BIGINT
FROM (
    SELECT COUNT(*) AS n
    FROM payment_analytics
    GROUP BY order_id, payment_sequential
    HAVING COUNT(*) > 1
) x;


-- =======================================================
-- 3. NULL CHECKS
-- NULL review_id / review_score are allowed when an order
-- has no review.
-- NULL delivery_time / delivery_days / delay_days are
-- allowed for orders that have not been delivered.
-- NULL last_purchase_time is allowed for customers with
-- no orders.
-- =======================================================

INSERT INTO dq_results (section_name, check_name, invalid_rows)
SELECT 'NULL Checks', 'order_seller_analytics_required_nulls', COUNT(*)
FROM order_seller_analytics
WHERE order_id IS NULL
   OR seller_id IS NULL
   OR seller_order_value IS NULL
   OR seller_state IS NULL
   OR distance_km IS NULL

UNION ALL
SELECT 'NULL Checks', 'order_analytics_required_nulls', COUNT(*)
FROM order_analytics
WHERE order_id IS NULL
   OR order_status IS NULL
   OR order_value IS NULL
   OR purchase_time IS NULL
   OR customer_state IS NULL
   OR item_counts IS NULL

UNION ALL
SELECT 'NULL Checks', 'delivery_analytics_required_nulls', COUNT(*)
FROM delivery_analytics
WHERE order_id IS NULL
   OR customer_id IS NULL
   OR purchase_time IS NULL
   OR estimated_delivery_time IS NULL
   OR customer_state IS NULL
   OR order_weight IS NULL
   OR order_status IS NULL

UNION ALL
SELECT 'NULL Checks', 'seller_analytics_required_nulls', COUNT(*)
FROM seller_analytics
WHERE seller_id IS NULL
   OR seller_state IS NULL
   OR total_orders IS NULL
   OR canceled_orders IS NULL
   OR total_sales_value IS NULL
   OR total_items_sold IS NULL
   OR average_review_score IS NULL

UNION ALL
SELECT 'NULL Checks', 'category_analytics_required_nulls', COUNT(*)
FROM category_analytics
WHERE category_name IS NULL
   OR total_category_value IS NULL
   OR total_category_units_sold IS NULL

UNION ALL
SELECT 'NULL Checks', 'canceled_order_analytics_required_nulls', COUNT(*)
FROM canceled_order_analytics
WHERE order_id IS NULL
   OR purchase_time IS NULL
   OR customer_state IS NULL
   OR order_value IS NULL

UNION ALL
SELECT 'NULL Checks', 'customer_analytics_required_nulls', COUNT(*)
FROM customer_analytics
WHERE customer_id IS NULL
   OR total_orders IS NULL
   OR total_spending IS NULL
   OR total_items_purchased IS NULL
   OR average_days_between_orders IS NULL

UNION ALL
SELECT 'NULL Checks', 'product_analytics_required_nulls', COUNT(*)
FROM product_analytics
WHERE product_id IS NULL
   OR total_units_sold IS NULL
   OR total_sales_value IS NULL
   OR average_price IS NULL
   OR average_review_score IS NULL
   OR product_weight_kg IS NULL

UNION ALL
SELECT 'NULL Checks', 'review_analytics_required_nulls', COUNT(*)
FROM review_analytics
WHERE order_id IS NULL
   OR customer_id IS NULL
   OR seller_id IS NULL
   OR customer_state IS NULL
   OR purchase_time IS NULL

UNION ALL
SELECT 'NULL Checks', 'payment_analytics_required_nulls', COUNT(*)
FROM payment_analytics
WHERE order_id IS NULL
   OR payment_method IS NULL
   OR payment_sequential IS NULL
   OR installment_count IS NULL
   OR average_installment_value IS NULL;


-- =======================================================
-- 4. RANGE AND DOMAIN CHECKS
-- NULLs are handled separately in section 3.
-- A negative delay_days is valid: delivery happened before
-- the estimated delivery date.
-- =======================================================

INSERT INTO dq_results (section_name, check_name, invalid_rows)
SELECT 'Range and Domain Checks',
       'order_seller_analytics_invalid_state_or_range',
       COUNT(*)
FROM order_seller_analytics osa
WHERE NOT EXISTS (
        SELECT 1
        FROM dq.valid_states vs
        WHERE vs.state = osa.seller_state
    )
   OR osa.seller_order_value < 0
   OR osa.distance_km < 0

UNION ALL
SELECT 'Range and Domain Checks',
       'order_analytics_invalid_status_state_or_range',
       COUNT(*)
FROM order_analytics oa
WHERE NOT EXISTS (
        SELECT 1
        FROM dq.valid_order_statuses vos
        WHERE vos.order_status = oa.order_status
    )
   OR oa.order_value < 0
   OR oa.purchase_time < TIMESTAMP '2016-09-04 21:15:19'
   OR oa.purchase_time > TIMESTAMP '2018-08-29 15:00:37'
   OR NOT EXISTS (
        SELECT 1
        FROM dq.valid_states vs
        WHERE vs.state = oa.customer_state
    )
   OR oa.item_counts < 0
   OR oa.average_distance_km < 0

UNION ALL
SELECT 'Range and Domain Checks',
       'delivery_analytics_invalid_status_state_or_range',
       COUNT(*)
FROM delivery_analytics da
WHERE NOT EXISTS (
        SELECT 1
        FROM dq.valid_states vs
        WHERE vs.state = da.customer_state
    )
   OR da.order_weight < 0
   OR da.delivery_days < 0
   OR NOT EXISTS (
        SELECT 1
        FROM dq.valid_order_statuses vos
        WHERE vos.order_status = da.order_status
    )

UNION ALL
SELECT 'Range and Domain Checks',
       'seller_analytics_invalid_metric_range',
       COUNT(*)
FROM seller_analytics sa
WHERE sa.total_orders < 0
   OR sa.canceled_orders < 0
   OR sa.canceled_orders > sa.total_orders
   OR sa.total_sales_value < 0
   OR sa.total_items_sold < 0
   OR sa.average_review_score < 0
   OR sa.average_review_score > 5

UNION ALL
SELECT 'Range and Domain Checks',
       'category_analytics_invalid_metric_range',
       COUNT(*)
FROM category_analytics ca
WHERE ca.total_category_value < 0
   OR ca.total_category_units_sold < 0

UNION ALL
SELECT 'Range and Domain Checks',
       'canceled_order_analytics_invalid_state_or_range',
       COUNT(*)
FROM canceled_order_analytics coa
WHERE coa.purchase_time < TIMESTAMP '2016-09-04 21:15:19'
   OR coa.purchase_time > TIMESTAMP '2018-08-29 15:00:37'
   OR NOT EXISTS (
        SELECT 1
        FROM dq.valid_states vs
        WHERE vs.state = coa.customer_state
    )
   OR coa.order_value < 0

UNION ALL
SELECT 'Range and Domain Checks',
       'customer_analytics_invalid_metric_or_date_range',
       COUNT(*)
FROM customer_analytics ca
WHERE ca.total_orders < 0
   OR ca.total_spending < 0
   OR ca.total_items_purchased < 0
   OR (
        ca.last_purchase_time IS NOT NULL
        AND (
            ca.last_purchase_time < TIMESTAMP '2016-09-04 21:15:19'
            OR ca.last_purchase_time > TIMESTAMP '2018-08-29 15:00:37'
        )
   )
   OR ca.average_days_between_orders < 0

UNION ALL
SELECT 'Range and Domain Checks',
       'product_analytics_invalid_metric_range',
       COUNT(*)
FROM product_analytics pa
WHERE pa.total_units_sold < 0
   OR pa.total_sales_value < 0
   OR pa.average_price < 0
   OR pa.average_review_score < 0
   OR pa.average_review_score > 5
   OR pa.product_weight_kg < 0

UNION ALL
SELECT 'Range and Domain Checks',
       'review_analytics_invalid_score_state_or_date_range',
       COUNT(*)
FROM review_analytics ra
WHERE (
        ra.review_score IS NOT NULL
        AND (ra.review_score < 1 OR ra.review_score > 5)
    )
   OR NOT EXISTS (
        SELECT 1
        FROM dq.valid_states vs
        WHERE vs.state = ra.customer_state
    )
   OR ra.purchase_time < TIMESTAMP '2016-09-04 21:15:19'
   OR ra.purchase_time > TIMESTAMP '2018-08-29 15:00:37'

UNION ALL
SELECT 'Range and Domain Checks',
       'payment_analytics_invalid_method_or_range',
       COUNT(*)
FROM payment_analytics pma
WHERE NOT EXISTS (
        SELECT 1
        FROM dq.valid_payment_methods vpm
        WHERE vpm.payment_method = pma.payment_method
    )
   OR pma.payment_sequential < 1
   OR pma.installment_count < 1
   OR pma.average_installment_value < 0;


-- =======================================================
-- 5. TEMPORAL CONSISTENCY
-- Delivery and estimated dates must not precede purchase.
-- NULL delivery_time is valid for undelivered orders.
-- =======================================================

INSERT INTO dq_results (section_name, check_name, invalid_rows)
SELECT
    'Temporal Consistency',
    'delivery_dates_before_purchase_time',
    COUNT(*)
FROM delivery_analytics da
WHERE (
        da.estimated_delivery_time IS NOT NULL
        AND da.estimated_delivery_time < da.purchase_time
    )
   OR (
        da.delivery_time IS NOT NULL
        AND da.delivery_time < da.purchase_time
    );


-- =======================================================
-- 6. REFERENTIAL INTEGRITY
-- =======================================================

INSERT INTO dq_results (section_name, check_name, invalid_rows)
SELECT 'Referential Integrity',
       'order_seller_analytics_missing_order_or_seller',
       COUNT(*)
FROM order_seller_analytics osa
WHERE NOT EXISTS (
        SELECT 1
        FROM orders o
        WHERE o.order_id = osa.order_id
    )
   OR NOT EXISTS (
        SELECT 1
        FROM sellers s
        WHERE s.seller_id = osa.seller_id
    )

UNION ALL
SELECT 'Referential Integrity',
       'order_analytics_missing_order',
       COUNT(*)
FROM order_analytics oa
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.order_id = oa.order_id
)

UNION ALL
SELECT 'Referential Integrity',
       'delivery_analytics_order_customer_mismatch',
       COUNT(*)
FROM delivery_analytics da
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.order_id = da.order_id
      AND o.customer_id = da.customer_id
)

UNION ALL
SELECT 'Referential Integrity',
       'seller_analytics_missing_seller',
       COUNT(*)
FROM seller_analytics sa
WHERE NOT EXISTS (
    SELECT 1
    FROM sellers s
    WHERE s.seller_id = sa.seller_id
)

UNION ALL
SELECT 'Referential Integrity',
       'canceled_order_analytics_missing_order',
       COUNT(*)
FROM canceled_order_analytics coa
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.order_id = coa.order_id
)

UNION ALL
SELECT 'Referential Integrity',
       'customer_analytics_missing_customer',
       COUNT(*)
FROM customer_analytics ca
WHERE NOT EXISTS (
    SELECT 1
    FROM customers c
    WHERE c.customer_id = ca.customer_id
)

UNION ALL
SELECT 'Referential Integrity',
       'product_analytics_missing_product',
       COUNT(*)
FROM product_analytics pa
WHERE NOT EXISTS (
    SELECT 1
    FROM products p
    WHERE p.product_id = pa.product_id
)

UNION ALL
SELECT 'Referential Integrity',
       'review_analytics_order_customer_seller_or_review_mismatch',
       COUNT(*)
FROM review_analytics ra
WHERE NOT EXISTS (
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
    )
   OR (
        ra.review_id IS NOT NULL
        AND NOT EXISTS (
            SELECT 1
            FROM order_reviews r
            WHERE r.review_id = ra.review_id
              AND r.order_id = ra.order_id
        )
    )

UNION ALL
SELECT 'Referential Integrity',
       'payment_analytics_missing_order',
       COUNT(*)
FROM payment_analytics pma
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.order_id = pma.order_id
);


-- =======================================================
-- 7. AGGREGATION CONSISTENCY
-- Recalculate source metrics and compare them with analytics.
-- =======================================================

WITH
order_seller_source AS (
    SELECT
        oi.order_id,
        oi.seller_id,
        SUM(oi.price) AS seller_value
    FROM order_items oi
    GROUP BY oi.order_id, oi.seller_id
),

order_source AS (
    SELECT
        oi.order_id,
        SUM(oi.price) AS order_total_value,
        COUNT(*) AS item_count,
        o.order_status,
        o.purchase_time,
        c.state AS customer_state
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    JOIN customers c ON c.customer_id = o.customer_id
    GROUP BY
        oi.order_id,
        o.order_status,
        o.purchase_time,
        c.state
),

order_distance_source AS (
    SELECT
        osa.order_id,
        AVG(osa.distance_km) AS avg_distance
    FROM order_seller_analytics osa
    GROUP BY osa.order_id
),

seller_source AS (
    SELECT
        oi.seller_id,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        COUNT(DISTINCT CASE
            WHEN o.order_status = 'canceled' THEN oi.order_id
        END) AS canceled_orders,
        SUM(oi.price) AS seller_revenue,
        COUNT(*) AS item_count
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    GROUP BY oi.seller_id
),

seller_review_source AS (
    SELECT
        x.seller_id,
        COALESCE(AVG(x.order_avg_review), 0) AS avg_seller_review
    FROM (
        SELECT
            oi.seller_id,
            oi.order_id,
            AVG(r.review_score) AS order_avg_review
        FROM order_items oi
        JOIN order_reviews r ON r.order_id = oi.order_id
        GROUP BY oi.seller_id, oi.order_id
    ) x
    GROUP BY x.seller_id
),

category_source AS (
    SELECT
        p.category AS category_name,
        SUM(oi.price) AS total_category_value,
        COUNT(*) AS total_category_units_sold
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY p.category
),

customer_order_source AS (
    SELECT
        o.customer_id,
        oi.order_id,
        SUM(oi.price) AS order_value,
        COUNT(*) AS item_count
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    GROUP BY o.customer_id, oi.order_id
),

customer_source AS (
    SELECT
        c.customer_id,
        COALESCE(SUM(cos.order_value), 0) AS total_spending,
        COUNT(DISTINCT cos.order_id) AS total_orders,
        COALESCE(SUM(cos.item_count), 0) AS total_items_purchased
    FROM customers c
    LEFT JOIN customer_order_source cos
        ON cos.customer_id = c.customer_id
    GROUP BY c.customer_id
),

customer_history AS (
    SELECT
        cos.customer_id,
        cos.order_id,
        o.purchase_time,
        LAG(o.purchase_time) OVER (
            PARTITION BY cos.customer_id
            ORDER BY o.purchase_time, cos.order_id
        ) AS previous_purchase_time
    FROM customer_order_source cos
    JOIN orders o ON o.order_id = cos.order_id
),

customer_history_source AS (
    SELECT
        c.customer_id,
        MAX(ch.purchase_time) AS last_purchase_time,
        ROUND(
            COALESCE(
                AVG(
                    EXTRACT(EPOCH FROM (
                        ch.purchase_time - ch.previous_purchase_time
                    )) / 86400.0
                ),
                0
            )::NUMERIC,
            1
        ) AS avg_days_between_orders
    FROM customers c
    LEFT JOIN customer_history ch
        ON ch.customer_id = c.customer_id
    GROUP BY c.customer_id
),

order_review_source AS (
    SELECT
        r.order_id,
        AVG(r.review_score) AS avg_review_score
    FROM order_reviews r
    GROUP BY r.order_id
),

product_source AS (
    SELECT
        p.product_id,
        COUNT(oi.order_id) AS total_units_sold,
        COALESCE(SUM(oi.price), 0) AS total_sales_value,
        COALESCE(AVG(oi.price), 0) AS average_price,
        ROUND(
            COALESCE(AVG(ors.avg_review_score), 0)::NUMERIC,
            1
        ) AS average_review_score,
        COALESCE(MAX(p.weight_g), 0) / 1000.0 AS product_weight_kg
    FROM products p
    LEFT JOIN order_items oi ON oi.product_id = p.product_id
    LEFT JOIN order_review_source ors ON ors.order_id = oi.order_id
    GROUP BY p.product_id
),

payment_order_source AS (
    SELECT
        oi.order_id,
        SUM(oi.price) AS order_value
    FROM order_items oi
    GROUP BY oi.order_id
),

payment_source AS (
    SELECT
        op.order_id,
        op.payment_sequential,
        op.payment_type AS payment_method,
        op.payment_installments AS installment_count,
        ROUND(
            (
                pos.order_value
                / NULLIF(op.payment_installments, 0)
            )::NUMERIC,
            2
        ) AS average_installment_value
    FROM order_payments op
    JOIN payment_order_source pos
        ON pos.order_id = op.order_id
),

delivery_source AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.purchase_time,
        o.estimated_delivery_time,
        o.order_delivery_time AS delivery_time,
        c.state AS customer_state,
        o.order_status,
        COALESCE(SUM(p.weight_g), 0) / 1000.0 AS order_weight,
        EXTRACT(
            EPOCH FROM (o.order_delivery_time - o.purchase_time)
        ) / 86400.0 AS delivery_days,
        EXTRACT(
            EPOCH FROM (o.order_delivery_time - o.estimated_delivery_time)
        ) / 86400.0 AS delay_days
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY
        o.order_id,
        o.customer_id,
        o.purchase_time,
        o.estimated_delivery_time,
        o.order_delivery_time,
        c.state,
        o.order_status
),

canceled_source AS (
    SELECT
        o.order_id,
        o.purchase_time,
        c.state AS customer_state,
        SUM(oi.price) AS order_value
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.order_status = 'canceled'
    GROUP BY
        o.order_id,
        o.purchase_time,
        c.state
),

review_source AS (
    SELECT DISTINCT
        oi.order_id,
        o.customer_id,
        oi.seller_id,
        r.review_score,
        r.review_id,
        c.state AS customer_state,
        o.purchase_time
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    JOIN customers c ON c.customer_id = o.customer_id
    LEFT JOIN order_reviews r ON r.order_id = oi.order_id
)

INSERT INTO dq_results (section_name, check_name, invalid_rows)

SELECT
    'Aggregation Consistency',
    'order_seller_analytics_metric_or_key_mismatch',
    COUNT(*)
FROM order_seller_analytics a
FULL JOIN order_seller_source s
    ON s.order_id = a.order_id
   AND s.seller_id = a.seller_id
WHERE a.order_id IS NULL
   OR s.order_id IS NULL
   OR a.seller_order_value IS DISTINCT FROM s.seller_value

UNION ALL
SELECT
    'Aggregation Consistency',
    'order_analytics_metric_or_key_mismatch',
    COUNT(*)
FROM order_analytics a
FULL JOIN order_source s
    ON s.order_id = a.order_id
LEFT JOIN order_distance_source d
    ON d.order_id = COALESCE(a.order_id, s.order_id)
WHERE a.order_id IS NULL
   OR s.order_id IS NULL
   OR a.order_value IS DISTINCT FROM s.order_total_value
   OR a.item_counts IS DISTINCT FROM s.item_count
   OR a.average_distance_km IS DISTINCT FROM d.avg_distance
   OR a.order_status IS DISTINCT FROM s.order_status
   OR a.purchase_time IS DISTINCT FROM s.purchase_time
   OR a.customer_state IS DISTINCT FROM s.customer_state

UNION ALL
SELECT
    'Aggregation Consistency',
    'seller_analytics_metric_or_key_mismatch',
    COUNT(*)
FROM seller_analytics a
FULL JOIN seller_source s
    ON s.seller_id = a.seller_id
LEFT JOIN seller_review_source r
    ON r.seller_id = COALESCE(a.seller_id, s.seller_id)
WHERE a.seller_id IS NULL
   OR s.seller_id IS NULL
   OR a.total_orders IS DISTINCT FROM s.total_orders
   OR a.canceled_orders IS DISTINCT FROM s.canceled_orders
   OR a.total_sales_value IS DISTINCT FROM s.seller_revenue
   OR a.total_items_sold IS DISTINCT FROM s.item_count
   OR a.average_review_score IS DISTINCT FROM COALESCE(r.avg_seller_review, 0)

UNION ALL
SELECT
    'Aggregation Consistency',
    'category_analytics_metric_or_key_mismatch',
    COUNT(*)
FROM category_analytics a
FULL JOIN category_source s
    ON s.category_name = a.category_name
WHERE a.category_name IS NULL
   OR s.category_name IS NULL
   OR a.total_category_value IS DISTINCT FROM s.total_category_value
   OR a.total_category_units_sold IS DISTINCT FROM s.total_category_units_sold

UNION ALL
SELECT
    'Aggregation Consistency',
    'customer_analytics_metric_or_key_mismatch',
    COUNT(*)
FROM customer_analytics a
FULL JOIN customer_source s
    ON s.customer_id = a.customer_id
LEFT JOIN customer_history_source h
    ON h.customer_id = COALESCE(a.customer_id, s.customer_id)
WHERE a.customer_id IS NULL
   OR s.customer_id IS NULL
   OR a.total_spending IS DISTINCT FROM s.total_spending
   OR a.total_orders IS DISTINCT FROM s.total_orders
   OR a.total_items_purchased IS DISTINCT FROM s.total_items_purchased
   OR a.last_purchase_time IS DISTINCT FROM h.last_purchase_time
   OR a.average_days_between_orders IS DISTINCT FROM h.avg_days_between_orders

UNION ALL
SELECT
    'Aggregation Consistency',
    'product_analytics_metric_or_key_mismatch',
    COUNT(*)
FROM product_analytics a
FULL JOIN product_source s
    ON s.product_id = a.product_id
WHERE a.product_id IS NULL
   OR s.product_id IS NULL
   OR a.total_units_sold IS DISTINCT FROM s.total_units_sold
   OR a.total_sales_value IS DISTINCT FROM s.total_sales_value
   OR a.average_price IS DISTINCT FROM s.average_price
   OR a.average_review_score IS DISTINCT FROM s.average_review_score
   OR a.product_weight_kg IS DISTINCT FROM s.product_weight_kg

UNION ALL
SELECT
    'Aggregation Consistency',
    'payment_analytics_metric_or_key_mismatch',
    COUNT(*)
FROM payment_analytics a
FULL JOIN payment_source s
    ON s.order_id = a.order_id
   AND s.payment_sequential = a.payment_sequential
WHERE a.order_id IS NULL
   OR s.order_id IS NULL
   OR a.payment_method IS DISTINCT FROM s.payment_method
   OR a.installment_count IS DISTINCT FROM s.installment_count
   OR a.average_installment_value IS DISTINCT FROM s.average_installment_value

UNION ALL
SELECT
    'Aggregation Consistency',
    'delivery_analytics_metric_or_key_mismatch',
    COUNT(*)
FROM delivery_analytics a
FULL JOIN delivery_source s
    ON s.order_id = a.order_id
WHERE a.order_id IS NULL
   OR s.order_id IS NULL
   OR a.customer_id IS DISTINCT FROM s.customer_id
   OR a.purchase_time IS DISTINCT FROM s.purchase_time
   OR a.estimated_delivery_time IS DISTINCT FROM s.estimated_delivery_time
   OR a.delivery_time IS DISTINCT FROM s.delivery_time
   OR a.customer_state IS DISTINCT FROM s.customer_state
   OR a.order_status IS DISTINCT FROM s.order_status
   OR a.order_weight IS DISTINCT FROM s.order_weight
   OR a.delivery_days IS DISTINCT FROM s.delivery_days
   OR a.delay_days IS DISTINCT FROM s.delay_days

UNION ALL
SELECT
    'Aggregation Consistency',
    'canceled_order_analytics_metric_or_key_mismatch',
    COUNT(*)
FROM canceled_order_analytics a
FULL JOIN canceled_source s
    ON s.order_id = a.order_id
WHERE a.order_id IS NULL
   OR s.order_id IS NULL
   OR a.purchase_time IS DISTINCT FROM s.purchase_time
   OR a.customer_state IS DISTINCT FROM s.customer_state
   OR a.order_value IS DISTINCT FROM s.order_value

UNION ALL
SELECT
    'Aggregation Consistency',
    'review_analytics_metric_or_key_mismatch',
    COUNT(*)
FROM review_analytics a
FULL JOIN review_source s
    ON s.order_id = a.order_id
   AND s.seller_id = a.seller_id
   AND s.review_id IS NOT DISTINCT FROM a.review_id
WHERE a.order_id IS NULL
   OR s.order_id IS NULL
   OR a.customer_id IS DISTINCT FROM s.customer_id
   OR a.review_score IS DISTINCT FROM s.review_score
   OR a.customer_state IS DISTINCT FROM s.customer_state
   OR a.purchase_time IS DISTINCT FROM s.purchase_time;


-- =======================================================
-- 8. BUSINESS LOGIC CHECKS
-- =======================================================

INSERT INTO dq_results (section_name, check_name, invalid_rows)
SELECT
    'Business Logic Checks',
    'canceled_order_status_mismatch',
    COUNT(*)
FROM canceled_order_analytics coa
JOIN orders o ON o.order_id = coa.order_id
WHERE o.order_status IS DISTINCT FROM 'canceled'

UNION ALL
SELECT
    'Business Logic Checks',
    'order_analytics_customer_state_mismatch',
    COUNT(*)
FROM order_analytics oa
JOIN orders o ON o.order_id = oa.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE oa.customer_state IS DISTINCT FROM c.state

UNION ALL
SELECT
    'Business Logic Checks',
    'delivery_analytics_customer_state_mismatch',
    COUNT(*)
FROM delivery_analytics da
JOIN orders o ON o.order_id = da.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE da.customer_state IS DISTINCT FROM c.state

UNION ALL
SELECT
    'Business Logic Checks',
    'canceled_order_analytics_customer_state_mismatch',
    COUNT(*)
FROM canceled_order_analytics coa
JOIN orders o ON o.order_id = coa.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE coa.customer_state IS DISTINCT FROM c.state

UNION ALL
SELECT
    'Business Logic Checks',
    'review_analytics_customer_state_mismatch',
    COUNT(*)
FROM review_analytics ra
JOIN orders o ON o.order_id = ra.order_id
JOIN customers c ON c.customer_id = o.customer_id
WHERE ra.customer_state IS DISTINCT FROM c.state

UNION ALL
SELECT
    'Business Logic Checks',
    'order_seller_analytics_seller_state_mismatch',
    COUNT(*)
FROM order_seller_analytics osa
JOIN sellers s ON s.seller_id = osa.seller_id
WHERE osa.seller_state IS DISTINCT FROM s.state

UNION ALL
SELECT
    'Business Logic Checks',
    'seller_analytics_seller_state_mismatch',
    COUNT(*)
FROM seller_analytics sa
JOIN sellers s ON s.seller_id = sa.seller_id
WHERE sa.seller_state IS DISTINCT FROM s.state;


-- =======================================================
-- 9. FINAL DQ SUMMARY
-- Set PASS / FAIL only after every check has been inserted.
-- =======================================================

UPDATE dq_results
SET check_status =
    CASE
        WHEN invalid_rows = 0 THEN 'PASS'
        ELSE 'FAIL'
    END
WHERE check_status = 'PENDING';


-- Detailed result for every individual check.
SELECT
    section_name,
    check_name,
    invalid_rows,
    check_status
FROM dq_results
ORDER BY
    CASE section_name
        WHEN 'Row Count Checks' THEN 1
        WHEN 'Duplicate Checks' THEN 2
        WHEN 'NULL Checks' THEN 3
        WHEN 'Range and Domain Checks' THEN 4
        WHEN 'Temporal Consistency' THEN 5
        WHEN 'Referential Integrity' THEN 6
        WHEN 'Aggregation Consistency' THEN 7
        WHEN 'Business Logic Checks' THEN 8
        ELSE 9
    END,
    check_name;


-- Overall summary by section.
SELECT
    section_name,
    COUNT(*) AS total_checks,
    COUNT(*) FILTER (WHERE check_status = 'PASS') AS passed_checks,
    COUNT(*) FILTER (WHERE check_status = 'FAIL') AS failed_checks,
    SUM(invalid_rows) AS total_invalid_rows,
    CASE
        WHEN COUNT(*) FILTER (WHERE check_status = 'FAIL') = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS section_status
FROM dq_results
GROUP BY section_name
ORDER BY
    CASE section_name
        WHEN 'Row Count Checks' THEN 1
        WHEN 'Duplicate Checks' THEN 2
        WHEN 'NULL Checks' THEN 3
        WHEN 'Range and Domain Checks' THEN 4
        WHEN 'Temporal Consistency' THEN 5
        WHEN 'Referential Integrity' THEN 6
        WHEN 'Aggregation Consistency' THEN 7
        WHEN 'Business Logic Checks' THEN 8
        ELSE 9
    END;


-- One-row overall result.
SELECT
    COUNT(*) AS total_checks,
    COUNT(*) FILTER (WHERE check_status = 'PASS') AS passed_checks,
    COUNT(*) FILTER (WHERE check_status = 'FAIL') AS failed_checks,
    SUM(invalid_rows) AS total_invalid_rows,
    CASE
        WHEN COUNT(*) FILTER (WHERE check_status = 'FAIL') = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS overall_dq_status
FROM dq_results;
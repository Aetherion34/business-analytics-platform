CREATE TABLE order_seller_analytics AS -- 1 row = 1 order + 1 seller
WITH average_geolocations AS (
    SELECT
        zip_code,
        AVG(g.longitude) AS lng,
        AVG(g.latitude) AS lat
    FROM geolocations g
    GROUP BY zip_code
)

SELECT
    oi.order_id AS order_id,
    oi.seller_id AS seller_id,
    MAX(s.state) AS seller_state,
    SUM(oi.price) AS seller_order_value,
    MAX(
        2 * 6371 * ASIN(
            SQRT(
                POWER(
                    SIN((RADIANS(gc.lat) - RADIANS(gs.lat)) / 2),
                    2
                ) +
                COS(RADIANS(gc.lat)) *
                COS(RADIANS(gs.lat)) *
                POWER(
                    SIN((RADIANS(gc.lng) - RADIANS(gs.lng)) / 2),
                    2
                )
            )
        )
    ) AS distance_km
FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN sellers s
    ON oi.seller_id = s.seller_id

JOIN customers c
    ON o.customer_id = c.customer_id

LEFT JOIN average_geolocations gc
    ON gc.zip_code = c.zip_code

LEFT JOIN average_geolocations gs
    ON gs.zip_code = s.zip_code

GROUP BY
    oi.seller_id,
    oi.order_id;


CREATE TABLE order_analytics AS -- 1 row = 1 order
WITH order_summary AS (
    SELECT
        oi.order_id AS order_id,
        SUM(oi.price) AS order_value,
        COUNT(oi.order_id) AS item_counts
    FROM order_items oi
    GROUP BY
        oi.order_id
),
average_distances AS (
    SELECT
        osa.order_id AS order_id,
        AVG(osa.distance_km) AS average_distance_km
    FROM order_seller_analytics osa
    GROUP BY
        osa.order_id
)

SELECT
    o.order_id AS order_id,
    o.order_status AS order_status,
    os.order_value AS order_value,
    o.purchase_time AS purchase_time,
    c.state AS customer_state,
    os.item_counts AS item_counts,
    ad.average_distance_km AS average_distance_km

FROM orders o

JOIN order_summary os
    ON o.order_id = os.order_id

JOIN customers c
    ON o.customer_id = c.customer_id

LEFT JOIN average_distances ad
    ON o.order_id = ad.order_id;


CREATE TABLE delivery_analytics AS -- 1 row = 1 order
WITH order_delivery_summary AS (
    SELECT
        oi.order_id AS order_id,
        o.customer_id AS customer_id,
        SUM(p.weight_g) / 1000 AS order_weight
    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY
        oi.order_id,
        o.customer_id
)

SELECT
    o.order_id AS order_id,
    ods.customer_id AS customer_id,
    o.purchase_time AS purchase_time,
    o.estimated_delivery_time AS estimated_delivery_time,
    o.order_delivery_time AS delivery_time,
    c.state AS customer_state,
    ods.order_weight AS order_weight,

    EXTRACT(
        EPOCH FROM (
            o.order_delivery_time::timestamp
            - o.purchase_time::timestamp
        )
    ) / 86400 AS delivery_days,

    EXTRACT(
        EPOCH FROM (
            o.order_delivery_time::timestamp
            - o.estimated_delivery_time::timestamp
        )
    ) / 86400 AS delay_days,

    o.order_status AS order_status

FROM orders o

JOIN order_delivery_summary ods
    ON o.order_id = ods.order_id

JOIN customers c
    ON ods.customer_id = c.customer_id;

CREATE TABLE seller_analytics AS -- 1 row = 1 seller
WITH sellers_sales_summary AS (
    SELECT
        oi.seller_id AS seller_id,
        COUNT(oi.order_id) AS total_items_sold,
        SUM(oi.price) AS total_sales_value,
        COUNT(DISTINCT oi.order_id) AS total_orders
    FROM order_items oi
    GROUP BY
        oi.seller_id
),

seller_order_reviews AS (
    SELECT
        oi.order_id AS order_id,
        oi.seller_id AS seller_id,
        AVG(orw.review_score) AS average_review_score
    FROM order_items oi

    JOIN order_reviews orw
        ON oi.order_id = orw.order_id

    GROUP BY
        oi.order_id,
        oi.seller_id
),

average_seller_review AS (
    SELECT
        sor.seller_id,
        AVG(sor.average_review_score) AS average_seller_review_score
    FROM seller_order_reviews sor
    GROUP BY
        sor.seller_id
),

canceled_orders AS (
    SELECT
        oi.seller_id,
        COUNT(DISTINCT oi.order_id) AS canceled_orders
    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'canceled'

    GROUP BY
        oi.seller_id
)

SELECT
    s.seller_id AS seller_id,
    sss.total_orders AS total_orders,
    co.canceled_orders AS canceled_orders,
    sss.total_sales_value AS total_sales_value,
    sss.total_items_sold AS total_items_sold,
    asr.average_seller_review_score AS average_review_score,
    s.state AS seller_state

FROM sellers s

JOIN sellers_sales_summary sss
    ON sss.seller_id = s.seller_id

LEFT JOIN average_seller_review asr
    ON asr.seller_id = s.seller_id

LEFT JOIN canceled_orders co
    ON s.seller_id = co.seller_id;


CREATE TABLE category_analytics AS -- 1 row = 1 category
SELECT
    p.category AS category_name,
    SUM(oi.price) AS total_category_value,
    COUNT(oi.order_id) AS total_category_units_sold
FROM order_items oi

JOIN products p
    ON p.product_id = oi.product_id

GROUP BY
    p.category;


CREATE TABLE canceled_order_analytics AS -- 1 row = 1 canceled order
SELECT
    o.order_id AS order_id,
    MAX(o.purchase_time) AS purchase_time,
    MAX(c.state) AS customer_state,
    SUM(COALESCE(oi.price, 0)) AS order_value

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'canceled'

GROUP BY
    o.order_id;


CREATE TABLE customer_analytics AS -- 1 row = 1 customer
WITH customer_order AS (
    SELECT
        o.customer_id AS customer_id,
        oi.order_id AS order_id,
        SUM(oi.price) AS order_value,
        COUNT(*) AS item_count
    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    GROUP BY
        o.customer_id,
        oi.order_id
),

order_history AS (
    SELECT
        co.customer_id AS customer_id,
        co.order_id AS order_id,
        co.order_value AS order_value,
        co.item_count AS item_count,
        o.purchase_time AS purchase_time,

        LAG(o.purchase_time, 1) OVER (
            PARTITION BY co.customer_id
            ORDER BY o.purchase_time ASC
        ) AS previous_purchase_time

    FROM customer_order co

    JOIN orders o
        ON co.order_id = o.order_id
)

SELECT
    c.customer_id AS customer_id,

    COALESCE(
        COUNT(DISTINCT oh.order_id),
        0
    ) AS total_orders,

    COALESCE(
        SUM(oh.order_value),
        0
    ) AS total_spending,

    COALESCE(
        SUM(oh.item_count),
        0
    ) AS total_items_purchased,

    COALESCE(
        MAX(oh.purchase_time)::TEXT,
        'No purchases'
    ) AS last_purchase_time,

    ROUND(
        COALESCE(
            AVG(
                EXTRACT(
                    EPOCH FROM (
                        oh.purchase_time:: timestamp - oh.previous_purchase_time:: timestamp
                    )
                ) / 86400
            ),
            0
        )::NUMERIC,
        1
    ) AS average_days_between_orders

FROM customers c

LEFT JOIN order_history oh
    ON c.customer_id = oh.customer_id

GROUP BY
    c.customer_id;


CREATE TABLE product_analytics AS -- 1 row = 1 product
WITH clean_reviews AS (
    SELECT
        orw.order_id AS order_id,
        AVG(orw.review_score) AS review_score
    FROM order_reviews orw
    GROUP BY
        orw.order_id
)

SELECT
    p.product_id AS product_id,

    COUNT(oi.order_id) AS total_units_sold,

    COALESCE(
        SUM(oi.price),
        0
    ) AS total_sales_value,

    COALESCE(
        AVG(oi.price),
        0
    ) AS average_price,

    ROUND(
        COALESCE(
            AVG(cr.review_score),
            0
        )::NUMERIC,
        1
    ) AS average_review_score,

    COALESCE(
        MAX(p.weight_g),
        0
    ) / 1000.0 AS product_weight_kg

FROM products p

LEFT JOIN order_items oi
    ON p.product_id = oi.product_id

LEFT JOIN clean_reviews cr
    ON oi.order_id = cr.order_id

GROUP BY
    p.product_id;


CREATE TABLE review_analytics AS -- 1 row = 1 order + 1 seller + 1 review
WITH unique_order_parties AS (
    SELECT
        oi.order_id AS order_id,
        MAX(o.customer_id) AS customer_id,
        oi.seller_id AS seller_id

    FROM order_items oi

    JOIN orders o
        ON oi.order_id = o.order_id

    GROUP BY
        oi.order_id,
        oi.seller_id
)

SELECT
    uop.order_id AS order_id,
    uop.customer_id AS customer_id,
    uop.seller_id AS seller_id,
    orw.review_score AS review_score,
    c.state AS customer_state,
    o.purchase_time AS purchase_time
FROM unique_order_parties uop

LEFT JOIN order_reviews orw
ON  uop.order_id = orw.order_id

LEFT JOIN unique_order_parties uop
    ON orw.order_id = uop.order_id

LEFT JOIN orders o
    ON orw.order_id = o.order_id

LEFT JOIN customers c
    ON uop.customer_id = c.customer_id;


CREATE TABLE payment_analytics AS -- 1 row = 1 payment record
WITH order_values AS (
    SELECT
        oi.order_id AS order_id,
        SUM(oi.price) AS order_value
    FROM order_items oi
    GROUP BY
        oi.order_id
)

SELECT
    op.order_id AS order_id,
    op.payment_type AS payment_method,
    op.payment_sequential AS payment_sequential,
    op.payment_installments AS installment_count,

    ROUND(
        (
            ov.order_value /
            NULLIF(op.payment_installments, 0)
        )::NUMERIC,
        2
    ) AS average_installment_value

FROM order_payments op

JOIN order_values ov
    ON op.order_id = ov.order_id;
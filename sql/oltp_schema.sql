CREATE TABLE orders (
    order_id text PRIMARY KEY,
    customer_id text,
    order_status text,
    purchase_time timestamp,
    approval_time timestamp,
    carrier_delivery_time timestamp,
    order_delivery_time timestamp,
    estimated_delivery_time timestamp
)
CREATE TABLE customers (
    customer_id text
    customer_unique_id text
    zip_code text
    city text
    state text
)

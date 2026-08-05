CREATE TABLE customers (
    customer_id text PRIMARY KEY,
    customer_unique_id text NOT NULL,
    zip_code text,
    city text,
    state text
);


CREATE TABLE products (
    product_id text PRIMARY KEY,
    category text NOT NULL,
    name_length int,
    description_length int,
    photo_quantity int,
    weight_g numeric(10, 2) CHECK (weight_g >= 0),
    length_cm numeric(10, 2) CHECK (length_cm >= 0)
);


CREATE TABLE sellers (
    seller_id text PRIMARY KEY,
    zip_code text,
    city text,
    state text
);


CREATE TABLE orders (
    order_id text PRIMARY KEY,
    customer_id text NOT NULL,
    order_status text NOT NULL,
    purchase_time timestamp,
    approval_time timestamp,
    carrier_delivery_time timestamp,
    order_delivery_time timestamp,
    estimated_delivery_time timestamp,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


CREATE TABLE order_items (
    order_id text,
    order_item_id int NOT NULL,
    product_id text NOT NULL,
    seller_id text NOT NULL,
    shipping_limit timestamp,
    price numeric(10, 2) , CHECK (price >= 0),
    freight_value numeric(10, 2) CHECK (freight_value >= 0),
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);


CREATE TABLE order_payments (
    order_id text,
    payment_sequential int NOT NULL,
    payment_type text  NOT NULL,
    payment_installments int NOT NULL CHECK(payment_installments > 0),
    payment_value numeric(10, 2), CHECK (payment_value >= 0),
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);


CREATE TABLE order_reviews (
    review_id text PRIMARY KEY,
    order_id text UNIQUE  NOT NULL,
    review_score int CHECK (review_score BETWEEN 1 AND 5),
    title text,
    comment text,
    creation_timestamp timestamp,
    answer_timestamp timestamp,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);


CREATE TABLE geolocations (
    zip_code text NOT NULL,
    latitude numeric(9,6),
    longitude numeric(9,6)
    city text,
    state text,
    PRIMARY KEY (zip_code, latitude, longitude)
);
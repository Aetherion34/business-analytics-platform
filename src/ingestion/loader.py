import pandas as pd

CUSTOMERS_DTYPES = {
    "customer_id": str,
    "customer_unique_id": str,
    "customer_zip_code_prefix": str,
    "customer_city": str,
    "customer_state": str,
}

SELLERS_DTYPES = {
    "seller_id": str,
    "seller_zip_code_prefix": str,
    "seller_city": str,
    "seller_state": str,
}

PRODUCTS_DTYPES = {
    "product_id": str,
    "product_category_name": str,
}

ORDERS_DTYPES = {
    "order_id": str,
    "customer_id": str,
    "order_status": str,
}

ORDER_ITEMS_DTYPES = {
    "order_id": str,
    "product_id": str,
    "seller_id": str,
}

ORDER_PAYMENTS_DTYPES = {
    "order_id": str,
    "payment_type": str,
}

ORDER_REVIEWS_DTYPES = {
    "review_id": str,
    "order_id": str,
}

GEOLOCATION_DTYPES = {
    "geolocation_zip_code_prefix": str,
    "geolocation_city": str,
    "geolocation_state": str,
}

CATEGORY_TRANSLATION_DTYPES = {
    "product_category_name": str,
    "product_category_name_english": str,
}


def load_orders(path, column=None):
    return pd.read_csv(path, usecols=column, dtype=ORDERS_DTYPES)  # type: ignore


def load_customers(path, column=None):
    return pd.read_csv(path, usecols=column, dtype=CUSTOMERS_DTYPES)  # type: ignore


def load_sellers(path, column=None):
    return pd.read_csv(path, usecols=column, dtype=SELLERS_DTYPES)  # type: ignore


def load_products(path, column=None):
    return pd.read_csv(path, usecols=column, dtype=PRODUCTS_DTYPES)  # type: ignore


def load_order_items(path, column=None):
    return pd.read_csv(path, usecols=column, dtype=ORDER_ITEMS_DTYPES)  # type: ignore


def load_order_payments(path, column=None):
    return pd.read_csv(path, usecols=column, dtype=ORDER_PAYMENTS_DTYPES)  # type: ignore


def load_order_reviews(path, column=None):
    return pd.read_csv(path, usecols=column, dtype=ORDER_REVIEWS_DTYPES)  # type: ignore


def load_geolocation(path, column=None):
    return pd.read_csv(path, usecols=column, dtype=GEOLOCATION_DTYPES)  # type: ignore


def load_product_category_translations(path, column=None):
    return pd.read_csv(path, usecols=column, dtype=CATEGORY_TRANSLATION_DTYPES)  # type: ignore
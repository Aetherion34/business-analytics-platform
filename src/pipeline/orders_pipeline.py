import pandas as pd
from pathlib import Path
import ingestion.loader as Loader
from data_processing.cleaners import (
    OrdersCleaner,
    OrderItemsCleaner,
    OrderPaymentCleaner,
    OrderReviewsCleaner,
)
from data_processing.validators import (
    OrdersValidator,
    OrderItemsValidator,
    OrderPaymentsValidator,
    OrderReviewsValidator,
)
from data_processing.rules import orders_rule

BASE_DIR = Path(__file__).resolve().parents[2]
RAW_DIR = BASE_DIR / "data" / "raw"

def run(paths) -> tuple:
    product_ids =  Loader.load_products(BASE_DIR /  paths["products"], column = ["product_id"])["product_id"]
    seller_ids = Loader.load_sellers(BASE_DIR / paths["sellers"], column = ["seller_id"])["seller_id"]
    customer_ids = Loader.load_customers(BASE_DIR / paths["customers"], column = ["customer_id"])["customer_id"]
    order_items = Loader.load_order_items(RAW_DIR   / "olist_order_items_dataset.csv")

    order_payments = Loader.load_order_payments(RAW_DIR / "olist_order_payments_dataset.csv")

    orders = Loader.load_orders(RAW_DIR / "olist_orders_dataset.csv")
    orders_validator = OrdersValidator(orders, customer_ids)
    orders_cleaner = OrdersCleaner(orders, customer_ids)
    orders_report = orders_validator.validate()
    orders_cleaner.clean(orders_report)
    paths.update({"orders" : "data/processed/order_list.csv"})
    order_ids = Loader.load_orders(BASE_DIR / paths["orders"], column = ["order_id"])["order_id"]

    order_items_validator = OrderItemsValidator(order_items, order_ids = order_ids, product_ids = product_ids, seller_ids = seller_ids)
    order_items_cleaner = OrderItemsCleaner(order_items,  order_ids = order_ids, product_ids = product_ids, seller_ids = seller_ids)
    order_items_report = order_items_validator.validate()
    order_items_cleaner.clean(order_items_report)
    paths.update({"order_items": "data/processed/order_items_list.csv"})
    order_items_order_ids = Loader.load_order_items(BASE_DIR / paths["order_items"], column=["order_id"])["order_id"]
    order_items_clean = Loader.load_order_items(BASE_DIR / paths["order_items"])
    payments_total = order_items_clean[
    ["order_id", "price", "freight_value"]
]

    order_payments_validator = OrderPaymentsValidator(order_payments, payments_total)
    order_payments_cleaner = OrderPaymentCleaner(order_payments, payments_total)
    order_payments_report = order_payments_validator.validate()
    order_payments_cleaner.clean(order_payments_report)
    paths.update({"order_payments" : "data/processed/order_payments_list.csv"})
    payment_order_ids = Loader.load_order_payments(BASE_DIR / paths["order_payments"], column = ["order_id"])["order_id"]
    
    
    order_reviews = Loader.load_order_reviews(RAW_DIR   / "olist_order_reviews_dataset.csv")
    order_reviews_validator = OrderReviewsValidator(order_reviews)
    order_reviews_cleaner = OrderReviewsCleaner(order_reviews)
    order_reviews_report = order_reviews_validator.validate()
    order_reviews_cleaner.clean(order_reviews_report)
    paths.update({"order_reviews" : "data/processed/order_reviews_list.csv"})
    review_order_ids = Loader.load_order_reviews(BASE_DIR / paths["order_reviews"], column = ["order_id"])["order_id"]


    product_order_ids = orders_rule.get_valid_order_ids_from_valid_references(order_items_clean, product_ids)
    return product_order_ids, order_items_order_ids, review_order_ids, payment_order_ids, order_ids
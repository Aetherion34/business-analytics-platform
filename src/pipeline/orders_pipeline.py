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

BASE_DIR = Path(__file__).resolve().parents[2]
DATA_DIR = BASE_DIR / "data" / "raw"


def run():
    orders = Loader.load_orders(DATA_DIR / "olist_orders_dataset.csv")
    orders_validator = OrdersValidator(orders)
    orders_cleaner = OrdersCleaner(orders)
    orders_report = orders_validator.validate()
    orders_cleaner.clean(orders_report)

    order_items = Loader.load_order_items(DATA_DIR / "olist_order_items_dataset.csv")
    product_ids =  Loader.load_products(DATA_DIR / "olist_products_dataset.csv", column = ["product_id"])
    order_ids = Loader.load_orders(DATA_DIR / "olist_orders_dataset.csv", column = ["order_id"])
    seller_ids = Loader.load_sellers(DATA_DIR / "olist_sellers_dataset.csv", column = ["seller_id"])
    order_items_validator = OrderItemsValidator(order_items, order_ids = order_ids, product_ids = product_ids, seller_ids = seller_ids)
    order_items_cleaner = OrderItemsCleaner(order_items,  order_ids = order_ids, product_ids = product_ids, seller_ids = seller_ids)
    order_items_report = order_items_validator.validate()
    order_items_cleaner.clean(order_items_report)

    order_payments = Loader.load_order_payments(DATA_DIR / "olist_order_payments_dataset.csv")
    order_payments_validator = OrderPaymentsValidator(order_ids, order_payments)
    order_payments_cleaner = OrderPaymentCleaner(order_ids, order_payments)
    order_payments_report = order_payments_validator.validate()
    order_payments_cleaner.clean(order_payments_report)

    order_reviews = Loader.load_order_reviews(DATA_DIR / "olist_order_reviews_dataset.csv")
    order_reviews_validator = OrderReviewsValidator(order_ids, order_reviews)
    order_reviews_cleaner = OrderReviewsCleaner(order_ids, order_reviews)
    order_reviews_report = order_reviews_validator.validate()
    order_reviews_cleaner.clean(order_reviews_report)
from pathlib import Path
import ingestion.loader as Loader
from data_processing.cleaners import (
    ConsistencyCleaner
)
from data_processing.validators import (
    ConsistencyValidator
)

BASE_DIR = Path(__file__).resolve().parents[2]

def run(product_order_ids, order_items_order_ids, review_order_ids, payment_order_ids):
    order_payments_list = Loader.load_order_payments(BASE_DIR / "data/processed/order_payments_list.csv")
    order_items_list = Loader.load_order_items(BASE_DIR   / "data/processed/order_items_list.csv")
    order_reviews_list = Loader.load_order_reviews(BASE_DIR / "data/processed/order_reviews_list.csv")
    order_list = Loader.load_customers(BASE_DIR / "data/processed/orders_list.csv")
    consistency_validator = ConsistencyValidator(
        product_order_ids, order_items_order_ids, review_order_ids, payment_order_ids,
        order_payments_list, order_items_list, order_reviews_list, order_list)
    consistency_cleaner = ConsistencyCleaner(
        product_order_ids, order_items_order_ids, review_order_ids, payment_order_ids,
        order_payments_list, order_items_list, order_reviews_list, order_list)
    error_report = consistency_validator.validate()
    consistency_cleaner.clean(error_report)
    
from pathlib import Path
from .workflows import (
customers_pipeline as customers_pipeline,
products_pipeline as products_pipeline,
sellers_pipeline as sellers_pipeline,
orders_pipeline as orders_pipeline,
consistency_pipeline as consistency_pipeline)
CLEANED_CSV = Path(__file__).resolve().parents[2] / "data" / "processed"

def execute_pipelines():
    if not any(Path(CLEANED_CSV).iterdir()): # Checks if it needs to run the data cleaning pipeline
        paths = {}

        paths.update(customers_pipeline())
        paths.update(sellers_pipeline())
        paths.update(products_pipeline())
        product_order_ids, order_items_order_ids, review_order_ids, payment_order_ids, order_ids = orders_pipeline(paths)
        consistency_pipeline(product_order_ids, order_items_order_ids, review_order_ids, payment_order_ids, order_ids)
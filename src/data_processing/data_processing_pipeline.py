from .workflows import (
customers_pipeline as customers_pipeline,
products_pipeline as products_pipeline,
sellers_pipeline as sellers_pipeline,
orders_pipeline as orders_pipeline,
consistency_pipeline as consistency_pipeline)
def execute_pipelines():
    paths = {}

    paths.update(customers_pipeline())
    paths.update(sellers_pipeline())
    paths.update(products_pipeline())
    product_order_ids, order_items_order_ids, review_order_ids, payment_order_ids, order_ids = orders_pipeline(paths)
    consistency_pipeline(product_order_ids, order_items_order_ids, review_order_ids, payment_order_ids, order_ids)
from .customers_pipeline import run as customer_pipeline
from .products_pipeline import run as product_pipeline
from .sellers_pipeline import run as seller_pipeline
from .orders_pipeline import run as order_pipeline
from .Consistency_pipeline import run as consistency_pipeline
def execute_pipelines():
    paths = {}

    paths.update(customer_pipeline())
    paths.update(seller_pipeline())
    paths.update(product_pipeline())
    product_order_ids, order_items_order_ids, review_order_ids, payment_order_ids, order_ids = order_pipeline(paths)
    consistency_pipeline(product_order_ids, order_items_order_ids, review_order_ids, payment_order_ids, order_ids)
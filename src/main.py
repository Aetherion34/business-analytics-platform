from pipeline.customers_pipeline import run as customer_pipeline
from pipeline.products_pipeline import run as product_pipeline
from pipeline.sellers_pipeline import run as seller_pipeline
from pipeline.orders_pipeline import run as order_pipeline

def main():
    customer_pipeline()
    seller_pipeline()
    product_pipeline()
    order_pipeline()

if __name__ == "__main__":
    main()
    
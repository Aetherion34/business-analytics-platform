from pipeline.customers_pipeline import run as customer_pipeline
from pipeline.products_pipeline import run as product_pipeline
from pipeline.sellers_pipeline import run as seller_pipeline
from pipeline.orders_pipeline import run as order_pipeline
from database import process_all_tables as db_loader, engine as db_engine


def main():
    customer_pipeline()
    seller_pipeline()
    product_pipeline()
    order_pipeline()
    db_loader(db_engine)

if __name__ == "__main__":
    main()
    
from pathlib import Path
import data_processing.loader as Loader
BASE_DIR = Path(__file__).resolve().parent.parent
orders = Loader.load_orders(BASE_DIR / "data" / "raw" / "olist_orders_dataset.csv")
customers = Loader.load_customers(BASE_DIR / "data" / "raw" / "olist_customers_dataset.csv")
sellers = Loader.load_customers(BASE_DIR / "data" / "raw" / "data/raw/olist_sellers_dataset.csv")
products = Loader.load_products(BASE_DIR / "data" / "raw" / "data/raw/olist_products_dataset.csv")
order_items = Loader.load_order_items(BASE_DIR / "data" / "raw" / "data/raw/olist_order_items_dataset.csv")
order_payments = Loader.load_order_items(BASE_DIR / "data" / "raw" / "data/raw/olist_order_payments_dataset.csv")
order_reviews = Loader.load_order_items(BASE_DIR / "data" / "raw" / "data/raw/olist_order_reviews_dataset.csv")


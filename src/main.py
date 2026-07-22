from pathlib import Path
from data_processing.loader import load_orders
BASE_DIR = Path(__file__).resolve().parent.parent
orders = load_orders(BASE_DIR / "data" / "raw" / "olist_orders_dataset.csv")

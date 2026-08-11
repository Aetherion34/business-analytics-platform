from pathlib import Path
import ingestion.loader as Loader
BASE_DIR = Path(__file__).resolve().parents[2]
DATA_DIR = BASE_DIR / "data" / "raw"
from data_processing.validators import SellersValidator
from data_processing.cleaners import SellersCleaner
def run():
    sellers = Loader.load_sellers(DATA_DIR / "olist_sellers_dataset.csv")
    sellers_validator = SellersValidator(sellers)
    sellers_cleaner = SellersCleaner(sellers)
    report = sellers_validator.validate()
    sellers_cleaner.clean(report)
    return {"sellers" : "data/processed/sellers_list.csv"}

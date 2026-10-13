from pathlib import Path
import data_processing.ingestion.csv_reader as Loader
BASE_DIR = Path(__file__).resolve().parents[3]
DATA_DIR = BASE_DIR / "data" / "raw"
from data_processing.processing_core.validators import SellersValidator
from data_processing.processing_core.cleaners import SellersCleaner
def run():
    sellers = Loader.load_sellers(DATA_DIR / "olist_sellers_dataset.csv")
    sellers_validator = SellersValidator(sellers)
    sellers_cleaner = SellersCleaner(sellers)
    report = sellers_validator.validate()
    sellers_cleaner.clean(report)
    return {"sellers" : "data/processed/sellers_list.csv"}

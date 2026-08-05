from pathlib import Path
import ingestion.loader as Loader
from data_processing.cleaners import CustomerCleaner, GeolocationCleaner
from data_processing.validators import CustomersValidator, GeolocationValidator

BASE_DIR = Path(__file__).resolve().parents[2]
DATA_DIR = BASE_DIR / "data" / "raw"


def run():
    customers = Loader.load_customers(DATA_DIR / "olist_customers_dataset.csv")
    customer_validator = CustomersValidator(customers)
    customer_cleaner = CustomerCleaner(customers)
    customers_report = customer_validator.validate()
    customer_cleaner.clean(customers_report)

    geolocations = Loader.load_geolocation(DATA_DIR / "olist_geolocation_dataset.csv")
    geolocation_validator = GeolocationValidator(geolocations)
    geolocation_cleaner = GeolocationCleaner(geolocations)
    geolocations_report = geolocation_validator.validate()
    geolocation_cleaner.clean(geolocations_report)
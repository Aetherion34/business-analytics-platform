from pathlib import Path
import ingestion.loader as Loader
from data_processing.cleaners import (
    ProductCleaner,
    ProductCategoryNameTranslationCleaner,
)
from data_processing.validators import (
    ProductsValidator,
    ProductCategoryNameTranslationValidator,
)

BASE_DIR = Path(__file__).resolve().parents[2]
DATA_DIR = BASE_DIR / "data" / "raw"


def run():
    products = Loader.load_products(DATA_DIR / "olist_products_dataset.csv")
    products_validator = ProductsValidator(products)
    products_cleaner = ProductCleaner(products)
    products_report = products_validator.validate()
    products_cleaner.clean(products_report)

    product_category_translations = Loader.load_product_category_translations(
        DATA_DIR / "olist_product_category_name_translation.csv"
    )
    translations_validator = ProductCategoryNameTranslationValidator(product_category_translations)
    translations_cleaner = ProductCategoryNameTranslationCleaner(product_category_translations)
    translations_report = translations_validator.validate()
    translations_cleaner.clean(translations_report)
    return {"products" : "data/processed/products_list.csv"}
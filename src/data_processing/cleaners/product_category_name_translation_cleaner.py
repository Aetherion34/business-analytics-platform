import pandas as pd
import json
from rules.product_category_name_translation_rules import  REQUIRED_COLUMNS

class ProductCategoryTranslationCleaner:
    def __init__(self,translations):
        self.translations = translations

    def clean(self, error_report):
        self.save_report(error_report)

        for column in REQUIRED_COLUMNS:
            self.normalize_text(column)
            self.remove_missing_values(column)

        self.remove_duplicate_category_name()

        self.save_clean_data()

    def normalize_text(self, column):
        self.translations = self.translations[column].str.astype("string").str.strip().str.lower()

    def remove_missing_values(self, column):
        mask = self.translations[column].isna()
        self.translations = self.translations.loc[~mask]

    def remove_duplicate_category_name(self):
        mask = self.translations.duplicated("product_category_name", keep = False)
        self.translations = self.translations.loc[~mask]

    def save_report(self, error_report):
        serializable = {product_name : list(errors) for product_name, errors in error_report.items()}
        with open("data/errors/product_category_name_translation_errors_report.json", "w") as f:
            json.dump(serializable, f, indent = 4)

    def save_clean_data(self):
        self.translations.to_csv("data/processed/product_category_name_translation_list.csv", index = False)
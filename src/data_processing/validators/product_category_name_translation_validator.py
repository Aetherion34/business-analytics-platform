import pandas as pd
from rules.product_category_name_translation_rules import  REQUIRED_COLUMNS
class ProductCategoryTranslationValidator:
    def __init__(self,translations):
        self.translations = translations

    def validate(self):
        errors = []
        for column in REQUIRED_COLUMNS:
            errors.append(self.check_missing_values(column))

        errors.append(self.check_duplicate_category_name())

        all_errors = pd.concat(errors)

        errors_by_order = all_errors.groupby(level = 0).apply(set).to_dict()

        return errors_by_order


    def check_missing_values(self, column):
        mask = self.translations[column].isna()
        index = self.translations.loc[mask, "product_category_name"]
        return pd.Series(f"missing {column}", index = index)

    def check_duplicate_category_name(self):
        mask = self.translations.duplicated("product_category_name", keep = False)
        index = self.translations.loc[mask, "product_category_name"]
        return pd.Series(f"product_category_name should be unique", index = index)
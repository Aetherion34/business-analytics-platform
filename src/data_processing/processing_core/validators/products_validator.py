import pandas as pd


class ProductsValidator:
    def __init__(self, products):
        self.products = products

    def validate(self):
        errors = [
            self.check_missing("product_id"),
            self.check_duplicate_product_id(),
            self.check_missing("product_category_name"),
        ]

        numeric_columns = [
            "product_name_length",
            "product_description_length",
            "product_photos_qty",
            "product_weight_g",
            "product_length_cm",
            "product_height_cm",
            "product_width_cm"
        ]

        for column in numeric_columns:
            errors.append(self.check_missing(column))
            errors.append(self.check_positive_values(column))

        all_errors = pd.concat(errors)
        errors_by_product = all_errors.groupby(level=0).apply(set).to_dict()

        return errors_by_product

    def check_missing(self, column: str):
        mask = self.products[column].isna()
        product_ids = self.products[mask]["product_id"]

        return pd.Series(f"Missing {column}",index=product_ids)

    def check_positive_values(self, column: str):
        mask = self.products[column] <= 0
        product_ids = self.products[mask]["product_id"]

        return pd.Series(f"{column} must be positive", index=product_ids)

    def check_duplicate_product_id(self):
        mask = self.products["product_id"].duplicated(keep=False)
        product_ids = self.products[mask]["product_id"]

        return pd.Series("Duplicated product id value",index=product_ids)
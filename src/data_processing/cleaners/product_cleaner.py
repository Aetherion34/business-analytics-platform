import pandas as pd
import json
class ProductCleaner:
    def __init__(self, products):
        self.products = products

    def clean(self, error_list):
        self.normalize_product_category_name()

        self.remove_empty_values("product_id")
        self.remove_empty_values("product_category_name")

        self.remove_product_id_duplicates()

        numeric_columns = [
            "product_name_length",
            "product_description_length",
            "product_photo_qty",
            "product_weight_g",
            "product_length_cm",
            "product_height_cm",
            "product_width_cm"
        ]

        for column in numeric_columns:
            self.remove_empty_values(column)
            self.remove_negative_values(column)

        self.save_report(error_list)
        self.save_clean_data()

        return self.products
    def remove_empty_values(self, column: str):
        self.products[column] =(
            self.products[column]
            .replace(r"^\s*$", pd.NA, regex=True)
        )
        self.products = self.products.dropna(subset=[column])

    def remove_negative_values(self, column):
        mask = (self.products[column] <= 0)
        self.products = self.products[~mask]


    def remove_product_id_duplicates(self):
        self.products = self.products.drop_duplicates(
            subset = ["product_id"],
            keep = "first"
        )
    def normalize_product_category_name(self):
        self.products["product_category_name"] = (
            self.products["product_category_name"]
            .astype("string")
            .str.lower().
            str.strip())

    def save_report(self, error_list):
        serialized = {product_id: list(errors) for product_id, errors in error_list.items()}
        with open("data/errors/product_errors_report.json", "w") as f:
            json.dump(serialized, f, indent = 4,ensure_ascii=False)

    def save_clean_data(self):
        self.products.to_csv("data/processed/products_list.csv", index = False)



import pandas as pd
import json
from rules.order_items_rules import REQUIRED_COLUMNS, POSITIVE_COLUMNS
class OrderItemsCleaner:
    def __init__(self, order_ids, product_ids, seller_ids, order_items):
            self.order_ids = order_ids
            self.product_ids = product_ids
            self.seller_ids = seller_ids
            self.order_items= order_items
    def clean(self,error_report):
        references = {
            "order_id": self.order_ids,
            "product_id": self.product_ids,
            "seller_id": self.seller_ids
        }
        self.normalize_dates()
        self.clean_invalid_shipping_date()

        for column, valid_values in references.items():
            self.clean_invalid_reference(valid_values, column)

        for column in REQUIRED_COLUMNS:
            self.clean_missing_values(column)

        for column in POSITIVE_COLUMNS:
            self.clean_negative_values(column)

        self.clean_invalid_order_item_key()

        self.save_report(error_report)
        self.save_clean_data()
    def normalize_dates(self):
        self.order_items["shipping_limit_date"] = pd.to_datetime(self.order_items["shipping_limit_date"], errors = "coerce")
        
    def clean_invalid_reference(self, values, column):
        mask = self.order_items[column].isin(values)
        self.order_items = self.order_items[mask]


    def clean_missing_values(self, column):
        mask = self.order_items[column].isna()
        self.order_items = self.order_items[~mask]

    def clean_negative_values(self, column):
        mask = self.order_items[column] <= 0
        self.order_items = self.order_items[~mask]

    def clean_invalid_shipping_date(self):
        mask = self.order_items["shipping_limit_date"].isna()
        self.order_items = self.order_items[~mask]

    def clean_invalid_order_item_key(self):
        self.order_items  = self.order_items.drop_duplicates(
            subset = ["order_id", "order_item_id"],
            keep = False
        )

    def save_report(self, error_report):
        serializable = {f"{order_id}|{order_item_id}": list(errors) for (order_id,order_item_id),errors in error_report.items()}
        with open("data/errors/order_items_errors_report.json", "w") as f:
            json.dump(serializable, f, indent = 4)

    def save_clean_data(self):
        self.order_items.to_csv("data/processed/order_items_list.csv", index = False)
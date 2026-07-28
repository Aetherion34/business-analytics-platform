import pandas as pd
import json
from constants import VALID_STATUS,DEFAULT_STATUS
class OrdersCleaner:
    def __init__(self, orders):
        self.orders = orders

    def clean(self, error_list):
        self.remove_duplicates()
        self.remove_invalid_dates()
        self.remove_invalid_date_sequence()
        self.fix_invalid_status()

        self.save_report(error_list)
        self.save_clean_data()
        

    def remove_duplicates(self):
        self.orders = self.orders.drop_duplicates(subset="order_id", keep="first")

    def fix_invalid_status(self):
        mask  = ~self.orders["order_status"].isin(VALID_STATUS)
        self.orders.loc[mask, "order_status"] = DEFAULT_STATUS

    def remove_invalid_dates(self):
        mask = ~self.orders[[
            "order_purchase_timestamp", 
            "order_approved_at",
            "order_delivered_carrier_date", 
            "order_delivered_customer_date"
            ]].isna().any(axis = 1)
        self.orders = self.orders[mask]
    def remove_invalid_date_sequence(self):
        mask = ~(
            (self.orders["order_purchase_timestamp"] > self.orders["order_approved_at"]) |
            (self.orders["order_approved_at"] > self.orders["order_delivered_carrier_date"]) |
            (self.orders["order_delivered_carrier_date"] > self.orders["order_delivered_customer_date"])
        )
        self.orders = self.orders[mask]

    def save_report(self, error_list):
        serializable = {order_id: list(errors) for order_id, errors in error_list.items()}
        with open("data/errors/order_errors_report.json", "w") as f:
            json.dump(serializable, f, indent=4, ensure_ascii=False)

    def save_clean_data(self):
        self.orders.to_csv("data/processed/orders_list.csv", index = False)

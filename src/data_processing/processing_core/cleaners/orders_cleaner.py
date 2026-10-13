import pandas as pd
import json
from data_processing.processing_core.constants import VALID_STATUS,DEFAULT_STATUS, REQUIRED_DATES_BY_STATUS
class OrdersCleaner:
    def __init__(self, orders, customer_ids):
        self.orders = orders
        self.customer_ids = customer_ids

    def clean(self, error_list):
        self.remove_duplicates()
        self.remove_invalid_date()
        self.remove_invalid_date_sequence()
        self.fix_invalid_status()
        self.remove_invalid_customer_id()

        self.save_report(error_list)
        self.save_clean_data()
        
    def remove_duplicates(self):
        self.orders = self.orders.drop_duplicates(subset="order_id", keep="first")

    def fix_invalid_status(self):
        mask  = ~self.orders["order_status"].isin(VALID_STATUS)
        self.orders.loc[mask, "order_status"] = DEFAULT_STATUS

    def remove_invalid_customer_id(self):
        mask = self.orders["customer_id"].isin(self.customer_ids)
        self.orders = self.orders[mask]

    def remove_invalid_date(self):
        mask = pd.Series(False, index=self.orders.index)
        for status, required_columns in REQUIRED_DATES_BY_STATUS.items():
            correct_status = self.orders.loc[self.orders["order_status"] == status]
            invalid_dates = correct_status[required_columns].isna().any(axis=1)

            mask.loc[invalid_dates.index] |= invalid_dates
        
        self.orders = self.orders.loc[~mask]

    def remove_invalid_date_sequence(self):
        date_pairs = [
            ("order_purchase_timestamp", "order_approved_at"),
            ("order_approved_at", "order_delivered_carrier_date"),
            ("order_delivered_carrier_date", "order_delivered_customer_date"),
        ]
        invalid_mask = pd.Series(False, index=self.orders.index)

        for first, second in date_pairs:
            date_present = (self.orders[first].notna() & self.orders[second].notna())
            invalid_mask |= (date_present & (self.orders[first] > self.orders[second]))
        
        self.orders = self.orders.loc[~invalid_mask]
    
    
    def save_report(self, error_list):
        serializable = {order_id: list(errors) for order_id, errors in error_list.items()}
        with open("data/errors/order_errors_report.json", "w") as f:
            json.dump(serializable, f, indent=4, ensure_ascii=False)

    def save_clean_data(self):
        self.orders.to_csv("data/processed/order_list.csv", index = False)

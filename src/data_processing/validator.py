"""
Validator module

This module is responsible for checking the quality and consistency
of raw data before it enters the cleaning process.

It applies business rules to identify invalid records, such as:
- duplicated IDs
- missing required values
- inconsistent dates
- invalid relationships between fields

The validator does not modify the original data.
It separates valid records from invalid records and generates
an error report for further analysis.
"""
import pandas as pd
from constants import VALID_STATUS

class Validator():
    def __init__(self, orders = None):
        self.orders = pd.DataFrame({
            "order_id": [1, 1, 2, 3, 4],
            "order_status": ["delivered", "delivered", "delivered", "invalid_status_xyz", "shipped"],
            "order_approved_at": [
                "2024-01-01", "2024-01-01", "2024-01-02", "2024-01-03", "2024-01-05"
            ],
            "order_delivered_carrier_date": [
                "2024-01-02", "2024-01-02", "2024-01-03", "2024-01-01", None
            ],
            "order_delivered_customer_date": [
                "2024-01-03", "2024-01-03", "2024-01-04", "2024-01-05", "2024-01-06"
            ]
        })
        self.orders["order_purchase_timestamp"] = pd.to_datetime(self.orders["order_purchase_timestamp"])
        self.orders["order_approved_at"] = pd.to_datetime(self.orders["order_approved_at"])
        self.orders["order_delivered_carrier_date"] = pd.to_datetime(self.orders["order_delivered_carrier_date"])
        self.orders["order_delivered_customer_date"] = pd.to_datetime(self.orders["order_delivered_customer_date"])

    def validate(self):
        all_errors = pd.concat([
            self.check_duplicates(),
            self.check_valide_status(),
            self.invalid_date(),
            self.invalid_date_order(),
        ])
        errors_by_order = all_errors.groupby(level=0).apply(set).to_dict()
        return errors_by_order

    def check_duplicates(self):
        duplicate_mask = self.orders["order_id"].duplicated(keep=False)
        errors_df = self.orders[duplicate_mask]
        order_ids = errors_df["order_id"]
        return pd.Series("duplicate_order_id", index=order_ids)

    def check_valide_status(self):
        invalid_rows = self.orders[~self.orders["order_status"].isin(VALID_STATUS)]
        order_ids = invalid_rows["order_id"]
        return pd.Series("invalid_status", index=order_ids)

    def invalid_date(self):
        mask = self.orders[[
            "order_purchase_timestamp", "order_approved_at", "order_delivered_carrier_date", "order_delivered_customer_date"
        ]].isna().any(axis=1)
        invalid_dates = self.orders[mask]
        order_ids = invalid_dates["order_id"]
        return pd.Series("invalid_date", index=order_ids)

    def invalid_date_order(self):
        invalid_dates_order = self.orders[
            (self.orders["order_purchase_timestamp"] > self.orders["order_approved_at"]) |
            (self.orders["order_approved_at"] > self.orders["order_delivered_carrier_date"]) |
            (self.orders["order_delivered_carrier_date"] > self.orders["order_delivered_customer_date"])
        ]
        order_ids = invalid_dates_order["order_id"]
        return pd.Series("invalid_date_sequence", index=order_ids)


if __name__ == "__main__":
    v = Validator()
    print(v.validate())
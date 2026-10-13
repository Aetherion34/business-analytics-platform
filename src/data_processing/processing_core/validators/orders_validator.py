import pandas as pd
from data_processing.processing_core.constants import VALID_STATUS,  REQUIRED_DATES_BY_STATUS

class OrdersValidator():
    def __init__(self, orders, customer_ids):
        self.orders = orders
        self.customer_ids = customer_ids
        self.orders["order_purchase_timestamp"] = pd.to_datetime(self.orders["order_purchase_timestamp"])
        self.orders["order_approved_at"] = pd.to_datetime(self.orders["order_approved_at"])
        self.orders["order_delivered_carrier_date"] = pd.to_datetime(self.orders["order_delivered_carrier_date"])
        self.orders["order_delivered_customer_date"] = pd.to_datetime(self.orders["order_delivered_customer_date"])

    def validate(self):
        all_errors = pd.concat([
            self.check_invalid_customer_id(),
            self.check_duplicates(),
            self.check_valide_status(),
            self.check_invalid_date(),
            self.check_invalid_date_sequence(),
            
        ])
        errors_by_order = all_errors.groupby(level=0).apply(set).to_dict()
        return errors_by_order


    def check_invalid_customer_id(self):
        mask = ~self.orders["customer_id"].isin(self.customer_ids)
        order_ids = self.orders.loc[mask, "order_id"]
        return pd.Series("Invalid customer id", index=order_ids.values)

    def check_duplicates(self):
        duplicate_mask = self.orders["order_id"].duplicated(keep=False)
        errors_df = self.orders[duplicate_mask]
        order_ids = errors_df["order_id"]
        return pd.Series("duplicate order id", index=order_ids.values)

    def check_valide_status(self):
        invalid_rows = self.orders[~self.orders["order_status"].isin(VALID_STATUS)]
        order_ids = invalid_rows["order_id"]
        return pd.Series("invalid status", index=order_ids.values)

    def check_invalid_date(self):
        invalid_order_ids = []

        for status, required_columns in REQUIRED_DATES_BY_STATUS.items():
            correct_status = self.orders.loc[
                self.orders["order_status"] == status
            ]

            mask = correct_status[required_columns].isna().any(axis=1)

            invalid_order_ids.extend(
                correct_status.loc[mask, "order_id"].tolist()
            )

        return pd.Series("invalid date", index=invalid_order_ids)

    def check_invalid_date_sequence(self):
        date_pairs = [
            ("order_purchase_timestamp", "order_approved_at"),
            ("order_approved_at", "order_delivered_carrier_date"),
            ("order_delivered_carrier_date", "order_delivered_customer_date"),
        ]
        invalid_mask = pd.Series(False, index=self.orders.index)

        for first, second in date_pairs:
            date_present = (self.orders[first].notna() & self.orders[second].notna())
            invalid_mask |= (date_present & (self.orders[first] > self.orders[second]))
        invalid_order_ids = self.orders.loc[invalid_mask, "order_id"]

        return pd.Series("invalid date sequence", index=invalid_order_ids)
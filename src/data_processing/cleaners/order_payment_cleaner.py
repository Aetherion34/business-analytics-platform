import pandas as pd
import json
from constants import VALID_PAYMENT_TYPES
from rules.order_payments_rules import POSITIVE_COLUMNS, REQUIRED_COLUMNS
class OrderPaymentCeaner:
    def __init__(self, order_ids, order_payments):
        self.order_ids = order_ids
        self.order_payments = order_payments

        
    def clean(self,error_report):
        self.save_report(error_report)
        self.clean_invalid_order_ids()
        self.clean_invalid_payment_type()

        for column in REQUIRED_COLUMNS:
            self.clean_missing_values(column)
        
        for column in POSITIVE_COLUMNS:
            self.clean_negative_values(column)

        self.remove_duplicate_payment_sequences()
        self.clean_invalid_payment_sequence()

        self.save_clean_data()
        

    def clean_missing_values(self, column):
        mask = self.order_payments[column].isna()
        self.order_payments = self.order_payments[~mask]

    def clean_negative_values(self, column):
        mask = self.order_payments[column] <= 0
        self.order_payments = self.order_payments[~mask]

    def clean_invalid_order_ids(self):
        mask = self.order_payments["order_id"].isin(self.order_ids)
        self.order_payments = self.order_payments[mask]

    def clean_invalid_payment_type(self):
        mask = self.order_payments["payment_type"].isin(VALID_PAYMENT_TYPES)
        self.order_payments = self.order_payments[mask]

    def remove_duplicate_payment_sequences(self):
        self.order_payments = self.order_payments.drop_duplicates(
            subset = ["order_id", "payment_sequence"],
            keep = False
        )

    def clean_invalid_payment_sequence(self):
        def check(seq):
            seq = seq.sort_values()
            return seq.diff().iloc[1:].eq(1).all()
        mask = self.order_payments.groupby("order_id")["payment_sequence"].apply(check)
        self.order_payments = self.order_payments[self.order_payments["order_id"].isin(mask[mask].index)]

    def save_report(self, error_report):
        serializable = {f"{order_id}|{payment_sequential}" : list(errors) for (order_id,payment_sequential), errors in error_report.items()}
        with open("data/errors/order_payments_errors_report.json", "w") as f:
            json.dump(serializable, f, indent = 4)

    def save_clean_data(self):
        self.order_payments.to_csv("data/processed/order_payments_list.csv", index = False)


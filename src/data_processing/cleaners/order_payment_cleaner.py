import pandas as pd
import json
from data_processing.constants import VALID_PAYMENT_TYPES
from data_processing.rules.order_payments_rules import POSITIVE_COLUMNS, REQUIRED_COLUMNS
class OrderPaymentCleaner:
    def __init__(self, order_payments, payments_total):
        self.order_payments = order_payments
        self.payments_total = payments_total

        
    def clean(self,error_report):
        self.save_report(error_report)
        self.clean_payment_consistency()
        self.clean_invalid_payment_type()

        for column in REQUIRED_COLUMNS:
            self.clean_missing_values(column)
        
        for column in POSITIVE_COLUMNS:
            self.clean_negative_values(column)

        self.remove_duplicate_payment_sequentials()
        self.clean_invalid_payment_sequential()

        self.save_clean_data()
        
    def clean_payment_consistency(self):
        total_expected_payment = self.payments_total.groupby(
            "order_id"
        )[["price", "freight_value"]].sum().reset_index()

        total_payment = self.order_payments.groupby(
            "order_id"
        )["payment_value"].sum().reset_index()

                
        result = total_expected_payment.merge(
            total_payment,
            on="order_id"
        )

        result["expected_payment"] = result["price"] + result["freight_value"]
        result = result.drop(columns=["price", "freight_value"])

        mask = (result["expected_payment"] - result["payment_value"]).abs() > 1

        invalid_order_ids = result[mask]["order_id"]

        self.order_payments = self.order_payments[~(self.order_payments["order_id"].isin(invalid_order_ids))]

    def clean_missing_values(self, column):
        mask = self.order_payments[column].isna()
        self.order_payments = self.order_payments[~mask]

    def clean_negative_values(self, column):
        mask = self.order_payments[column] <= 0
        self.order_payments = self.order_payments[~mask]

    def clean_invalid_payment_type(self):
        mask = self.order_payments["payment_type"].isin(VALID_PAYMENT_TYPES)
        self.order_payments = self.order_payments[mask]
    
    def remove_duplicate_payment_sequentials(self):
        self.order_payments = self.order_payments.drop_duplicates(
            subset=["order_id", "payment_sequential"],
            keep=False
        )
    def clean_invalid_payment_sequential(self):
        def check(seq):
            seq = seq.sort_values()
            return seq.diff().iloc[1:].eq(1).all()

        mask = self.order_payments.groupby("order_id")["payment_sequential"].apply(check)

        self.order_payments = self.order_payments[
            self.order_payments["order_id"].isin(mask[mask].index)
        ]
    def save_report(self, error_report):
        serializable = {f"{order_id}|{payment_sequential}" : list(errors) for (order_id,payment_sequential), errors in error_report.items()}
        with open("data/errors/order_payments_errors_report.json", "w") as f:
            json.dump(serializable, f, indent = 4)

    def save_clean_data(self):
        self.order_payments.to_csv("data/processed/order_payments_list.csv", index = False)


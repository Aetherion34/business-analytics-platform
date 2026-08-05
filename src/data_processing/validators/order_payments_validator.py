import pandas as pd
from data_processing.constants import VALID_PAYMENT_TYPES
from data_processing.rules.order_payments_rules import POSITIVE_COLUMNS, REQUIRED_COLUMNS
class OrderPaymentsValidator:
    def __init__(self, order_payments, order_ids):
        self.order_payments = order_payments
        self.order_ids = order_ids
    def validate(self):
        errors = [
            self.check_order_id(),
            self.check_payment_type(),
            self.check_payment_sequential_key_uniqueness(),
            self.check_payment_sequential(),
        ]
        for column in REQUIRED_COLUMNS:
            errors.append(self.check_missing_values(column))

        for column in POSITIVE_COLUMNS:
            errors.append(self.check_positive_values(column))

        all_errors = pd.concat(errors)
        errors_by_order = all_errors.groupby(level=[0,1]).apply(set).to_dict()
        return errors_by_order

    def check_missing_values(self, column):
        mask = self.order_payments[column].isna()
        index = self.order_payments.loc[mask].set_index(["order_id","payment_sequential"]).index
        return pd.Series(f"missing {column}", index = index)

    def check_positive_values(self, column):
        mask = self.order_payments[column] > 0
        index = self.order_payments.loc[~mask].set_index(["order_id","payment_sequential"]).index
        return pd.Series(f"{column} must be positive", index = index)

    def check_payment_type(self):
        mask = (self.order_payments["payment_type"].isin(VALID_PAYMENT_TYPES))
        index = self.order_payments.loc[~mask].set_index(["order_id","payment_sequential"]).index
        return pd.Series(f"invalid payment type", index = index)

    def check_order_id(self):
        mask = (self.order_payments["order_id"].isin(self.order_ids))
        index = self.order_payments.loc[~mask].set_index(["order_id","payment_sequential"]).index
        return pd.Series(f"invalid order id", index = index)

    def check_payment_sequential_key_uniqueness(self):
        mask = self.order_payments.duplicated(
            subset=["order_id","payment_sequential"],
            keep=False
        )
        index = self.order_payments.loc[mask].set_index(["order_id","payment_sequential"]).index
        return pd.Series(f"payment sequential must be unique for each order", index = index)

    def check_payment_sequential(self):
        def check(seq):
            seq = seq.sort_values()
            return seq.diff().iloc[1:].eq(1).all()
        result = self.order_payments.groupby("order_id")["payment_sequential"].apply(check)
        bad_orders = result[~result].index
        mask = self.order_payments[self.order_payments["order_id"].isin(bad_orders)]
        index = mask.set_index(["order_id","payment_sequential"]).index
        return pd.Series(f"Payment sequence is not consecutive", index = index)


    

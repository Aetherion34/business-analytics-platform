"""
Validator module

This module is responsible for checking the quality and consistency
of raw data before it enters the cleaning process.

It applies business rules to identify invalid records, such as:
- missing required values
- inconsistent data
- invalid relationships between fields

The validator does not modify the original data.
It separates valid records from invalid records and generates
an error report for further analysis.
"""
import pandas as pd
from data_processing.constants import VALID_STATES
class CustomersValidator:
    def __init__(self, customers):
        self.customers = customers

    def validate(self):
        all_errors = pd.concat([
            self.check_inconsistent_customer_data(),
            self.check_customer_zip_code_prefix(),
            self.check_customer_city(),
            self.check_customer_state(),
        ])
        errors_by_order = all_errors.groupby(level=0).apply(set).to_dict()
        return errors_by_order

    def check_inconsistent_customer_data(self):
        mask = self.customers.duplicated(
            subset = ["customer_unique_id", "customer_zip_code_prefix", "customer_city", "customer_state"],
            keep = False
        )
        customers_id = self.customers[mask].index
        return pd.Series("Inconsistent customer data", index = customers_id.values)

    def check_customer_zip_code_prefix(self):
        mask = self.customers["customer_zip_code_prefix"].isna()
        errors = self.customers[mask]
        customers_id = errors["customer_id"]
        return pd.Series("Invalid zip code prefix", index = customers_id.values)

    def check_customer_city(self):
        mask = self.customers["customer_city"].isna()
        errors = self.customers[mask]
        customers_id = errors["customer_id"]
        return pd.Series("Invalid city", index = customers_id.values)

    def check_customer_state(self):
        mask = (
            self.customers["customer_state"].isna()
            | ~self.customers["customer_state"].isin(VALID_STATES)
        )
        errors = self.customers[mask]
        customers_id = errors["customer_id"]
        return pd.Series("Invalid state", index = customers_id.values)
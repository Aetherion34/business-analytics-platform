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
from constants import VALID_STATES
class Customers_validator:
    def __init__(self, customers):
        self.customers = customers

    def check_inconsistent_customer_data(self):
        grouped = self.customers.groupby("customer_unique_id")
        count_uniques = grouped[["customer_zip_code_prefix", "customer_city", "customer_state"]].nunique()
        errors = (count_uniques > 1).any(axis=1)
        customers_id = errors.index
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
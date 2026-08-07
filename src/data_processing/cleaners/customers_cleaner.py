from data_processing.constants import VALID_STATES
import pandas as pd
import json
class CustomerCleaner():
    def __init__(self, customers):
        self.customers = customers

    def clean(self, error_list):
        self.normalize_customer_city()
        self.normalize_customer_zip()
        self.remove_invalid_states()

        self.remove_duplicate_customers()

        self.remove_empty_zcp()
        self.remove_empty_city()

        self.save_report(error_list)
        self.save_clean_data()


    def normalize_customer_city(self):
        self.customers["customer_city"] = (
        self.customers["customer_city"]
        .str.strip()
        .replace("", pd.NA)
        .str.upper()
        .str.replace(r"\s+", " ", regex=True)
        )
    def normalize_customer_zip(self):
        self.customers["customer_zip_code_prefix"] = (
        self.customers["customer_zip_code_prefix"]
        .astype("string")
        .str.strip()
        .replace("", pd.NA)
        .str.title()
        .str.replace(r"\s+", " ", regex=True)
        )

    def remove_empty_zcp(self):
        mask = self.customers["customer_zip_code_prefix"].isna()
        self.customers = self.customers[~mask]

    def remove_empty_city(self):
        mask = self.customers["customer_city"].isna()
        self.customers = self.customers[~mask]

    def remove_invalid_states(self):
        mask = (self.customers["customer_state"].isna() |
        ~self.customers["customer_state"].isin(VALID_STATES))
        self.customers = self.customers[~mask]
    # Infer most likely customer values using mode.
    # Ambiguous cases with multiple modes are handled later.
    def remove_duplicate_customers(self):
        mask = self.customers.duplicated(
            subset = ["customer_unique_id", "customer_zip_code_prefix", "customer_city", "customer_state"],
            keep = False
        )
        self.customers = self.customers[~mask]

    def save_report(self, error_list):
        serializable ={seller_id : list(errors) for seller_id, errors in error_list.items()} 
        with open("data/errors/customer_errors_report.json", "w") as f:
            json.dump(serializable, f, indent = 4)
    
    def save_clean_data(self):
        self.customers.to_csv("data/processed/customers_list.csv", index = False)
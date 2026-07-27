from constants import VALID_STATES
import pandas as pd
class Customer_cleaner():
    def __init__(self, customers):
        self.customers = customers

    def clean_customers(self):
        self.normalize_customer_city()
        self.normalize_customer_zip()
        self.remove_invalid_states()

        inferred = self.infer_customer_values()
        self.apply_customer_corrections(inferred)

        self.remove_empty_zcp()
        self.remove_empty_city()

        return self.customers


    def normalize_customer_city(self):
        self.customers["customer_city"] = (
        self.customers["customer_city"]
        .str.strip()
        .replace("", pd.NA)
        .str.title()
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
    def infer_customer_values(self):
        grouped = self.customers.groupby("customer_unique_id")
        count_uniques = grouped[["customer_zip_code_prefix", "customer_city", "customer_state"]].nunique()
        errors = (count_uniques > 1).any(axis=1)
        invalid_customers_id = errors[errors].index
        customers_id_mask = (self.customers["customer_unique_id"].isin(invalid_customers_id))
        Invalid_customers = self.customers[customers_id_mask]
        invcu_grouped = Invalid_customers.groupby("customer_unique_id")
        inferred_customer_values = invcu_grouped.agg(lambda x: x.mode())
        return inferred_customer_values



    def apply_customer_corrections(self, inferred_customer_values):
        counts = inferred_customer_values.groupby("customer_unique_id").size()
        valid_customers = counts[counts == 1].index
        ambiguous_customers = counts[counts > 1].index
        self.customers = self.customers[~self.customers["customer_unique_id"].isin(ambiguous_customers)]
        valid_customers_value = inferred_customer_values.loc[
            inferred_customer_values.index.isin(valid_customers)
        ]
        customers_with_inferred_values  = self.customers.merge(
            valid_customers_value,
            on="customer_unique_id",
            how="left",
            suffixes=("", "_correct")
        )
        customers_with_inferred_values["customer_zip_code_prefix"] = (customers_with_inferred_values["customer_zip_code_prefix_correct"].fillna(customers_with_inferred_values["customer_zip_code_prefix"]))
        customers_with_inferred_values["customer_city"] = (customers_with_inferred_values["customer_city_correct"].fillna(customers_with_inferred_values["customer_city"]))
        customers_with_inferred_values["customer_state"] = (customers_with_inferred_values["customer_state_correct"].fillna(customers_with_inferred_values["customer_state"]))
        customers_with_inferred_values= customers_with_inferred_values.drop(columns=["customer_zip_code_prefix_correct", "customer_city_correct", "customer_state_correct"])
        self.customers = customers_with_inferred_values
        return self.customers
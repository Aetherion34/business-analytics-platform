import pandas as pd
from data_processing.constants import VALID_STATES
import json
class SellersCleaner():
    def __init__(self, sellers):
        self.sellers = sellers

    #TODO
    def clean(self, error_list):
        self.normalize_zcp()
        self.normalize_city()
        self.normalize_states()

        self.remove_invalid_seller()
        self.remove_invalid_zcp()
        self.remove_invalid_city()
        self.remove_invalid_states()

        self.save_report(error_list)
        self.save_clean_data()

    def normalize_zcp(self):
        formatted = (
        self.sellers["seller_zip_code_prefix"]
        .astype("string")
        .str.strip()
        .str.zfill(5)
        )
        self.sellers["seller_zip_code_prefix"] = formatted

    def normalize_city(self):
        formatted = (
        self.sellers["seller_city"]
        .str.strip()
        .replace("", pd.NA)
        .str.replace(r"\s+", " ", regex=True)
        .str.title()
        )
        self.sellers["seller_city"] = formatted

    def normalize_states(self):
        formatted =(
            self.sellers["seller_state"]
            .str.strip()
            .replace("", pd.NA)
            .str.replace(r"\s+", " ", regex=True)
            .str.title()
        )
        self.sellers["seller_state"] = formatted

    def remove_invalid_seller(self):
        mask = (self.sellers["seller_id"].isna() | 
            self.sellers["seller_id"].duplicated(keep = "first"))
        self.sellers = self.sellers[~mask]

    def remove_invalid_zcp(self):
        mask = (self.sellers["seller_zip_code_prefix"].isna() |
                ~self.sellers["seller_zip_code_prefix"].str.match(r"^\d{5}$"))
        self.sellers = self.sellers[~mask]

    def remove_invalid_city(self):
        mask = self.sellers["seller_city"].isna()
        self.sellers = self.sellers[~mask]
    
    def remove_invalid_states(self):
        mask = (self.sellers["seller_state"].isna() | ~self.sellers["seller_state"].isin(VALID_STATES))
        self.sellers = self.sellers[~mask]

    def save_report(self, error_list):
        serializable = {seller_id: list(errors) for seller_id, errors in error_list.items()}
        with open("data/errors/sellers_error_report.json", "w") as f:
            json.dump(serializable, f, indent = 4)

    def save_clean_data(self):
        self.sellers.to_csv("data/processed/sellers_list.csv")
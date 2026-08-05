import pandas as pd
from data_processing.constants import VALID_STATES
class SellersValidator():
    def __init__(self,sellers):
        self.sellers = sellers
    def validate(self):
        all_errors = pd.concat([
            self.check_seller_id(),
            self.check_seller_zcp(),
            self.check_valid_city(),
            self.check_seller_state()
        ])
        errors_by_order = all_errors.groupby(level = 0).apply(set).to_dict()
        return errors_by_order
    def check_seller_id(self):
        mask = (self.sellers["seller_id"].isna() | 
                self.sellers["seller_id"].duplicated(keep = "first"))
        invalid_ids = self.sellers[mask]["seller_id"]
        return pd.Series("Invalid seller id", index = invalid_ids.values)

    def check_seller_zcp(self):
        mask = (self.sellers["seller_zip_code_prefix"].isna())
        invalid_ids = self.sellers[mask]["seller_id"]
        return pd.Series("Invalid seller zip code prefix", index = invalid_ids.values)
    def check_valid_city(self):
        mask = (self.sellers["seller_city"].isna())
        invalid_ids = self.sellers[mask]["seller_id"]
        return pd.Series("Invalid seller city", index = invalid_ids.values)
    def check_seller_state(self):
        mask = (self.sellers["seller_state"].isna() |
                self.sellers["seller_state"].isin(VALID_STATES))
        invalid_ids = self.sellers[mask]["seller_id"]
        return pd.Series("Invalid seller state", index = invalid_ids.values)
    
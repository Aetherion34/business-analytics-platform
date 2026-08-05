import pandas as pd
from data_processing.constants import VALID_STATES
from data_processing.rules.geolocation_rules import  REQUIRED_COLUMNS

class GeolocationValidator:
    def __init__(self, geolocation):
        self.geolocation = geolocation

    def validate(self):
        errors = [
            self.check_duplicates(),
            self.check_valid_zcp(),
            self.check_valid_state(),
            self.check_valide_lat(),
            self.check_valide_lng(),
            ]
        for column in REQUIRED_COLUMNS:
            errors.append(self.check_missing_values(column))

        all_errors = pd.concat(errors)

        errors_by_order = all_errors.groupby(level = 0).apply(set).to_dict()
        return errors_by_order
    
    def check_missing_values(self, column):
        mask = self.geolocation[column].isna()
        index = self.geolocation.loc[mask].index
        return pd.Series(f"missing {column}", index=index)

    def check_valid_zcp(self):
        mask = self.geolocation["geolocation_zip_code_prefix"].str.fullmatch(r"\d{5}", na = False)
        index = self.geolocation.loc[~mask].index
        return pd.Series(f"invalid zip code prefix", index=index)

    def check_valid_state(self):
        mask = self.geolocation["geolocation_state"].isin(VALID_STATES)
        index = self.geolocation.loc[~mask].index
        return pd.Series(f"invalid state", index=index)

    def check_valide_lat(self):
        mask = (
            (self.geolocation["geolocation_lat"] >= -90) &
            (self.geolocation["geolocation_lat"] <= 90)
        )
        index = self.geolocation.loc[~mask].index
        return pd.Series(f"invalid latitude", index=index)

    def check_valide_lng(self):
        mask = (
            (self.geolocation["geolocation_lng"] >= -180) &
            (self.geolocation["geolocation_lng"] <= 180)
        )
        index = self.geolocation.loc[~mask].index
        return pd.Series(f"invalid longitude", index=index)

    def check_duplicates(self):
        mask = self.geolocation.duplicated(keep = False)
        index = self.geolocation.loc[mask].index
        return pd.Series(f"duplicate geolocation row", index=index)
        

        

            

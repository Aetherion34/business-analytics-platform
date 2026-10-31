
import pandas as pd

from data_processing.processing_core.constants import VALID_STATES


class SellersValidator:

    def __init__(self, sellers, geolocations):
        self.sellers = sellers.copy()
        self.geolocations = geolocations.copy()

    def validate(self):
        all_errors = pd.concat([
            self.check_seller_id(),
            self.check_missing_seller_zcp(),
            self.check_seller_zcp(),
            self.check_valid_city(),
            self.check_seller_state()
        ])

        errors_by_seller = (
            all_errors.groupby(level=0)
            .apply(set)
            .to_dict()
        )

        return errors_by_seller

    def check_seller_id(self):
        mask = (
            self.sellers["seller_id"].isna()
            | self.sellers["seller_id"].duplicated(keep=False)
        )

        invalid_ids = self.sellers.loc[mask, "seller_id"]

        return pd.Series(
            "Invalid seller id",
            index=invalid_ids.values
        )

    def check_missing_seller_zcp(self):
        mask = self.sellers["seller_zip_code_prefix"].isna()

        invalid_ids = self.sellers.loc[mask, "seller_id"]

        return pd.Series(
            "Missing seller zip code prefix",
            index=invalid_ids.values
        )

    def check_seller_zcp(self):
        valid_zcps = self.geolocations[
            "geolocation_zip_code_prefix"
        ]

        mask = (
            self.sellers["seller_zip_code_prefix"].notna()
            & ~self.sellers["seller_zip_code_prefix"].isin(valid_zcps)
        )

        invalid_ids = self.sellers.loc[mask, "seller_id"]

        return pd.Series(
            "Invalid seller zip code prefix",
            index=invalid_ids.values
        )

    def check_valid_city(self):
        mask = self.sellers["seller_city"].isna()

        invalid_ids = self.sellers.loc[mask, "seller_id"]

        return pd.Series(
            "Invalid seller city",
            index=invalid_ids.values
        )

    def check_seller_state(self):
        mask = (
            self.sellers["seller_state"].isna()
            | ~self.sellers["seller_state"].isin(VALID_STATES)
        )

        invalid_ids = self.sellers.loc[mask, "seller_id"]

        return pd.Series(
            "Invalid seller state",
            index=invalid_ids.values
        )

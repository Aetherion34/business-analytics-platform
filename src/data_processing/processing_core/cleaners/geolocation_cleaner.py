
import pandas as pd
import json
from data_processing.processing_core.constants import VALID_STATES
from data_processing.processing_core.rules.geolocation_rules import REQUIRED_COLUMNS


class GeolocationCleaner:
    def __init__(self, geolocations):
        self.geolocations = geolocations

    def clean(self, error_report):
        self.save_report(error_report)

        self.normalize_zcp()
        self.normalize_city()

        for column in REQUIRED_COLUMNS:
            self.remove_missing_values(column)

        self.remove_invalid_state()
        self.remove_invalid_lat()
        self.remove_invalid_lng()
        self.remove_duplicates()

        self.save_clean_data()

    def remove_duplicates(self):
        self.geolocations = self.geolocations.drop_duplicates(
            subset=[
                "geolocation_zip_code_prefix",
                "geolocation_lat",
                "geolocation_lng",
            ],
            keep="first",
        )

    def normalize_zcp(self):
        self.geolocations["geolocation_zip_code_prefix"] = (
            self.geolocations["geolocation_zip_code_prefix"]
            .astype("string")
            .str.strip()
            .str.zfill(5)
        )

    def normalize_city(self):
        self.geolocations["geolocation_city"] = (
            self.geolocations["geolocation_city"]
            .astype("string")
            .str.strip()
            .str.replace(r"\s+", " ", regex=True)
            .str.title()
        )

    def remove_missing_values(self, column):
        self.geolocations = self.geolocations.loc[
            self.geolocations[column].notna()
        ]

    def remove_invalid_state(self):
        self.geolocations = self.geolocations.loc[
            self.geolocations["geolocation_state"].isin(VALID_STATES)
        ]

    def remove_invalid_lat(self):
        mask = self.geolocations["geolocation_lat"].between(-90, 90)
        self.geolocations = self.geolocations.loc[mask]

    def remove_invalid_lng(self):
        mask = self.geolocations["geolocation_lng"].between(-180, 180)
        self.geolocations = self.geolocations.loc[mask]

    def save_report(self, error_report):
        serializable = {
            index: list(errors)
            for index, errors in error_report.items()
        }

        with open("data/errors/geolocation_errors_report.json", "w") as f:
            json.dump(serializable, f, indent=4)

    def save_clean_data(self):
        self.geolocations.to_csv(
            "data/processed/geolocation_list.csv",
            index=False,
        )

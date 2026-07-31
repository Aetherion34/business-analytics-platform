import pandas as pd
import json
from constants import VALID_STATES
from rules.geolocation_rules import  REQUIRED_COLUMNS
class GeolocationCleaner:
    def __init__(self, geolocations, error_report):
        self.geolocations = geolocations
        self.error_report = error_report

    #TODO
    def clean(self):
        self.save_report(self.error_report)

        self.remove_duplicates()
        self.normalize_zcp()
        self.normalize_city()
        for column in REQUIRED_COLUMNS:
            self.remove_missing_values(column)

        self.remove_invalid_state()
        self.remove_invalid_lat()
        self.remove_invalid_lng()

        self.save_clean_data()

    def remove_duplicates(self):
        self.geolocations = self.geolocations.drop_duplicates(keep = False)
    
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
            .str.title()
        )
        

    def remove_missing_values(self, column):
        mask = self.geolocations[column].isna()
        self.geolocations = self.geolocations.loc[~mask]

    def remove_invalid_state(self):
        mask = self.geolocations["geolocation_state"].isin(VALID_STATES)
        self.geolocations = self.geolocations.loc[mask]

    def remove_invalid_lat(self):
        mask = (
            (self.geolocations["geolocation_lat"] >= -90) &
            (self.geolocations["geolocation_lat"] <= 90)
        )
        self.geolocations = self.geolocations.loc[mask]

    def remove_invalid_lng(self):
            mask = (
                (self.geolocations["geolocation_lng"] >= -180) &
                (self.geolocations["geolocation_lng"] <= 180)
            )
            self.geolocations = self.geolocations.loc[mask]

    def save_report(self,error_report):
        serializable = {index:list(errors) for index, errors in error_report.items()}
        with open("data/errors/geolocation_errors_report.json", "w") as f:
            json.dump(serializable, f, indent = 4)

    def save_clean_data(self):
            self.geolocations.to_csv("data/processed/geolocation_list.csv", index = False)
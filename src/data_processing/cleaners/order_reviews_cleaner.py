import pandas as pd
from data_processing.constants import MAX_REVIEW_SCORE, MIN_REVIEW_SCORE
from data_processing.rules.order_reviews_rules import DATE_COLUMNS, REQUIRED_COLUMNS
import json
class OrderReviewsCleaner:
    def __init__(self, order_reviews, order_ids):
        self.order_reviews = order_reviews
        self.order_ids = order_ids


    def clean(self, error_report):
        self.save_report(error_report)
        self.save_report(error_report)

        for column in DATE_COLUMNS:
            self.normalize_dates(column)
            self.remove_missing_values(column)

        for column in REQUIRED_COLUMNS:
            self.remove_missing_values(column)

        self.remove_review_id_duplicates()
        self.remove_invalid_order_id()

        self.remove_invalid_review_score()
        self.remove_invalid_review_answer_timestamp()

        self.save_clean_data()



        

    def normalize_dates(self, column):
        self.order_reviews[column] = pd.to_datetime(self.order_reviews[column], errors="coerce")

    def remove_missing_values(self, column):
        mask = self.order_reviews[column].isna()
        self.order_reviews = self.order_reviews[~mask]

    def remove_review_id_duplicates(self):
        self.order_reviews = self.order_reviews.drop_duplicates(
            subset = ["review_id"],
            keep = False
        )

    def remove_invalid_order_id(self):
        mask = self.order_reviews["order_id"].isin(self.order_ids)
        self.order_reviews = self.order_reviews[mask]

    def remove_invalid_review_score(self):
        mask = (
        (self.order_reviews["review_score"] >= MIN_REVIEW_SCORE) &
        (self.order_reviews["review_score"] <= MAX_REVIEW_SCORE)
        )       
        self.order_reviews = self.order_reviews[mask]

    def remove_invalid_review_answer_timestamp(self):
        mask = (self.order_reviews["review_answer_timestamp"] >= self.order_reviews["review_creation_date"])
        self.order_reviews = self.order_reviews[mask]

    def save_report(self, error_report):
        serializable = {review_id : list(errors) for review_id, errors in error_report.items()}
        with open("data/errors/order_reviews_errors_report.json", "w") as f:
            json.dump(serializable, f, indent = 4)

    def save_clean_data(self):
        self.order_reviews.to_csv("data/processed/order_reviews_list.csv", index = False)
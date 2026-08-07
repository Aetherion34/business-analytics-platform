import pandas as pd
from data_processing.constants import MAX_REVIEW_SCORE, MIN_REVIEW_SCORE
from data_processing.rules.order_reviews_rules import DATE_COLUMNS, REQUIRED_COLUMNS
class OrderReviewsValidator:
    def __init__(self, order_reviews, order_ids):
        self.order_reviews = order_reviews
        self.order_ids = order_ids
        
    def validate(self):
        errors = [
            self.check_review_id_duplicates(),
            self.check_order_id(),
        ]

        for column in REQUIRED_COLUMNS:
            errors.append(self.check_missing_values(column))

        for column in DATE_COLUMNS:
            errors.append(self.check_valid_dates(column))

        errors.append(self.check_review_score())
        errors.append(self.check_review_answer_after_creation())

        all_errors = pd.concat(errors)

        errors_by_order = all_errors.groupby(level = 0).apply(set).to_dict()

        return errors_by_order
    def check_missing_values(self, column):
        mask = self.order_reviews[column].isna()
        index = self.order_reviews.loc[mask, "review_id"]
        return pd.Series(f"missing {column}", index=index)

    def check_review_id_duplicates(self):
        mask = self.order_reviews.duplicated(
            subset=["review_id"],
            keep=False
        )
        index = self.order_reviews.loc[mask, "review_id"]
        return pd.Series(f"invalid review id", index=index)

    def check_valid_dates(self, column):
        dates = pd.to_datetime(self.order_reviews[column], errors="coerce")
        mask = dates.isna()
        index = self.order_reviews.loc[mask, "review_id"]
        return pd.Series(f"invalid {column} format", index=index)

    def check_order_id(self):
        mask = (self.order_reviews["order_id"].isin(self.order_ids))
        index = self.order_reviews.loc[~mask, "review_id"]
        return pd.Series("invalid order id", index=index)

    def check_review_score(self):
        mask = (
            (self.order_reviews["review_score"] >= MIN_REVIEW_SCORE) &
            (self.order_reviews["review_score"] <= MAX_REVIEW_SCORE)
        )        
        index = self.order_reviews.loc[~mask, "review_id"]
        return pd.Series("review score must be between 1 and 5", index=index)

    def check_review_answer_after_creation(self):
        creation_date = pd.to_datetime(self.order_reviews["review_creation_date"], errors="coerce")
        answer_date = pd.to_datetime(self.order_reviews["review_answer_timestamp"], errors="coerce")
        mask = creation_date <= answer_date
        index = self.order_reviews.loc[~mask, "review_id"]
        return pd.Series(
            "review answer timestamp must be after review creation date",
            index=index
        )
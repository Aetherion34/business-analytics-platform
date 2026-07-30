import pandas as pd
from rules.order_items_rules import REQUIRED_COLUMNS, POSITIVE_COLUMNS
class OrderItemsValidator:
    def __init__(self, order_ids, product_ids, seller_ids, order_items):
        self.order_ids = order_ids
        self.product_ids = product_ids
        self.seller_ids = seller_ids
        self.order_items= order_items

    def validate(self):
        errors = []
        references = {
            "order_id": self.order_ids,
            "product_id": self.product_ids,
            "seller_id": self.seller_ids
        }
        for column, valid_values  in references.items():
            errors.append(self.check_valid_reference(column, valid_values))

        for column in REQUIRED_COLUMNS:
            errors.append(self.check_missing_value(column))

        for column in POSITIVE_COLUMNS:
            errors.append(self.check_positive_values(column))

        errors.append(self.check_valid_shipping_limit_date())
        errors.append(self.check_order_item_key_uniqueness())
        all_errors = pd.concat(errors)
        ordered_errors = all_errors.groupby(level=[0,1]).apply(set).to_dict()
        return ordered_errors
        


    def check_missing_value(self, column):
        mask = (self.order_items[column].isna())
        index = self.order_items.loc[mask].set_index(["order_id", "order_item_id"]).index
        return pd.Series(f"missing {column}", index = index)

    def check_positive_values(self, column):
        mask = (self.order_items[column] <= 0)
        index = self.order_items.loc[mask].set_index(["order_id", "order_item_id"]).index
        return pd.Series(f"{column} must be positive", index = index)

    def check_valid_shipping_limit_date(self):
        dates = pd.to_datetime(self.order_items["shipping_limit_date"], errors = "coerce")
        mask = dates.isna()
        index = self.order_items.loc[mask].set_index(["order_id", "order_item_id"]).index
        return pd.Series("invalid shipping_limit_date", index = index)

    def check_valid_reference(self, column, valid_values):
        mask = ~(self.order_items[column].isin(valid_values))
        index = self.order_items.loc[mask].set_index(["order_id", "order_item_id"]).index
        return pd.Series(f"invalid {column}", index = index)

    def check_order_item_key_uniqueness(self):
        duplicates  = self.order_items.duplicated(
            subset=["order_id", "order_item_id"],
            keep = False
        )
        index = self.order_items.loc[duplicates].set_index(["order_id", "order_item_id"]).index
        return pd.Series("order item must be unique for each order", index = index)
    
    
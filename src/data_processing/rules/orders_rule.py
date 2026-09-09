import pandas as pd
def get_invalid_order_ids_from_invalid_references(order_items, valid_product_ids):
    invalid_order_ids = order_items[~order_items["product_id"].isin(valid_product_ids)]["order_id"].drop_duplicates()
    return invalid_order_ids

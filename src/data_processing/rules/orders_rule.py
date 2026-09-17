import pandas as pd
def get_valid_order_ids_from_valid_references(order_items, valid_product_ids):
    valid_order_ids = order_items[order_items["product_id"].isin(valid_product_ids)]["order_id"].drop_duplicates()
    return valid_order_ids

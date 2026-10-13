import pandas as pd
import json
class ConsistencyCleaner:
    def __init__(self, product_order_ids, order_items_order_ids, review_order_ids, payment_order_ids,
            order_ids,order_payments_list, order_items_list, order_reviews_list, order_list):
        self.order_ids = order_ids
        self.product_order_ids = product_order_ids 
        self.order_items_order_ids = order_items_order_ids
        self.review_order_ids = review_order_ids
        self.payment_order_ids = payment_order_ids
        self.valid_order_ids = (
            pd.Index(self.product_order_ids)
            .intersection(pd.Index(self.order_items_order_ids))
            .intersection(pd.Index(self.payment_order_ids))
            .intersection(pd.Index(self.order_ids))
        )

        
        self.order_payments_list = order_payments_list
        self.order_items_list = order_items_list 
        self.order_reviews_list = order_reviews_list 
        self.order_list = order_list 

    def clean(self, error_report):
        TABLES = {
            "order_payments_list" : self.order_payments_list, 
            "order_items_list" : self.order_items_list, 
            "order_reviews_list" : self.order_reviews_list,
            "order_list" : self.order_list
        }
        for table_name, table in TABLES.items():
            cleaned = self.remove_table_inconsistencies(table)
            setattr(self, table_name, cleaned)


        self.save_report(error_report)

        self.save_clean_data()
    

    def remove_table_inconsistencies(self, table):
        mask =  table["order_id"].isin(self.valid_order_ids)
        return table.loc[mask]

    def save_report(self, error_report):
        serializzable = {order_id : list(error) for order_id,error in error_report.items()}
        with open("data/errors/consistency_errors_report.json", "w") as f:
            json.dump(serializzable, f, indent= 4)

    def save_clean_data(self):
        self.order_payments_list.to_csv("data/processed/order_payments_list.csv", index = False)
        self.order_items_list.to_csv("data/processed/order_items_list.csv", index = False)
        self.order_reviews_list.to_csv("data/processed/order_reviews_list.csv", index = False)
        self.order_list.to_csv("data/processed/order_list.csv", index = False)

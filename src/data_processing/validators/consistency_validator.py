import pandas as pd
class ConsistencyValidator:
    def __init__(self, product_order_ids, order_items_order_ids, review_order_ids, payment_order_ids, 
                order_payments_list, order_items_list, order_reviews_list, order_list):
        self.product_order_ids = product_order_ids 
        self.order_items_order_ids = order_items_order_ids
        self.review_order_ids = review_order_ids
        self.payment_order_ids = payment_order_ids
        self.valid_order_ids =   pd.concat([
                    self.product_order_ids,
                    self.order_items_order_ids,
                    self.review_order_ids,
                    self.payment_order_ids
                ]).drop_duplicates()

        
        self.order_payments_list = order_payments_list
        self.order_items_list = order_items_list 
        self.order_reviews_list = order_reviews_list 
        self.order_list = order_list 


    def validate(self):
        TABLES = [
            self.order_payments_list, 
            self.order_items_list, 
            self.order_reviews_list,
            self.order_list,
        ]
        errors = []

        for table in TABLES:
            errors.append(self.check_table_consistencies(table))

        all_errors = pd.concat(errors)

        errors_by_order = all_errors.groupby(level = 0).apply(set).to_dict()

        return errors_by_order



    def check_table_consistencies(self,table):
        mask =  ~table["order_id"].isin(self.valid_order_ids)
        index = table.loc[mask].index
        return pd.Series(f"id not in valid ids", index=index)




class Customer_cleaner():
    def __init__(self, customers):
        self.customers = customers

    def infer_customer_values(self):
        grouped = self.customers.groupby("customer_unique_id")
        count_uniques = grouped[["customer_zip_code_prefix", "customer_city", "customer_state"]].nunique()
        errors = (count_uniques > 1).any(axis=1)
        invalid_customers_id = errors[errors].index
        customers_id_mask = (self.customers["customer_unique_id"].isin(invalid_customers_id))
        Invalid_customers = self.customers[customers_id_mask]
        invcu_grouped = Invalid_customers.groupby("customer_unique_id")
        


    def apply_customer_corrections(self):
        ...
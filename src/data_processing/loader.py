import pandas as pd
def load_orders(path):
    return pd.read_csv(path)

def load_customers(path):
    return pd.read_csv(path)
import pandas as pd
def load_orders(path):
    return pd.read_csv(path)

def load_customers(path):
    return pd.read_csv(path)

def load_sellers(path):
    return pd.read_csv(path)

def load_products(path):
    return pd.read_csv(path)

def load_order_items(path):
    return pd.read_csv(path)
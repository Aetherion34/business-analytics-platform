from .config import TABLE_CONFIGS
import pandas as pd

def load_all_tables(engine):
    for table_name, config in TABLE_CONFIGS.items():
        table_data = prepare_table_data(config)

        table_data.to_sql(
            name=table_name,
            con=engine,
            method="multi",
            chunksize=1000,
            if_exists="append",
            index=False,
        )

def prepare_table_data(config):
    path = config["file"]
    column_mapping = config["columns"]

    raw_df = pd.read_csv(path)
    formatted_df = raw_df.rename(columns=column_mapping)

    return formatted_df

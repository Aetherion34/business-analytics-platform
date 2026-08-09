from .config import TABLE_CONFIGS
from sqlalchemy import text
import pandas as pd

def drop_all_tables(engine):
    with engine.connect() as con:
        con.execute(text("DROP SCHEMA public CASCADE; CREATE SCHEMA public;"))
        con.commit()
def process_all_tables(engine):
    drop_all_tables(engine)
    for table_name, config in TABLE_CONFIGS.items():
        formatted_table = load_and_clean(table_name, config)
        formatted_table.to_sql(
            name = table_name,
            con = engine,
            method = "multi",
            chunksize = 1000,
            if_exists = "replace",
            index = False
            )

def load_and_clean(table_name, config):
    path = config["file"]
    colum_mapping = config["columns"]
    raw_df = pd.read_csv(path)
    print(f"Lunghezza {table_name}: {len(raw_df)}")
    formatted_df = raw_df.rename(columns = colum_mapping)
    return formatted_df




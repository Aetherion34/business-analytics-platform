from .database_client.connection import engine
from .database_client.loader import process_all_tables as otlp_loader

def setup_oltp_database():
    otlp_loader(engine)
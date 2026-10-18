from sqlalchemy import text
from .database_client.connection import engine
from .database_client.sql_executor import execute_sql_file as schemas_runner
from .database_client.database_loader import load_all_tables as otlp_loader
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[2]

def setup_database_pipeline():
    setup_oltp_database()
    setup_warehouse_database()


def setup_oltp_database():
    schemas_runner(engine, BASE_DIR / "sql" / "schemas" / "oltp_schema.sql")
    otlp_loader(engine)

def setup_warehouse_database():
    schemas_runner(engine, BASE_DIR / "sql" / "schemas" / "warehouse_schema.sql")

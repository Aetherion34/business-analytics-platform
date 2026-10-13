import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()
username = os.environ.get("DB_USER")
password = os.environ.get("DB_PASSWORD")
host = os.environ.get("DB_HOST")
port = os.environ.get("DB_PORT")
database = os.environ.get("DB_NAME")
engine = create_engine(f"postgresql+psycopg2://{username}:{password}@{host}:{port}/{database}")
# TEST
#with engine.connect() as connection:
#   result = connection.execute(text("SELECT 1"))
#   print(result.fetchone())
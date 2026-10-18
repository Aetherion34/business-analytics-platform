from pathlib import Path
from data_processing import run_data_processing, PROCESSED_DATA_DIR
from database import setup_database_pipeline
def main():
    run_data_processing()
    setup_database_pipeline()
if __name__ == "__main__":
    main()
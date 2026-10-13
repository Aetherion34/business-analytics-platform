from data_processing import run_data_processing
from database import setup_oltp_database
def main():
    run_data_processing()
    setup_oltp_database()
if __name__ == "__main__":
    main()
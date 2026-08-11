from database import process_all_tables as db_loader, engine as db_engine
from pipeline.main_pipeline import execute_pipelines

def main():
    db_loader(db_engine)
    execute_pipelines()
if __name__ == "__main__":
    main()
    
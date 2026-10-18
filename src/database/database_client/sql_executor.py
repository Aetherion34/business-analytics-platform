from pathlib import Path
import psycopg2
'''SQLAlchemy's standard execution methods are primarily designed to execute individual SQL statements.
Executing a complete SQL script containing multiple statements requires handling that is compatible with the underlying database driver.
For PostgreSQL, we use psycopg2 to execute the schema script directly through the DBAPI cursor,
while retaining SQLAlchemy for connection and engine management elsewhere in the application.'''
def execute_sql_file(engine, sql_file_path: Path): #
    sql_code = Path.read_text(sql_file_path)
    dbapi_conn = engine.raw_connection()
    cursor = dbapi_conn.cursor()
    try:
        cursor.execute(sql_code)
    except psycopg2.Error as e:
        dbapi_conn.rollback()
        cursor.close()
        dbapi_conn.close()
        raise RuntimeError(
        f"Failed to execute SQL script: {e}"
    ) from e
    dbapi_conn.commit()
    cursor.close()
    dbapi_conn.close()

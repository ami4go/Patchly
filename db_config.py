import mysql.connector
from mysql.connector import pooling

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'India@123',
    'database': 'PatchlyDB',
    'auth_plugin': 'mysql_native_password'
}

def get_db():
    """Get a fresh connection."""
    return mysql.connector.connect(**DB_CONFIG)

def query_db(sql, params=None, fetchone=False):
    """Execute a query and return results as list of dicts."""
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(sql, params or ())
        if sql.strip().upper().startswith('SELECT'):
            return cursor.fetchone() if fetchone else cursor.fetchall()
        else:
            conn.commit()
            return cursor.lastrowid
    finally:
        cursor.close()
        conn.close()

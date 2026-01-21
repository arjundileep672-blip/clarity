import sys
import os
sys.path.append('/home/aditya/Projects/gdg/namma-hack/clarity')

from backend.database import engine
from sqlalchemy import text

def verify_db():
    with engine.connect() as connection:
        # Check tables
        result = connection.execute(text("SELECT name FROM sqlite_master WHERE type='table';"))
        tables = [row[0] for row in result.fetchall()]
        expected_tables = ["sessions", "tasks", "task_steps", "panic_events", "grounding_exercises", "ai_logs"]
        
        print("Tables found in database:")
        for table in tables:
            print(f"- {table}")

        for table in expected_tables:
            if table not in tables:
                print(f"Error: Table '{table}' missing!")
            else:
                print(f"Success: Table '{table}' verified.")

        # Check foreign key enforcement
        result = connection.execute(text("PRAGMA foreign_keys;"))
        fk_status = result.fetchone()[0]
        print(f"Foreign keys enabled (PRAGMA foreign_keys): {'Yes' if fk_status else 'No'}")

if __name__ == "__main__":
    verify_db()

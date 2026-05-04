"""
Shelter Outcome Predictor - Data Ingestion
Austin Animal Center - Intakes + Outcomes
With DuckDB storage and run logging
"""

import pandas as pd
from sodapy import Socrata
import duckdb
import os
from datetime import datetime

# ── CONFIG ────────────────────────────────────────────────────────────────────
DB_PATH = os.path.join(os.path.dirname(__file__), "shelter.duckdb")
INTAKES_ID = "wter-evkm"   # Austin Animal Center Intakes
OUTCOMES_ID = "9t4d-g238"  # Austin Animal Center Outcomes

# ── API CLIENT ────────────────────────────────────────────────────────────────
client = Socrata(
    "data.austintexas.gov",
    os.environ.get("SOCRATA_APP_TOKEN")
)

# ── FETCH FUNCTION ────────────────────────────────────────────────────────────
def get_all_records(client, dataset_id, batch_size=50000):
    all_records = []
    offset = 0
    while True:
        batch = client.get(dataset_id, limit=batch_size, offset=offset)
        if not batch:
            break
        all_records.extend(batch)
        offset += batch_size
        print(f"  {dataset_id}: fetched {len(all_records)} rows...")
    return all_records

# ── DATABASE SETUP ────────────────────────────────────────────────────────────
def setup_database(con):
    """Create tables if they don't exist yet"""

    con.execute("""
        CREATE TABLE IF NOT EXISTS raw_intakes AS
        SELECT * FROM intakes_df WHERE 1=0
    """) if False else None  # placeholder — handled below

    con.execute("""
        CREATE TABLE IF NOT EXISTS run_log (
            run_id        INTEGER PRIMARY KEY,
            run_timestamp TIMESTAMP,
            dataset       VARCHAR,
            rows_fetched  INTEGER,
            status        VARCHAR,
            notes         VARCHAR
        )
    """)
    print("Database tables ready.")

# ── LOG A RUN ─────────────────────────────────────────────────────────────────
def log_run(con, dataset, rows_fetched, status, notes=""):
    con.execute("""
        INSERT INTO run_log (run_timestamp, dataset, rows_fetched, status, notes)
        VALUES (?, ?, ?, ?, ?)
    """, [datetime.now(), dataset, rows_fetched, status, notes])
    print(f"  Logged: {dataset} | {rows_fetched} rows | {status}")

# ── LOAD TO DUCKDB ────────────────────────────────────────────────────────────
def load_to_db(con, df, table_name):
    """Replace table with fresh data"""
    con.execute(f"DROP TABLE IF EXISTS {table_name}")
    con.execute(f"CREATE TABLE {table_name} AS SELECT * FROM df")
    print(f"  Loaded {len(df)} rows into {table_name}")

# ── MAIN ──────────────────────────────────────────────────────────────────────
def main():
    con = duckdb.connect(DB_PATH)

    # Create run_log if it doesn't exist
    con.execute("""
        CREATE TABLE IF NOT EXISTS run_log (
            run_id        INTEGER,
            run_timestamp TIMESTAMP,
            dataset       VARCHAR,
            rows_fetched  INTEGER,
            status        VARCHAR,
            notes         VARCHAR
        )
    """)

    # ── INTAKES ──
    print("\nFetching intakes...")
    try:
        intakes_records = get_all_records(client, INTAKES_ID)
        intakes_df = pd.DataFrame.from_records(intakes_records)
        load_to_db(con, intakes_df, "raw_intakes")
        log_run(con, "intakes", len(intakes_df), "success")
    except Exception as e:
        log_run(con, "intakes", 0, "failed", str(e))
        print(f"  ERROR: {e}")

    # ── OUTCOMES ──
    print("\nFetching outcomes...")
    try:
        outcomes_records = get_all_records(client, OUTCOMES_ID)
        outcomes_df = pd.DataFrame.from_records(outcomes_records)
        load_to_db(con, outcomes_df, "raw_outcomes")
        log_run(con, "outcomes", len(outcomes_df), "success")
    except Exception as e:
        log_run(con, "outcomes", 0, "failed", str(e))
        print(f"  ERROR: {e}")

    # ── CONFIRM ──
    print("\nDatabase summary:")
    print(con.execute("SELECT * FROM run_log ORDER BY run_timestamp DESC").df())
    print(con.execute("SELECT COUNT(*) as intakes_rows FROM raw_intakes").df())
    print(con.execute("SELECT COUNT(*) as outcomes_rows FROM raw_outcomes").df())

    con.close()
    print("\nDone.")

if __name__ == "__main__":
    main()
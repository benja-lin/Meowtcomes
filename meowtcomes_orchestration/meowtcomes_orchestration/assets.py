import importlib.util
from dagster import asset, OpExecutionContext
from dagster_dbt import DbtCliResource
from pathlib import Path
import subprocess

REPO_ROOT = Path(__file__).parent.parent.parent
DBT_PROJECT_DIR = REPO_ROOT / "shelter_dbt"

@asset
def raw_shelter_data(context: OpExecutionContext):
    """Fetches intakes and outcomes from Austin Animal Center API into DuckDB."""
    spec = importlib.util.spec_from_file_location("ingest", REPO_ROOT / "ingest.py")
    ingest = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(ingest)
    context.log.info("Starting shelter data ingestion...")
    ingest.main()
    context.log.info("Ingestion complete.")

@asset(deps=[raw_shelter_data])
def dbt_models(context: OpExecutionContext):
    """Runs dbt models on top of raw shelter data."""
    context.log.info("Running dbt...")
    result = subprocess.run(
        ["dbt", "run", "--project-dir", str(DBT_PROJECT_DIR)],
        capture_output=True,
        text=True
    )
    context.log.info(result.stdout)
    if result.returncode != 0:
        raise Exception(f"dbt failed:\nSTDOUT:\n{result.stdout}\nSTDERR:\n{result.stderr}")
    context.log.info("dbt run complete.")
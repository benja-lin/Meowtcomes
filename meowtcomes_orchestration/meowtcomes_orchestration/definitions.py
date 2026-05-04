import sys
from pathlib import Path

# Add repo root to path so ingest.py can be found
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from dagster import Definitions, load_assets_from_modules
from meowtcomes_orchestration import assets  # noqa: TID252

all_assets = load_assets_from_modules([assets])

defs = Definitions(
    assets=all_assets,
)
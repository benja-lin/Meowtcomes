# Meowtcomes 🐾

## Overview
Meowtcomes is an end-to-end data pipeline built using public data from the 
Austin Animal Center. The project ingests data from the Socrata API, stores 
it in a local DuckDB warehouse, and transforms it into tables using dbt. 
The goal is to understand what factors influence animal outcomes — including adoption 
rates, euthanasia risk, and repeat shelter visits.

## Data Source
Data is sourced from the [Austin Animal Center](https://data.austintexas.gov/Health-and-Community-Services/Austin-Animal-Center-Intakes/wter-evkm), 
The dataset contains intake and outcome records for animals in the shelter's care 
from October 2013 to present, refreshed hourly via the Socrata Open Data API.

## Pipeline Architecture
Socrata API → ingest.py → DuckDB (shelter.duckdb) → dbt → Analysis-Ready Marts
1. **Ingestion** — `ingest.py` pulls intake and outcome records from the Socrata API 
   and loads them into DuckDB, with a run log table tracking each ingestion job.
2. **Staging** — dbt cleans and standardizes raw tables, handling type casting, 
   null values, and derived fields like spay/neuter status and animal category.
3. **Intermediate** — intake and outcome records are joined at the visit level, 
   with window functions used to handle animals with multiple shelter visits.
4. **Marts** — two analysis-ready tables are produced: one at the animal level 
   and one at the visit level.

## Project Structure
Meowtcomes/
├── ingest.py                   # Socrata API ingestion script
├── shelter.duckdb              # Local DuckDB warehouse
├── EDA_V3.ipynb                # Exploratory data analysis
└── shelter_dbt/
├── dbt_project.yml
└── models/
├── staging/
│   ├── stg_intakes.sql
│   ├── stg_outcomes.sql
│   └── schema.yml
├── intermediate/
│   ├── int_animals_joined.sql
│   └── schema.yml
└── marts/
├── mart_animal_summary.sql
├── mart_visit_detail.sql
└── schema.yml

## Models

**Staging**
- `stg_intakes` — Cleaned and standardized intake records from the Austin Animal Center
- `stg_outcomes` — Cleaned and standardized outcome records from the Austin Animal Center

**Intermediate**
- `int_animals_joined` — Intake and outcome records joined at the visit level using 
  ROW_NUMBER() to correctly pair visits for animals with multiple shelter stays

**Marts**
- `mart_animal_summary` — One row per animal, aggregating visit history into a single 
  record with first intake characteristics and last outcome details
- `mart_visit_detail` — One row per visit, enabling analysis of repeat visitor patterns 
  and time between shelter stays

## Key Questions This Dataset Can Answer
- Which dog and cat breeds have the highest adoption rates?
- Do animals that enter the shelter in poor health have worse outcomes?
- How does age at intake affect the likelihood of adoption vs euthanasia?
- Are animals that were altered during a shelter stay less likely to return?
- How long do repeat visitors typically spend outside the shelter between visits?
- Does intake source (stray vs owner surrender) affect outcome?

## How To Run

### Prerequisites
- Python 3.12
- dbt-duckdb
- Socrata API credentials ([register here](https://data.austintexas.gov/signup))

### Setup
```bash
# Clone the repository
git clone https://github.com/yourusername/IntakesMeowtcomes.git
cd IntakesMeowtcomes
# Set your Socrata credentials as environment variables
# or update ingest.py with your app token

# Create and activate virtual environment
py -3.12 -m venv shelter_env_312
& shelter_env_312\Scripts\Activate.ps1

# Install dependencies
pip install duckdb pandas dbt-duckdb sodapy

# Run ingestion
python ingest.py

# Run dbt
cd shelter_dbt
dbt run
dbt test
```

## Tools Used
- **Python** — API ingestion, exploratory data analysis
- **DuckDB** — Local analytical warehouse
- **dbt** — Data transformation and modeling
- **Socrata API** — Austin Animal Center open data
- **pandas / matplotlib / seaborn** — Exploratory analysis
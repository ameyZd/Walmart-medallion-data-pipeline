# Walmart Medallion Data Pipeline

This project builds a Walmart-style retail analytics pipeline using GhostDB as an agentic source database, Databricks, dbt, Airflow, Docker, and AWS S3.

The project follows a medallion architecture: raw operational data from a forked GhostDB source lands in Databricks bronze tables, dbt transforms it into technical and business silver layers, and gold models expose analytics-ready dimension and fact tables. Airflow orchestrates the end-to-end flow, including a Databricks ingestion job and dbt model execution.

## Project Story

- A forked GhostDB agentic database is used as a safe source system copy, so experiments do not accidentally delete or update the main production database.
- Databricks hosts a `walmart` catalog with raw/bronze, silver, and gold schemas.
- dbt connects to Databricks through a SQL Warehouse and handles transformation, tests, snapshots, and data modeling.
- Airflow runs in Docker and orchestrates the pipeline from ingestion to gold-layer models.
- A new customer reviews file in S3 is integrated as an additional data lake source through Databricks external location access.

## Architecture

<img width="2200" height="1117" alt="Walmart_Project_architecture (1)" src="https://github.com/user-attachments/assets/76803643-b01d-4971-abb6-fcdf844fc8bd" />

## Tech Stack

- GhostDB for the agentic operational source database
- Databricks for catalog, schemas, ingestion, and compute
- dbt for transformations, tests, snapshots, and modeling
- Apache Airflow for orchestration
- Docker for running a custom Airflow environment
- AWS S3 for customer review data lake ingestion
- Python for seed data loading and Databricks job triggering

## Repository Structure

```text
.
|-- walmart_dataset/
|   |-- data/                         # CSV seed data
|   |-- ddl/walmart_schema.sql         # PostgreSQL source schema
|   `-- load_data.py                   # CSV loader for PostgreSQL
|-- airflow_dbt_project/
|   |-- dags/orchestrate.py            # Airflow DAG
|   |-- requirements.txt               # Airflow image Python dependencies
|   `-- walmart_dbt_project/
|       |-- models/source/             # dbt source definitions
|       |-- models/silver_technical/   # cleaned technical tables
|       |-- models/silver_business/    # OBT business model
|       |-- models/gold/               # ephemeral and fact models
|       |-- snapshots/                 # SCD-style dimension snapshots
|       |-- tests/                     # custom dbt tests
|       |-- dbt_project.yml
|       `-- profiles.yml
`-- docs/
    |-- demo-video-plan.md
    `-- medium-article-draft.md
```

## Data Flow

1. Load Walmart-style seed CSVs into a GhostDB-backed source database.
2. Use a forked GhostDB database copy for development safety.
3. Ingest source data into the Databricks `walmart` catalog bronze schema.
4. Use dbt silver technical models to clean and standardize source tables.
5. Build a silver business one-big-table model using metadata-driven SQL/Jinja.
6. Use dbt snapshots for dimension-style history tracking.
7. Build gold fact models for analytics-ready reporting.
8. Trigger and monitor the pipeline through Airflow.
9. Extend the pipeline with customer review data from S3 through Databricks external locations.

## dbt Layers

| Layer | Purpose | Examples |
| --- | --- | --- |
| Source | Defines bronze Databricks tables | `customers`, `orders`, `products`, `stores` |
| Silver technical | Cleaned technical models | `customers_t`, `orders_t`, `products_t` |
| Silver business | Business-level OBT model | `obt_b` |
| Gold ephemeral | Reusable intermediate dimension logic | `eph_customers`, `eph_orders`, `eph_products` |
| Gold fact | Analytics fact tables | `fact_orders` |
| Snapshots | Historical dimension tracking | `dim_customers`, `dim_orders`, `dim_products` |

## Orchestration

The Airflow DAG in `airflow_dbt_project/dags/orchestrate.py` runs the pipeline in this order:

1. Trigger Databricks ingestion job through the Databricks SDK.
2. Clean old dbt `target` and `logs` folders.
3. Run `dbt source freshness`.
4. Build silver technical models.
5. Test silver technical models.
6. Build silver business models.
7. Test silver business models.
8. Build gold ephemeral dependencies.
9. Run dbt snapshots for dimensions.
10. Build gold fact tables.

## Local Setup Notes

This project depends on cloud resources, so local setup requires your own credentials and workspace values.

### 1. GhostDB source setup

Create the source tables from:

```bash
walmart_dataset/ddl/walmart_schema.sql
```

Then update the connection string in:

```bash
walmart_dataset/load_data.py
```

Load CSV data:

```bash
python walmart_dataset/load_data.py
```

### 2. Databricks setup

Create or update these Databricks resources:

- Catalog: `walmart`
- Bronze/raw schema for ingested source tables
- SQL Warehouse for dbt
- Databricks job for source ingestion
- External location or storage credential for the S3 reviews file

Update dbt connection values in:

```bash
airflow_dbt_project/walmart_dbt_project/profiles.yml
```

### 3. dbt commands

From `airflow_dbt_project/walmart_dbt_project`:

```bash
dbt debug
dbt source freshness
dbt run --select silver_technical
dbt test --select silver_technical
dbt run --select silver_business
dbt test --select silver_business
dbt snapshot
dbt run --select gold/fact
```

Use a full refresh when you want to rebuild models from scratch:

```bash
dbt run --full-refresh
```

### 4. Airflow and Docker

The default Airflow image does not include dbt or the Databricks SDK, so use a custom image that installs `requirements.txt`.

Example Dockerfile:

```Dockerfile
FROM apache/airflow:3.3.0

USER root
RUN apt-get update && apt-get install -y gcc && apt-get clean

USER airflow
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
```

Rebuild and restart Airflow:

```bash
docker compose down
docker compose up --build -d
```

## Key Learning Outcomes

- Designing a medallion architecture across bronze, silver, and gold layers
- Connecting dbt to Databricks through a SQL Warehouse
- Building metadata-driven dbt models with Jinja
- Using snapshots for dimension history
- Orchestrating Databricks and dbt work with Airflow
- Extending a warehouse pipeline with S3 data lake files
- Running Airflow with a custom Docker image when extra packages are required

## Demo Assets To Capture

For a portfolio demo, capture these screenshots or short clips:

- Databricks `walmart` catalog with bronze, silver, and gold schemas
- Databricks pipeline/job run for source ingestion
- dbt lineage graph or successful dbt run output
- Airflow DAG graph view showing task order
- Airflow successful DAG run logs
- S3 bucket customer reviews file
- Gold schema table preview, especially `fact_orders`


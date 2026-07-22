# Business Analytics Platform

A complete data analytics pipeline designed to transform raw business data into structured information and meaningful insights.

The project simulates a real-world Business Intelligence workflow, from raw data ingestion to analysis and visualization.

---

# Project Overview

Companies generate large amounts of raw data every day. This project aims to build a system capable of processing this data, improving its quality, and preparing it for business analysis.

The main pipeline is:

```
Raw Data
    |
    v
Data Loading
    |
    v
Data Validation
    |
    v
Data Cleaning
    |
    v
Processed Data
    |
    v
Analysis
    |
    v
Visualization
```

---

# Current Progress

## Phase 1: Data Processing

The first phase focuses on building the foundation of the analytics pipeline using Python and Pandas.

Implemented features:

- Project structure setup
- CSV data loading
- Data validation system
- Detection of invalid records
- Data quality checks

Current validation rules:

- Duplicate order IDs
- Invalid order statuses
- Missing required values
- Invalid date sequences
- Inconsistent relationships between dates

The validator only detects problems and generates an error report. It does not modify the original data.

The cleaning process is responsible for fixing or removing invalid records.

---

# Architecture

The project follows a modular structure:

```
src/

├── main.py

├── data_processing/

│   ├── loader.py
│   ├── validator.py
│   ├── cleaner.py
│   └── constants.py
```

Responsibilities:

## Loader

Responsible for:

- Reading raw datasets
- Loading data into Pandas DataFrames


## Validator

Responsible for:

- Checking data quality
- Detecting invalid records
- Creating error reports

The validator does not modify data.


## Cleaner

Responsible for:

- Removing invalid records
- Fixing incorrect values
- Creating processed datasets


---

# Technologies

- Python
- Pandas
- NumPy
- Git
- GitHub


---

# Dataset

This project uses the Brazilian E-Commerce Public Dataset by Olist.

The dataset contains information about:

- Customers
- Orders
- Products
- Sellers
- Payments
- Reviews
- Geolocation


The raw dataset is not included in this repository.

After downloading the dataset, place the files inside:

```
data/raw/
```

---

# Project Structure

```
business-analytics-platform/

├── data/

│   ├── raw/

│   ├── processed/

│   └── errors/


├── src/

│   ├── main.py

│   └── data_processing/

│       ├── loader.py

│       ├── validator.py

│       ├── cleaner.py

│       └── constants.py


├── README.md

├── requirements.txt

└── .gitignore
```

---

# Future Improvements

Planned features:

- SQL database integration
- REST API
- Interactive dashboard
- Automated business reports
- Advanced analytics
- Machine learning models
- Cloud deployment

---

# Goal

The final goal is to create a complete Business Intelligence platform capable of transforming raw business data into actionable insights.
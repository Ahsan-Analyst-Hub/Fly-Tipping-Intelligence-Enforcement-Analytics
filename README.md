# Kent Fly-Tipping Intelligence & Enforcement Analytics

## Introduction

This project is a **synthetic Business Intelligence and Intelligence Analysis case study** designed around a Lead Intelligence Analyst scenario supporting fly-tipping enforcement across Kent Council.

The project demonstrates how raw incident data can be transformed into **actionable intelligence** through data cleaning, transformation, SQL analysis, Power BI data modelling, DAX and interactive visualisation.

The analysis focuses on answering five key intelligence questions:

1. **What is happening?**
2. **Where is it happening?**
3. **When and what patterns exist?**
4. **What enforcement intelligence is available?**
5. **What intelligence is missing?**
6. **Hypothetical intelligence report**

> **Data disclaimer:** All data used in this project is synthetic and created solely for portfolio and demonstration purposes. It does not represent actual Kent Council enforcement data, real individuals, vehicles, cases or locations.

---

# Problem Statement

Fly-tipping creates operational, environmental and financial challenges for local authorities. Simply recording incidents is not sufficient; enforcement teams need reliable intelligence to identify **hotspots areas, recurring patterns, priority cases and intelligence gaps**.

The objective of this project was to develop an intelligence-led analytical solution that could:

* Identify geographic fly-tipping hotspots.
* Detect recurring and emerging trends.
* Analyse waste types and reporting patterns.
* Support enforcement investigations.
* Identify gaps in available intelligence and evidence.
* Compare activity across Kent's 12 councils.
* Provide clear intelligence insights for operational and strategic decision-making.

The final Power BI solution converts raw incident information into an **interactive intelligence dashboard and operational reporting framework**.

---

# Project Workflow

```text
Raw Synthetic Data
        ↓
Data Profiling & Quality Assessment
        ↓
Data Cleaning
        ↓
Data Transformation
        ↓
SQL Analysis
        ↓
Power Query Analysis
        ↓
Star Schema Data Model
        ↓
DAX Measures
        ↓
Power BI Visualisation
        ↓
Intelligence Analysis
        ↓
Operational Recommendations
```

### 1. Synthetic Data Generation

A synthetic dataset was created using SQL Server through prompt engineering via AI tools (Perplextiy, OpenAI, Chatgpt, Gemini) to simulate fly-tipping intelligence across Kent.

The core model contains:

* **20,000 fly-tipping incidents**
* **12 Kent councils**
* **1,500 locations**
* **8 waste categories**
* Approximately **2,500 enforcement cases**
* Approximately **8,000 intelligence reports**

The data was deliberately designed to contain realistic data-quality issues.

---

### 2. Data Profiling & Quality Assessment

The raw data was assessed for:

* Missing values | Duplicate records | Invalid dates | Inconsistent categories | Invalid numerical values
* Inconsistent council/location naming | Missing intelligence and evidence

A key principle was to **identify data-quality problems before attempting to analyse the data**.

---

### 3. Data Cleaning

Power Query was used to clean and standardise the data.

Key activities included:

* Removing duplicate records | Standardising council names | Standardising waste categories | Converting dates and times into appropriate data types.
* Handling missing values | Identifying invalid records | Creating data-quality indicators.

---

### 4. Data Transformation

Additional analytical fields were created to support intelligence analysis, including:

* Year | Month | Day of Week | Weekend/Weekday | Time of Day
* Investigation Duration | Evidence indicators | Intelligence-gap indicators | Priority indicators

---

### 5. SQL Intelligence Analysis

SQL Server was used to investigate:

* Incident volumes | Geographic hotspots | Repeat locations | Waste-type patterns.
* Year-on-year trends | Enforcement activity | Investigation performance.
* Evidence availability | Intelligence gaps.

---

### 6. Power BI Data Model

A **star-schema model** was created consisting of six tables:

```text
DimCouncil
     ↓
DimLocation
     ↓
FlyTipIncidents
     ↓
 ┌───┴───────────────┐
 ↓                   ↓
FactEnforcementCases  FactIntelligenceReport

DimDate ─────────────→ FlyTipIncidents
DimWasteType ────────→ FlyTipIncidents
```

This structure allows incident, geographic, waste, enforcement and intelligence information to be analysed efficiently.

---

# Power BI Intelligence Dashboard

The dashboard was structured around five intelligence questions.

### Page 1 — What Is Happening?

Introduction - Imaginary project profile image showing how BI and Data Analytic could be used to solve Fly-tipping issues 

### Page 2 — What Is Happening?

Executive Intelligence overview

### Page 3 — Where Is It Happening?

Geographic intelligence 

### Page 4 — When & What Patterns Exist?

Trend and pattern Intelligence 

### Page 5 — What Enforcement Intelligence Is Available?

Investigation & Enforcement 

### Page 6 — What Intelligence Is Missing?

Intelligence-gap and priorities 

### Page 6 — What Intelligence Is Missing?

Hypothetical Intelligence Report

---

# Key Intelligence Analysis

The project uses the analytical results to identify:

* **Geographic concentration** — councils and locations experiencing higher levels of activity.
* **Recurring waste patterns** — waste categories contributing most to reported incidents.
* **Seasonal patterns** — periods when incident volumes increase.
* **Reporting patterns** — when incidents are most commonly discovered or reported.
* **Enforcement intelligence** — cases supported by available evidence.
* **Intelligence gaps** — areas where missing evidence or inconsistent information limits investigative opportunities.

The resulting findings are translated into operational considerations such as **targeted monitoring, prevention activity, improved evidence capture and more consistent intelligence recording**.

Because the dataset is synthetic, these findings represent **analytical scenarios rather than claims about actual Kent fly-tipping activity**.

---

# Skills Demonstrated

### Data Analytics

* Exploratory Data Analysis
* Trend Analysis
* Geographic Analysis
* Hotspot Analysis
* Pattern Identification
* KPI Development
* Intelligence Gap Analysis

### Data Cleaning & Transformation

* Power Query
* Data profiling
* Duplicate detection
* Missing-value handling
* Data standardisation
* Data validation
* Data transformation

### SQL

* Aggregations
* Joins
* CTEs
* Window functions
* Trend analysis
* Ranking
* Data-quality validation
* Intelligence analysis

### Power BI

* Star-schema modelling
* Relationship management
* Interactive dashboards
* KPI cards
* Maps
* Trend analysis
* Decomposition analysis
* Matrix/heatmap analysis
* Drill-down and filtering

### DAX

* `CALCULATE`
* `FILTER`
* `SUMX`
* `TOPN`
* `DISTINCTCOUNT`
* Time intelligence
* YoY analysis
* Percentage calculations
* Ranking
* Context-aware measures

### Intelligence Analysis

* Intelligence-led decision support
* Hotspot identification
* Investigation support
* Evidence analysis
* Intelligence-gap identification
* Operational prioritisation
* Strategic reporting

### Stakeholder Communication

The project demonstrates the ability to translate complex datasets into **clear, concise intelligence that can support operational teams, enforcement managers and strategic decision-makers**.

---

# Project Structure

```text
Kent-Fly-Tipping-Intelligence-Analytics
│
├── README.md
│
├── 01_Raw_Data
│   ├── FlyTipIncidents.csv
│   ├── EnforcementCases.csv
│   ├── IntelligenceReports.csv
│   └── ReferenceData.csv
│
├── 02_Data_Cleaning
│   ├── Power_Query_Steps.md
│   └── Data_Quality_Report.xlsx
│
├── 03_SQL
│   ├── 01_Data_Validation.sql
│   ├── 02_Hotspot_Analysis.sql
│   ├── 03_Trend_Analysis.sql
│   ├── 04_Enforcement_Intelligence.sql
│   └── 05_Intelligence_Gaps.sql
│
├── 04_PowerBI
│   └── Kent_FlyTipping_Intelligence.pbix
│
├── 05_Reports
│   └── Intelligence_Briefing.pdf
│
└── 06_Documentation
    ├── Data_Dictionary.xlsx
    ├── Methodology.md
    └── Assumptions.md
```

---

## Tools Used

**SQL Server | Power Query | Power BI | DAX | Excel | GitHub**

---

## Project Outcome

The completed project demonstrates an end-to-end analytical workflow:

> **Raw Data → Data Quality → Transformation → SQL Intelligence → BI Modelling → DAX → Visualisation → Intelligence → Operational Insight**

The emphasis is not simply on producing a Power BI dashboard, but on demonstrating how **data can be transformed into structured intelligence to support evidence-based operational and strategic decision-making.**

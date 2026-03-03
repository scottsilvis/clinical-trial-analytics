# Clinical Trial Analytics & Machine Learning Pipeline (Synthetic Data)
## Overview

This project demonstrates an end-to-end data science workflow using a realistic, fully synthetic clinical trial dataset.

The goal is to mirror how a data scientist would approach messy, longitudinal, multi-table data and translate it into predictive models and actionable insights using modern analytics and machine-learning tools.

The dataset is entirely synthetic and was generated programmatically to reflect realistic clinical, operational, and behavioral patterns while preserving privacy.

---

## Objectives

- Design and validate a relational clinical trial dataset
- Perform exploratory analysis using enrollment-time data only
- Prevent data leakage through strict temporal feature control
- Build and evaluate baseline predictive models for clinical response
- Quantify the contribution of treatment assignment vs. baseline risk
- Assess whether early on-treatment changes improve prediction
- Communicate findings clearly and defensibly

---

## Dataset Description

The project consists of five CSV files representing a simplified clinical trial ecosystem.

### 1. patients.csv — Baseline Patient Data
    
One row per patient with demographics, baseline labs, and treatment assignment.
    
**Key variables**
- Demographics: age, sex, bmi, smoker
- Clinical: baseline_severity, crp_mgL, alt_U_L, egfr_ml_min
- Operational: site_id, treatment_arm
- Behavioral: self_reported_adherence

---

### 2. visits.csv — Longitudinal Visit Data

Multiple rows per patient capturing repeated measurements over time.

Key variables:
- Time: visit_num, days_from_enroll
- Outcomes: severity_score
- Labs over time: crp_mgL, alt_U_L, egfr_ml_min
- Safety & behavior: med_adherence, adverse_event_flag, dropout_flag

---

### 3. outcomes.csv — Patient-Level Targets

Derived outcomes based on each patient’s final observed visit.

Key variables:
- responder_30pct — binary clinical response indicator
- pct_improvement_severity — continuous outcome
- serious_ae_flag — safety outcome
- qol_score — quality-of-life proxy

---

### 4. sites.csv — Clinical Site Metadata

Operational characteristics of enrollment sites.

Key variables:
- region, site_size, urbanicity
- site_quality_index — observable proxy for site-level effects

---

### 5. notes.csv — Synthetic Clinical Notes (Optional NLP Extension)

Short free-text visit notes with labeled tone.

Key variables:
- clinical_note
- note_tone_label (positive / neutral / negative)

---

## Project Structure

```
.
├── README.md
├── requirements.txt
├── data/
│   ├── patients.csv    # ignored
│   ├── visits.csv      # ignored
│   ├── outcomes.csv    # ignored
│   ├── sites.csv       # ignored
│   └── notes.csv       # ignored
│
├── r/
│   ├── 01_load_to_sqlite.nb.html
│   ├── 02_baseline_EDA.sqlite.nb.html
│   ├── 03_baseline_modeling.nb.html
│   ├── 04_model_simplification.nb.html
│   └── 05_early_treatment_signal.nb.html
|
├── scripts/
│   └── 01_load_to_sqlite.R
|
└── sql/
    ├── 01_sites.sql
    ├── 02_patients.sql
    ├── 03_visits.sql
    ├── 04_outcomes.sql
    └── 05_notes.sql

```

---

## Modeling Approach

### Baseline Modeling (Enrollment-Time Only)

Predictive models were first constructed using only enrollment-time attributes, serving as a reference point for later analyses.

- Logistic regression was used for interpretability
- Severe class imbalance (~3% responders) required careful metric selection
- Evaluation emphasized precision–recall AUC, with ROC–AUC used for context

**Key finding:**

Baseline disease severity was the dominant predictor of response, with treatment assignment providing strong incremental signal.

---

### Model Simplification & Interpretability

Several reduced models were evaluated to assess tradeoffs between performance and defensibility:

- Full baseline model
- Baseline model excluding baseline_severity
- Objective labs only
- Labs + demographics

**Key finding:**

Removing the composite severity score caused performance to collapse toward the null model, indicating that baseline severity captures clinically meaningful information not recoverable from individual labs or demographics.

---

### Early On-Treatment Feature Evaluation

The final phase assessed whether early on-treatment changes improve prediction beyond baseline risk.

Features engineered from the first follow-up visit included:

- Changes and rates of change in severity and labs
- Time since enrollment
- Early medication adherence

**Key finding:**

Early on-treatment features did not materially improve predictive performance. Baseline severity and treatment assignment remained dominant, suggesting that meaningful response signal emerges later in the treatment course.

---

### Evaluation Metrics

Because response is rare, model performance was assessed using metrics appropriate for imbalanced outcomes:

- Precision–Recall AUC (primary)
- ROC–AUC (contextual)
- Calibration and interpretability of coefficients

---

### Key Skills Demonstrated
    
- Relational data modeling (SQLite, SQL)
- Data integrity and leakage prevention
- Exploratory data analysis and hypothesis checking
- Logistic regression with imbalanced outcomes
- Feature engineering with temporal awareness
- Model comparison and interpretability tradeoffs
- Clear analytical communication

---

### Notes on Synthetic Data
    
- All data is fully simulated
- No real patients, institutions, or medications are represented
- Patterns were intentionally embedded to allow meaningful discovery without being trivial

---

### Possible Extensions

These were intentionally scoped out of this project but are natural next steps:

- Later on-treatment or longitudinal modeling
- Time-to-event (survival) analysis
- Hierarchical or site-level effects
- NLP modeling on clinical notes
- Model deployment or monitoring pipelines

---

### Disclaimer

This project is for educational and demonstration purposes only.
It does not represent real clinical evidence and should not be used for medical decision-making.

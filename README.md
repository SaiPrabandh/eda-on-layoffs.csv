# eda-on-layoffs.csv
# Layoffs 2020-2023: Data Cleaning and Exploratory Data Analysis  This repository contains the data cleaning and exploratory data analysis (EDA) of global layoffs data between 2020 and 2023. The project uses a combination of **MySQL** for cleaning and querying, and **CSV data** as the input source.



## 📝 Dataset

- **Source:** [layoffs.csv]
- **Description:** The dataset includes details about layoffs such as:
  - Company
  - Location
  - Industry
  - Total employees laid off
  - Percentage laid off
  - Date of layoff
  - Funding raised
  - Company stage
  - Country

## 🧹 Data Cleaning Steps

The SQL script performs comprehensive data cleaning:
1. **Removing Duplicates**
   - Created staging tables.
   - Generated `row_num` partitions by company and other fields.
   - Removed duplicate rows where `row_num > 1`.
2. **Standardizing Data**
   - Trimmed extra spaces from company names.
   - Unified industry names (`Crypto`, `Cryptocurrency`, etc.) into a consistent label.
   - Standardized country names (e.g., `United States.` to `United States`).
   - Converted `date` column from text to `DATE` type.
3. **Handling Missing Values**
   - Filled missing industries based on other records of the same company.
   - Removed records where both `total_laid_off` and `percentage_laid_off` were missing.

## 📊 Exploratory Data Analysis (EDA)

Key EDA queries included:

- **Maximum layoffs**
  - Max total laid off: 12,000
  - Companies with 100% layoffs.
- **Layoffs by Company**
  - Total laid off per company, ranked descending.
- **Layoffs by Industry**
  - Aggregated totals by industry.
- **Layoffs by Country**
  - Country-level totals (with the US having the highest).
- **Time Analysis**
  - Layoffs aggregated by:
    - Year
    - Month
    - Cumulative monthly totals.
- **Stage of Company**
  - Total layoffs by funding stage (e.g., Post-IPO).
- **Top Companies Per Year**
  - Ranking top 5 companies with highest layoffs each year.

The final output provides a comprehensive picture of layoff trends across years, industries, and regions.

## 💻 How to Reproduce

1. **Load the Dataset**
   - Import `layoffs.csv` into your MySQL environment.

2. **Run the SQL Script**
   - Execute `layoffs_eda.sql` step by step in your SQL editor.
   - Be sure to:
     - Create your working database (e.g., `world_layoffs`).
     - Adjust any file paths or permissions if needed.

3. **Explore Results**
   - View cleaned tables.
   - Inspect EDA outputs.

## ⚙️ Requirements

- MySQL (tested on MySQL 8+)
- SQL client or MySQL Workbench

## 📈 Example Insights

- The most layoffs were observed in **2022**.
- The **Technology** and **Crypto** industries were the most impacted.
- The United States accounted for the majority of layoffs.
- Some companies laid off their entire workforce.

## ✨ Future Work

- Visualization in Python or Power BI.
- Forecasting layoffs trends.
- Interactive dashboards.

## 🙌 Acknowledgements

Inspired by global layoff tracking datasets.

---

Feel free to fork or contribute!

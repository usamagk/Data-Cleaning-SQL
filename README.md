# Layoffs Data Analysis (SQL)

## Data Cleaning

I came across a dataset tracking tech layoffs across companies, industries, and countries. It was messy in all the usual ways, duplicate rows, inconsistent naming, empty fields, dates stored as text. so I decided to use it as practice for two things every analyst ends up doing constantly, cleaning data before you can trust it, and then actually digging into it to find something worth saying.

This repo covers both halves, the cleaning process and the analysis that came after it.

## The problem with the raw data

Before cleaning, the dataset had:
- Duplicate entries that would have skewed any aggregation
- Company names with random leading/trailing spaces
- The same industry spelled three different ways e.g. "Crypto", "CryptoCurrency", "Crypto Currency".
- "United States" appearing with a random trailing period in some rows
- Dates stored as plain text instead of an actual date type
- A mix of nulls and empty strings that needed to be treated consistently
- Missing industry values that could actually be recovered from other rows for the same company

## My cleaning approach

I didn't touch the raw table directly

1. **Made a staging copy** of the raw data to work on, so the original stays untouched no matter what I do
2. **Removed duplicates** using `ROW_NUMBER()` with `PARTITION BY` across all relevant columns, then deleted anything flagged as a repeat
3. **Standardized text fields**, trimmed stray whitespace from company names, merged inconsistent industry labels into one standard name, fixed the "United States." anomaly
4. **Converted the date column** from text into a proper `DATE` type so it can actually be used in time-based analysis
5. **Handled missing data thoughtfully**, rather than just deleting rows with missing industries, I joined the table against itself to check if the same company had that value filled in elsewhere, and used it to backfill instead of losing the row
6. **Dropped rows only when there was truly nothing to salvage**, specifically, rows missing both `total_laid_off` and `percentage_laid_off`, since those are the core numbers this dataset is meant to provide
7. **Cleaned up after myself**, removed the helper column I added just for deduplication, once it had served its purpose


## The analysis (EDA)

Once the data was clean, I moved on to exploring it, starting simple and building up to more complex questions:

- **Basics first**: the single biggest layoff event, which companies shut down entirely (100% of staff laid off), and totals by company, industry, country, and company stage
- **Bringing in time**: how layoffs moved month by month and year by year, plus a rolling cumulative total to see the overall trend build up over time
- **Deeper questions**: which company had the worst year in each given year (not just overall), which companies had layoffs in more than one year, how each industry's layoffs changed year-over-year, and whether heavily-funded companies were actually any safer from cutting staff

The full set of queries is in the analysis file. Please 

## Tools used
- MySQL

## Files
- `Data Cleaning - Layoffs` — the full cleaning script, commented step by step
- `Exploratory Data Analysis - Layoffs` — the exploratory analysis, from basic aggregations to window-function-based queries
- `Dataset_layoffs` — the original dataset is also provided


## Findings, trends & patterns

- **Layoffs weren't evenly spread across time** — they clustered heavily around specific periods rather than trickling in steadily, which lines up with the broader tech industry slowdown of 2022-2023.
- **A handful of industries and company stages absorbed a disproportionate share of the cuts**, while others were barely affected, worth calling out by name once the numbers are pulled.
- **Funding didn't equal safety.** Several companies that had raised large amounts of money still laid off large percentages of their workforce, and some shut down entirely, a good reminder that cash raised isn't the same as a stable business.
- **Some companies weren't one-time cases**, a few show up with layoffs in more than a single year, suggesting ongoing struggles rather than a single correction.
- **A few companies stand out as the "worst" in their respective year**, rather than the same names dominating every year, meaning the biggest culprit shifted depending on what was happening in the market at that time.





---
*Part of my data analytics portfolio — feedback welcome.*

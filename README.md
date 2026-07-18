**Layoffs Data Cleaning (SQL)**
This repo walks through exactly how I cleaned it, step by step, using pure SQL.

## The problem with the raw data

Before cleaning, the dataset had:
- Duplicate entries that would have skewed any aggregation
- Company names with random leading/trailing spaces
- The same industry spelled three different ways (e.g. "Crypto", "CryptoCurrency", "Crypto Currency")
- "United States" appearing with a random trailing period in some rows
- Dates stored as plain text instead of an actual date type
- A mix of nulls and empty strings that needed to be treated consistently
- Missing industry values that could actually be recovered from other rows for the same company

## My approach

I never touch the raw table directly — first rule of data cleaning. Instead:

1. **Made a staging copy** of the raw data to work on, so the original stays untouched no matter what I do
2. **Removed duplicates** using `ROW_NUMBER()` with `PARTITION BY` across all relevant columns, then deleted anything flagged as a repeat
3. **Standardized text fields** — trimmed stray whitespace from company names, merged inconsistent industry labels into one standard name, fixed the "United States." anomaly
4. **Converted the date column** from text into a proper `DATE` type so it can actually be used in time-based analysis later
5. **Handled missing data thoughtfully** — rather than just deleting rows with missing industries, I joined the table against itself to check if the same company had that value filled in elsewhere, and used it to backfill instead of losing the row
6. **Dropped rows only when there was truly nothing to salvage** — specifically, rows missing both `total_laid_off` and `percentage_laid_off`, since those are the core numbers this dataset is meant to provide
7. **Cleaned up after myself** — removed the helper column I added just for deduplication, once it had served its purpose

## Why I did it this way

Anyone can write `DELETE FROM table WHERE column IS NULL`. The harder (and more useful) skill is figuring out which nulls can actually be recovered from elsewhere in the data before you decide to drop anything. That self-join step to backfill missing industries is the part of this project I'm most glad I did properly instead of taking a shortcut.

## Tools used
- MySQL

## Files
- `Data Cleaning - Layoffs.sql` — the full cleaning script, commented step by step

## What's next

I'm planning to add an exploratory analysis on top of this cleaned dataset — things like which industries and company stages were hit hardest, and how layoffs trended over time. That'll live in a follow-up file in this same repo.

---
*Part of my data analytics portfolio — feedback welcome.*

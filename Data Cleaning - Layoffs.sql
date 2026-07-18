-- Data Cleaning

-- First we will check the raw data
select *
from layoffs;

-- I will follow these steps
-- Copy of raw data
-- Deleting duplicates
-- Standardizing the data
-- nulls and blanks
-- removing any column or rows

-- It's a good practice to never change the raw data and work on it by making a copy of it.

-- We will create a similar table and will also add a new column to identify duplicates and then insert the layoffs data into it
CREATE TABLE `layoffs_staging` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Lets check if the layoffs_staging is created
select *
from layoffs_staging;

-- Lets import the data into it
insert into layoffs_staging
select *, row_number() 
over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
from layoffs;

-- lets check if we duplicate data into layoffs_staging as they will have a row_num greater than 1
select *
from layoffs_staging
where row_num > 1;
-- lets delete them from the table
delete
from layoffs_staging
where row_num > 1;
-- Lets check if the duplicates are deleted from layoffs_staging
select *
from layoffs_staging;


-- lets standardize the data
-- first we will check the company column
select company
from layoffs_staging;

-- lets check if there are any spaces before the company names
select company
from layoffs_staging
where (company like ' %' or company like '% ');

-- lets remove these extra spaces before or after the company names using update and trim
update layoffs_staging
set company = trim(company);
-- for checking purposes we can rerun the previous code snippet

-- lets explore the industry column
select distinct industry
from layoffs_staging
where industry is not null
order by industry asc;

-- We can see that there are 3 different names for the crypto industry, we have to find the most used and standardiz it
select *
from layoffs_staging
where industry like '%Crypto%';

-- As we can see that 'Crypto' is the most used, so we will change all other names to crypto as well
update layoffs_staging
set industry = 'Crypto'
where industry like '%Crypto%';


-- lets explore the county column if it has any problems
select distinct country
from layoffs_staging
order by country asc;

-- there is an anomaly with the country united sated, we will resolve it
update layoffs_staging
set country = trim(trailing '.' from country)
where country like 'united states%';

-- lets check if the anomaly is resolve or not
select distinct country
from layoffs_staging
where country like 'united states%';

-- lets check the date column
select * 
from layoffs_staging;

# lets change the date column into real date formate and date data type
update layoffs_staging
set `date` = str_to_date(`date`, '%m/%d/%Y');

-- now lets change the data type of the date column 
alter table layoffs_staging
modify column `date` date;


-- Now lets move to the nulls and blanks

select *
from layoffs_staging
where (industry is null or industry = '');
-- we will check if we can populate this missing data
select *
from layoffs_staging
where company like 'airbnb%';
-- as we can see the data is avaiable for this company in another row, lets copy this data to the nulls or blanks

-- lets join the table with itself, to see the missing value and the available data in front of it
select *
from layoffs_staging as tab1
join layoffs_staging as tab2
	on tab1.company = tab2.company
where (tab1.industry is null or tab1.industry = '') and (tab2.industry is not null or tab2.industry != '');

-- lets null all the blanks so that we can replace them with avaiable data
update layoffs_staging
set industry = null
where industry = '';

-- check the table again with join
select *
from layoffs_staging as tab1
join layoffs_staging as tab2
	on tab1.company = tab2.company
where (tab1.industry is null and tab2.industry is not null);

-- now we can populate the nulls using update and join

update layoffs_staging as tab1
join layoffs_staging as tab2
	on (tab1.company = tab2.company and tab1.location = tab2.location)
set tab1.industry = tab2.industry
where (tab1.industry is null and tab2.industry is not null);
-- The blanks/nulls are populated in the industry column

-- Our main columns are total_laid_off and percentage_laid_off, so we will delete the rows where both are gonna be nulls
select *
from layoffs_staging
where total_laid_off is null and percentage_laid_off is null;
-- lets delete it
delete 
from layoffs_staging
where total_laid_off is null and percentage_laid_off is null;

-- remember! we have added a new column named row_num which is in no use for us

-- lets check it first
select *
from layoffs_staging;

-- lets delete that too
alter table layoffs_staging
drop column row_num;

-- Now we have cleaned the date for our analysis, further cleaning can be done if required based on the objectives and goals

-- Exploratory Data Analysis
-- In EDA we will find patterns and trends based of off the cleaned layoffs data

select * from layoffs_staging;

-- Let's find out what's the biggest single layoff event, and the highest percentage laid off
select max(total_laid_off) as Biggest_single_layoff, max(percentage_laid_off) as Highest_percentage_laid_off
from layoffs_staging;

-- Let's find out which companies laid off 100% of their staff or went bankrupt
select * -- company, location, industry, total_laid_off, percentage_laid_off, funds_raised_millions
from layoffs_staging
where percentage_laid_off = 1;

-- Let's check the companies that went under (100% laid off) and also raised the most funding
select *
from layoffs_staging
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- What date range does this dataset actually cover?
select min(`date`) start_date, max(`date`) end_date
from layoffs_staging;


-- Total layoffs by company
select company, sum(total_laid_off) as total_laid
from layoffs_staging
group by company
order by total_laid desc
-- limit 10		-- we can get the results upto a specific range by using the limit keyword
;


-- Total layoffs by industry
select industry, sum(total_laid_off) as total_laid
from layoffs_staging
group by industry
order by total_laid desc;


-- Total layoffs by country
select country, sum(total_laid_off) as total_laid
from layoffs_staging
group by country
order by total_laid desc;


-- Total layoffs by company stage (Startup/Post-IPO/Acquired)
select stage, sum(total_laid_off) as total_laid
from layoffs_staging
group by stage
order by total_laid desc;


-- Total layoffs by year (let's check if it is getting worse or better over time)
select year(`date`) as yearly, sum(total_laid_off) as total_laid
from layoffs_staging
group by yearly
order by total_laid;


-- Total layoffs by month across all years combined and it will also show if there is a seasonal pattern
select month(`date`) as monthly, sum(total_laid_off) as total_laid
from layoffs_staging
where `date` is not null
group by monthly
order by monthly;


-- Average percentage of workforce laid off, by industry
select industry, round(avg(percentage_laid_off), 2) as avg_laid_per
from layoffs_staging
group by industry
order by avg_laid_per desc;


-- Let's find which country and industry combinations were hit hardest
select country, industry, round(avg(percentage_laid_off), 2) as avg_laid_per, sum(total_laid_off) as total_laid
from layoffs_staging
where total_laid_off is not null
group by country, industry
order by total_laid desc
limit 15;


-- Month-by-month total layoffs as a real timeline (year + month together)
select substring(`date`, 1, 7) as month_year, sum(total_laid_off) as total_laid
from layoffs_staging
where `date` is not null
group by month_year 
order by month_year asc;


-- Rolling total of layoffs over time, shows the running total month by month
-- useful for a line chart in Tableau/Power BI later
-- Let's create a CTE
with Rolling_total as
(
	select substring(`date`, 1, 7) as month_year, sum(total_laid_off) as total_laid
	from layoffs_staging
	where `date` is not null
	group by month_year
	order by month_year
)
select month_year, total_laid, sum(total_laid) over (order by month_year) as rolling_sum
from Rolling_total;


-- just checking the dateset
select *
from layoffs_staging;


-- Top 5 companies with the most layoffs per year
-- create a cte to fetch the data of companies with their yearly total
with company_year as
(
	select company, year(`date`) as `year`, sum(total_laid_off) as total_laid
    from layoffs_staging
    group by company, `year`
    ),
-- create a cte to get the data from above cte in the desired format
company_rank as
(
	select *, dense_rank() over (partition by `year` order by total_laid desc) as `rank`
    from company_year
    where `year` is not null
    )
select *
from company_rank
where `rank` <= 5
order by `year` asc, total_laid desc;


-- Companies that appear across MULTIPLE years with layoffs
select company, count(distinct extract(year from `date`)) as no_of_yrs #substring(`date`, 1, 4)
, sum(total_laid_off) as total_laid
from layoffs_staging
group by company
having count(distinct (extract(year from `date`))) > 1
order by no_of_yrs desc, total_laid desc;


-- Year-over-year change in layoffs by industry, is it improving or worsening per industry?
with industry_year as 
(
	select industry, year(`date`) as `year`, sum(total_laid_off) as total_laid
	from layoffs_staging
	where `date` is not null
	group by industry, `year`
)
select industry, `year`, total_laid, lag(total_laid) over (partition by industry order by `year` asc) as prev_yr_laid,
total_laid - lag(total_laid) over (partition by industry order by `year` asc) as yr_to_yr_change
from industry_year
where industry is not null
order by industry, `year`;


-- Companies that raised the most funding but STILL had high layoff percentages
select company, industry, total_laid_off, percentage_laid_off, funds_raised_millions
from layoffs_staging
where percentage_laid_off is not null
order by funds_raised_millions desc, percentage_laid_off desc;


-- Rank each company's layoff event against others in the same industry
select company, industry, total_laid_off, rank() over (partition by industry order by total_laid_off) as rank_within_industry
from layoffs_staging
where total_laid_off is not null
order by industry asc, rank_within_industry asc;














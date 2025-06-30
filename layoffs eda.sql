-- Data Cleaning:FIrst lets perform some data cleaning tasks
USE world_layoffs;
-- Output all the data
Select * 
from world_layoffs.layoffs;

-- Creating a staging table to avoid any data loss and its best practice to not work on raw data directly
 create table world_layoffs.layoffs_stagings
 like world_layoffs.layoffs;

insert world_layoffs.layoffs_stagings 
select *
from world_layoffs.layoffs;

select * from world_layoffs.layoffs_stagings;

-- step 1:Remove duplicates from the data

-- since we do not have any identifying column or something like canditate or primary key type column lets just create a new column row_number such that it can identify each row individually

select *,row_number() over(
partition by company,industry,total_laid_off,percentage_laid_off,`date`) as row_num 
from layoffs_stagings;


-- creating a cte for this and then checking duplicate rows first by checking row number if greater than 1 then its a duplicate mostly
with duplicate_cte as(
select *,row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
as row_num 
from layoffs_stagings
)
select * from duplicate_cte where row_num>1;

-- selecting casper first

select * from layoffs_stagings
where company='Casper'; 

-- removing duplicates
with duplicate_cte as(
select *,row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
as row_num 
from layoffs_stagings
)
delete from duplicate_cte where row_num>1;

-- this would return error as we cannot update the duplicate cte as per this mysql,so lets try another way

-- lets create a staging 2 here we take row_num then delete rows there instead of cte


CREATE TABLE `layoffs_stagings2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` double DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


insert into layoffs_stagings2
select *,row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
as row_num 
from layoffs_stagings;

-- Great we have created a staging 2 table and inserted now lets just delete rows with row_num>1

select count(*)
from layoffs_stagings2
where row_num>1; 

delete 
from layoffs_stagings2
where row_num>1;

-- We have completed removing the duplicates

-- Step-2:Standardizing the data

-- Firstly in the data company column there is an extra space at the beginning so first lets remove it

select company,trim(company) from layoffs_stagings2;

-- update by trimming

update layoffs_stagings2
set company=trim(company);

-- Now lets see about table "industry" column

select distinct industry
from layoffs_stagings2
order by 1;

 -- first there are 3 industries crypto,crypto currency,cryptocurrency so lets change it into 1

 select * 
 from layoffs_stagings2
 where industry like 'Crypto%';
 
 -- Yeah most of them are crypto but very few have remaining 2 names so lets just change them
 
 update layoffs_stagings2
 set industry='Crypto'
 where industry like 'Crypto%';
 
 -- It updated 3 rows it seems,now lets check location
 select distinct location
 from layoffs_stagings2
 order by 1;
 -- It seems fine so lets check country
  select distinct country
 from layoffs_stagings2
 order by 1;
 -- There are 2 united states one with a dot
 select * from layoffs_stagings2 
 where country like 'United States%'
 order by 1;
 
 update layoffs_stagings2
 set country='United States'
 where country like 'United States%';

-- 4 rows were affected which seems pretty fine
-- just in case lets check countries again

  select distinct country
 from layoffs_stagings2
 order by 1;

-- yeah this looks good
-- now lets get into date column,it is completely in wrong datatype instead of date datatype it is in text datatype,so we need to change that

select `date`
from layoffs_stagings2;

select `date`,str_to_date(`date`,'%m/%d/%Y')
from layoffs_stagings2;

-- now lets update the text to date

update layoffs_stagings2
set `date`=str_to_date(`date`,'%m/%d/%Y');
 
-- now finally updated lets check how it is now

select `date`
from layoffs_stagings2; 

-- now lets change datatype to date(make sure it is a staging table never perform alter on a actual data table)

alter table layoffs_stagings2
modify column `date` DATE;

select * 
from layoffs_stagings2;

-- so we have standardized the data a bit good so lets go step 3
-- Step 3:Dealing with the null values and blank values

-- First with the total_laid_off
 
select * 
from layoffs_stagings2
where total_laid_off is null;

-- If we have 2 nulls total_laid_off as well as percentage_laid_off then that data is pretty much useless to us 

select * 
from layoffs_stagings2
where total_laid_off is null
and percentage_laid_off is null;

-- It returned around 361 rows which is kind of unexpected
-- now lets see industry as well

select * 
from layoffs_stagings2
where industry is Null 
or industry='';
 
 -- It returned some 4 rows as well
 -- Now lets see one by one,first the airbnb
 
 select * 
from layoffs_stagings2
where company='airbnb';

-- There is a row that says it is travel industry so lets fill it up

update layoffs_stagings2
set industry='Travel'
where company='Airbnb';

 -- but to do this for multiple rows that have similar issue we can use the concept of joins
 
 select t1.industry,t2.industry
 from layoffs_stagings2 t1
 join layoffs_stagings2 t2
	on t1.company=t2.company
where (t1.industry is null or t1.industry='')
and (t2.industry is not null and t2.industry <> '') ;


-- great now lets update this

update layoffs_stagings2 t1
 join layoffs_stagings2 t2
	on t1.company=t2.company
set t1.industry =t2.industry
where (t1.industry is null or t1.industry='')
and (t2.industry is not null and t2.industry <> '') ;

-- it is saying 2 rows changed lets check that

 select t1.industry,t2.industry
 from layoffs_stagings2 t1
 join layoffs_stagings2 t2
	on t1.company=t2.company
where (t1.industry is null or t1.industry='')
and (t2.industry is not null and t2.industry <> '') ;

select * 
from layoffs_stagings2
where industry is Null 
or industry='';

-- still a company has null

select * from layoffs_stagings2
where company="Bally's Interactive";

-- there is only 1 row and it shows null for industry so we cannot do anything
-- similarly we cannot populate total laid off and percentage laid off since we cannot know total_laid_off or its percentage here since we do not know total number of employees present in the company

select * 
from layoffs_stagings2
where total_laid_off is null
and percentage_laid_off is null;

-- lets get rid of these

delete 
from layoffs_stagings2
where total_laid_off is null
and percentage_laid_off is null;

-- 361 rows deleted
-- now lets drop row_num column since we do not need any more

alter table layoffs_stagings2
drop column row_num;

select * 
from layoffs_stagings2;

-- iT IS SUCCESSFULLY deleted
-- So i think we can end the data cleaning here







						-- Lets start Exploratory Data Analysis
             

select * 
from layoffs_stagings2;


-- LETS START WITH SIMPLE ONES

select max(total_laid_off),max(percentage_laid_off)
from layoffs_stagings2;

-- THIS IS HUGE 12000 and 1% is not a good sign at all,lets check companies that have laid off 1% of their employees 

select *
from layoffs_stagings2
where percentage_laid_off=1;

--  116 rows has been returned,lets see in descending order of number of laid off 

select *
from layoffs_stagings2
where percentage_laid_off=1;

-- lets see the total laid off per company

select company,sum(total_laid_off)
from layoffs_stagings2
group by company
order by 2 desc;


-- lets see the range of layoffs dates

select min(`date`),max(`date`)
from layoffs_stagings2;

-- it ranged for 3 years

-- lets see total_laid_off per industry 

select industry,sum(total_laid_off)
from layoffs_stagings2
group by industry
order by 2 desc;

-- now lets see country wise too

select country,sum(total_laid_off)
from layoffs_stagings2
group by country
order by 2 desc;

-- usa the highest then india,netherlands follow on but the gap between usa and india is huge

select YEAR(`date`),sum(total_laid_off)
from layoffs_stagings2
group by YEAR(`date`)
order by 1 desc;
 
select stage,sum(total_laid_off)
from layoffs_stagings2
group by stage
order by 2 desc;

select substring(`date`,6,2) as month,sum(total_laid_off)
from layoffs_stagings2
group by month
order by 2 desc;

select substring(`date`,1,7) as month,sum(total_laid_off)
from layoffs_stagings2
group by month
order by 1 asc;

-- lets use cte to calculate cumulative sum of the total layoffs per month 

with rolling_total as
(
select substring(`date`,1,7) as month,sum(total_laid_off) as total_off
from layoffs_stagings2
group by month
order by 1 asc
)
select month,total_off,sum(total_off) over(order by month) as rolling_tot
from rolling_total;

-- now lets check company wise yearly cumulative layoffs too

 select company,year(`date`) as yearly,sum(total_laid_off)
from layoffs_stagings2
group by company,yearly
order by 3 desc;

with company_year as
(
 select company,year(`date`) as yearly,sum(total_laid_off) as total_laid_off
from layoffs_stagings2
group by company,yearly
order by 3 desc
)
select *,DENSE_RANK() over (partition by yearly order by total_laid_off desc) as ranking
from company_year
where yearly is not null
order by ranking asc;

-- but i think we just want top 5 per year

-- lets make this as another cte
with company_year as
(
 select company,year(`date`) as yearly,sum(total_laid_off) as total_laid_off
from layoffs_stagings2
group by company,yearly
order by 3 desc
),company_year_rank as (
select *,DENSE_RANK() over (partition by yearly order by total_laid_off desc) as ranking
from company_year
where yearly is not null
)
select *
from company_year_rank
where ranking<=5;
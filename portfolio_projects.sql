CREATE DATABASE PORTFOLIO_PROJECTS;

USE PORTFOLIO_PROJECTS;

SELECT * FROM cleaned_covidvaccination
order by 3,4;

/* 
SELECT * FROM covid_deaths
order by 3,4;
 */

-- select data we are going to use
select country, date, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2;

SHOW COLUMNS FROM covid_deaths;
SHOW COLUMNS FROM cleaned_covidvaccination;


ALTER TABLE covid_deaths CHANGE MyUnknownColumn country VARCHAR(50);

-- looking at total cases vs total deaths
select country, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_deaths;

-- looking at total cases vs population
-- shows percentage of total population got covid
select country, date, population,total_cases,  (total_cases/population)*100 as peoplePercentageInfected
from covid_deaths;


-- looking at countries with high infection rate compared to population
select country, population, MAX(total_cases), max(total_cases/population)*100 as peoplePercentageInfected
from covid_deaths
group by country, population;

-- showing countries/continent with highest death counts
select country, MAX(total_deaths) AS totalDeathCount
from covid_deaths
group by country
ORDER BY totalDeathCount DESC;


-- global numbers

select continent,country, MAX(total_cases) countrycases
from covid_deaths
where continent IS NOT NULL AND continent <> '' AND country IS NOT NULL
group by continent, country
order by continent asc, country asc, countrycases desc;

select continent,country, SUM(total_cases) countrycases
from covid_deaths
where continent IS NOT NULL AND continent <> '' AND country IS NOT NULL
group by continent, country
order by continent asc, country asc, countrycases desc;

select SUM(new_cases) newcases,SUM(new_deaths) newdeaths, (SUM(new_deaths)/SUM(new_cases))*100 as newdeathpercentage
from covid_deaths;

select date, SUM(new_cases) newcases,SUM(new_deaths) newdeaths, (SUM(new_deaths)/SUM(new_cases))*100 as newdeathpercentage
from covid_deaths
group by date;


select country from covid_deaths
where continent = 'europe'
group by country
order by country desc;

-- join both table

-- looking at total population vs total vaccinated
	select * from covid_deaths cd
	JOIN cleaned_covidvaccination cv
	ON cd.country = cv.country AND cd.date = cv.date;

	select cd.continent, cd.country, cd.date, cd.population, cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (partition by cd.country order by cd.country, cd.date) as RollingVaccination
    from covid_deaths cd
	JOIN cleaned_covidvaccination cv
	ON cd.country = cv.country AND cd.date = cv.date;
    
-- using cte

with PopVsVac(Continent, Country, Date, Population,new_vaccinations, RollingVaccination) AS
(
select cd.continent, cd.country, cd.date, cd.population, cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (partition by cd.country order by cd.country, cd.date) as RollingVaccination
    from covid_deaths cd
	JOIN cleaned_covidvaccination cv
	ON cd.country = cv.country AND cd.date = cv.date
)
SELECT * , (RollingVaccination/Population)*100
FROM PopVsVac;


-- using temp table

CREATE TEMPORARY TABLE PercentPopulatoinVaccinated
(
continent varchar(50),
location varchar(50),
date dateTime,
population numeric,
new_vaccination numeric,
rollingVaccination numeric);

INSERT INTO PercentPopulatoinVaccinated 
select cd.continent, cd.country, cd.date, cd.population, cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (partition by cd.country order by cd.country, cd.date) as RollingVaccination
    from covid_deaths cd
	JOIN cleaned_covidvaccination cv
	ON cd.country = cv.country AND cd.date = cv.date;

SELECT * , (RollingVaccination/Population)*100
FROM PercentPopulatoinVaccinated;

create view PercentPopulatoinVaccinated as 
select cd.continent, cd.country, cd.date, cd.population, cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (partition by cd.country order by cd.country, cd.date) as RollingVaccination
    from covid_deaths cd
	JOIN cleaned_covidvaccination cv
	ON cd.country = cv.country AND cd.date = cv.date;

SELECT * , (RollingVaccination/Population)*100
FROM PercentPopulatoinVaccinated;


CREATE DATABASE covid19;
USE covid19;

DESCRIBE coviddeaths;
DESCRIBE covidvaccinations;

-- fix dates for deaths table

SELECT STR_TO_DATE(date, '%m/%d/%Y') AS converted_date
FROM coviddeaths
ORDER BY date;

UPDATE coviddeaths
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE coviddeaths
MODIFY COLUMN date DATE;

-- -- fix dates for vaccines table


SELECT STR_TO_DATE(date, '%m/%d/%Y') AS converted_date
FROM covidvaccinations
ORDER BY date;

UPDATE covidvaccinations
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE covidvaccinations
MODIFY COLUMN date DATE;

-- at any date what % of population has covid 

SELECT location, date,total_cases, population, (total_cases/population)*100 AS percentige_ofcovid_inppl
FROM coviddeaths
WHERE continent !='' -- this counts out aggregated continent stats
ORDER BY 1,2;

-- at any date likelihood of dying if infected

SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_if_covid
FROM coviddeaths
WHERE continent !=''
ORDER BY 1,2;

-- counteies with highest infection rate compaired to its population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 AS max_percentige_ofcovid_infected
FROM coviddeaths
WHERE continent !=''
GROUP BY location, population
ORDER BY max_percentige_ofcovid_infected desc;

-- counteies with highest death count compaired to its population

SELECT location, population, MAX(total_deaths) AS total_death_count, MAX(total_deaths/population)*100 AS max_percentige_of_death
FROM coviddeaths
WHERE continent !=''
GROUP BY location, population
ORDER BY max_percentige_of_death desc;

-- world and continetns by aggrigated case/death count

SELECT location, MAX(total_cases), MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent =''
GROUP BY location
ORDER BY total_death_count desc;

-- per date cumulative new cases and new deaths in the world

SELECT date, SUM(new_cases), SUM(new_deaths), (SUM(new_deaths)/SUM(new_cases))*100 AS mortality_percentage
FROM coviddeaths
WHERE continent !=''
GROUP BY date
ORDER BY date;

-- population size vs vaccnated ppl

with popvsvacc as (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
 SUM(v.new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.date) as rolling_totalvaccinated
FROM coviddeaths d
JOIN covidvaccinations v
ON d.location = v.location
WHERE d.continent !=''
AND d.date = v.date
ORDER BY 2,3)

SELECT *, (rolling_totalvaccinated/population)*100 as vaccinated_perecent_of_Population
FROM popvsvacc;

-- temp population size vs vaccnated ppl


CREATE TEMPORARY TABLE POP_VS_VACC (
continent VARCHAR(50),
location VARCHAR(50),
date DATE,
population BIGINT,
new_vaccinations BIGINT,
rolling_totalvaccinated BIGINT)

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
 SUM(v.new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.date) as rolling_totalvaccinated
FROM coviddeaths d
JOIN covidvaccinations v
ON d.location = v.location
WHERE d.continent !=''
AND d.date = v.date
ORDER BY 2,3;

SELECT *
FROM POP_VS_VACC;

CREATE VIEW Vpopvsvac as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
 SUM(v.new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.date) as rolling_totalvaccinated
FROM coviddeaths d
JOIN covidvaccinations v
ON d.location = v.location
WHERE d.continent !=''
AND d.date = v.date
ORDER BY 2,3;

SELECT * FROM Vpopvsvac;
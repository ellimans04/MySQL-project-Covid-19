use covid_project;
SELECT *
FROM covid_deaths;
-- Check maximum infection rates  by continent for the period
-- Thus number of confirmed case over the population at risk
SELECT continent, Max(total_cases)/Max(population)*100 Infection_rate
FROM covid_deaths
WHERE continent is NOT NULL
GROUP BY 1
ORDER BY Infection_rate DESC;

-- Check maximum mortality rates by continent for the period
-- Thus the estimated total number of deaths in a population over the population, expressed per 100,000 population

SELECT continent, Max(total_deaths)/Max(population)*1000 Mortality_rate
FROM covid_deaths
WHERE continent is NOT NULL
GROUP BY 1
ORDER BY Mortality_rate DESC;
 
 -- Check maximum case fatality rates by continent
 -- The proportion of people diagnosed with a Covid-19, who end up dying of it.
SELECT continent, Max(total_deaths)/Max(total_cases)*100 CFR
FROM covid_deaths
WHERE continent is NOT NULL
GROUP BY 1
ORDER BY CFR DESC;

-- Get top 10 countries with high  mortality rate(MR) per 100 000

SELECT location, Max(total_deaths)/Max(population)*1000 MR
FROM covid_deaths
WHERE continent is NOT NULL AND location is NOT NULL
GROUP BY 1
ORDER BY MR DESC
LIMIT 10;

-- Get the global mortality rate for the period
SELECT Max(total_deaths)/Max(population)*1000 MR
FROM covid_deaths
WHERE location = 'World';

-- Get top 10 countries with high infection rates (IR) for the period

SELECT location, Max(total_cases)/Max(population)*100 IR
FROM covid_deaths
WHERE continent is NOT NULL AND location is NOT NULL
GROUP BY 1
ORDER BY IR DESC
LIMIT 10;

-- Get the global infection rate for the period
SELECT Max(total_cases)/Max(population)*100 MR
FROM covid_deaths
WHERE location = 'World';

-- Get the global cases, total deaths and case fatality rates
SELECT MAX(total_cases), MAX(total_deaths), MAX(total_deaths)/Max(total_cases)*100 AS Global_CFR
From covid_deaths
WHERE location = 'World';

-- Total Population vs Vaccinations
-- Shows Percentage of Population vaccinated (at least one Covid Vaccine) overtime

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, 
SUM(vacc.new_vaccinations) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as Rolling_Vaccinated
FROM covid_deaths deaths
Join covid_vaccinations vacc
	On deaths.location = vacc.location
	and deaths.date = vacc.date
WHERE deaths.continent is not null 
order by 2,3;

-- Show people fully vaccination percentage by continent over the period
SELECT continent, MAX(people_fully_vaccinated)/Max(population)*100 Fully_Vaccinated
FROM covid_vaccinations
WHERE continent is NOT NULL
GROUP BY 1
ORDER BY Fully_Vaccinated DESC;

-- Get global vaccination rate 
SELECT MAX(people_fully_vaccinated)/Max(population)*100 Fully_Vaccinated
FROM covid_vaccinations
WHERE location = 'World';

-- Top 10 fully vaccinated rates by country

WITH Vacc_rate AS (SELECT location, MAX(people_fully_vaccinated)/Max(population)*100 Fully_Vaccinated
FROM covid_vaccinations
WHERE continent is NOT NULL and location is NOT NULL 
GROUP BY 1)
SELECT *
FROM Vacc_rate
WHERE Fully_Vaccinated <=100
Order BY Fully_Vaccinated DESC
LIMIT 10;

-- Get 10 least fully vaccinated rate by countries
WITH Vacc_rate AS (SELECT location, MAX(people_fully_vaccinated)/Max(population)*100 Fully_Vaccinated
FROM covid_vaccinations
WHERE continent is NOT NULL and location is NOT NULL 
GROUP BY 1)
SELECT *
FROM Vacc_rate
WHERE Fully_Vaccinated <=100
Order BY Fully_Vaccinated 
LIMIT 10;

-- Get fully vaccinated rates by mortality and infection rate ranked by country

WITH vacc_impact AS(SELECT c.location country, MAX(v.people_fully_vaccinated)/Max(v.population)*100 Fully_Vaccinated,
Max(c.total_deaths)/Max(c.population)*1000 MR, Max(c.total_deaths)/Max(c.total_cases)*100 CFR
FROM covid_deaths c
JOIN covid_vaccinations v
ON c.location = v.location
and c.date = v.date
Group BY 1)
SELECT *
FROM vacc_impact
WHERE Fully_Vaccinated <=100 AND MR is NOT NULL AND CFR is NOT NULL
Order BY CFR DESC;-- export record to external file (vacc_impact.csv) for later Powr BI viz


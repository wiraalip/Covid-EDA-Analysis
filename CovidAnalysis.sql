SELECT * 
FROM CovidAnalysis..vaccinationscovid
ORDER BY 1 

SELECT * 
FROM CovidAnalysis..deathcovid
ORDER BY 1,2 

-- EDA --

-- Likelihood of dying if you have a covid in Indonesia 
SELECT location, date, CAST(total_cases AS FLOAT) AS total_cases, CAST(total_deaths AS FLOAT) AS total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT)*100.) as death_percentage
FROM CovidAnalysis..deathcovid
where location = 'Indonesia'
ORDER BY 1, 2

--Percentage of covid population 
SELECT location, date, total_cases, population, (CAST(total_cases AS FLOAT)/CAST(population AS FLOAT)*100.) as covid_percentage
FROM CovidAnalysis..deathcovid
ORDER BY 1, 2 

--Countries with Highest Infection Rate 
SELECT location, CAST(population AS FLOAT) AS population, MAX(CAST(total_cases AS FLOAT)) AS highest_infection, MAX((CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100.) as covid_infection_percentage
FROM CovidAnalysis..deathcovid
GROUP BY location, population
ORDER BY covid_infection_percentage desc

--Countries with the Highest Death Count 
SELECT location, MAX(CAST(total_deaths AS float)) AS highest_death_count
FROM CovidAnalysis..deathcovid
WHERE continent is not null 
GROUP BY location
ORDER BY highest_death_count desc

--Continent with the Highest Death Count 
SELECT continent, MAX(CAST(total_deaths AS float)) AS highest_death_count
FROM CovidAnalysis..deathcovid 
WHERE continent is not null 
GROUP BY continent 
ORDER BY highest_death_count desc

--Total Death Percentage in the World today 
SELECT SUM(CAST(new_cases AS float)) AS total_cases, SUM(CAST(new_deaths AS float)) AS total_deaths,  SUM(CAST(new_deaths AS float)) / SUM(CAST(new_cases AS float)) * 100 AS death_percentage
FROM CovidAnalysis..deathcovid 
where continent is not null

--Join Table 
SELECT * 
FROM CovidAnalysis..deathcovid dc
JOIN CovidAnalysis..vaccinationscovid vc
	ON dc.location = vc.location 
	AND dc.date = vc.date

--Vaccinated percentage 
WITH popvac AS (
SELECT dc.continent, dc.location, dc.date,  dc.population, vc.new_vaccinations, SUM(CAST(vc.new_vaccinations AS FLOAT)) OVER(PARTITION BY dc.location ORDER BY dc.location, dc.date) AS rolling_count_vacc
FROM CovidAnalysis..deathcovid dc
JOIN CovidAnalysis..vaccinationscovid vc
	ON dc.location = vc.location 
	AND dc.date = vc.date
WHERE dc.continent IS NOT NULL 
)
select *, (rolling_count_vacc / population)*100.0 AS vacc_percentage 
from popvac

--Highest Vaccinated Percentage 
WITH popvac AS (
SELECT dc.continent, dc.location, dc.date,  dc.population, vc.new_vaccinations, SUM(CAST(vc.new_vaccinations AS FLOAT)) OVER(PARTITION BY dc.location ORDER BY dc.location, dc.date) AS rolling_count_vacc
FROM CovidAnalysis..deathcovid dc
JOIN CovidAnalysis..vaccinationscovid vc
	ON dc.location = vc.location 
	AND dc.date = vc.date
WHERE dc.continent IS NOT NULL 
)
SELECT continent, location, MAX((rolling_count_vacc / population)*100.0) AS max_vaccinated_percentage
FROM popvac
GROUP BY continent, location
order by 1,2 

Create View percentagevaccines AS 
SELECT dc.continent, dc.location, dc.date,  dc.population, vc.new_vaccinations, SUM(CAST(vc.new_vaccinations AS FLOAT)) OVER(PARTITION BY dc.location ORDER BY dc.location, dc.date) AS rolling_count_vacc
FROM CovidAnalysis..deathcovid dc
JOIN CovidAnalysis..vaccinationscovid vc
	ON dc.location = vc.location 
	AND dc.date = vc.date
WHERE dc.continent IS NOT NULL 


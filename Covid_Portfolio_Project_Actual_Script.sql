SELECT *
FROM Covid_Project..Covid_Deaths
ORDER BY 3,4;

--SELECT *
--FROM Covid_vaccinations
--ORDER BY 3,4

--Select data that we are going to use
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Covid_Project..Covid_Deaths
ORDER BY 1,2 desc

--Looking at total cases vs total deaths
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM Covid_Project..Covid_Deaths
WHERE location LIKE '%INDIA%'
ORDER BY 1,2 

--Looking at total cases vs POPULATION
SELECT location,date,total_cases,population,(total_cases/population)*100 AS percent_pop_infected
FROM Covid_Project..Covid_Deaths
--WHERE location LIKE '%INDIA%'
ORDER BY 1,2 desc

--Looking at countries with highest infection rate compared to population
SELECT location,population,max(total_cases) AS highest_infection_count,max((total_cases/population)*100) AS percent_pop_infected
FROM Covid_Project..Covid_Deaths
GROUP BY location,population
ORDER BY percent_pop_infected desc

--Showing countries with highest death count per population
SELECT location,max(cast(total_deaths as int)) AS total_death_count
FROM Covid_Project..Covid_Deaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count desc

--Let's break things down by continent

--Continents with highest death count per population
SELECT continent,max(cast(total_deaths as int)) AS total_death_count
FROM Covid_Project..Covid_Deaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count desc


--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM Covid_Project..Covid_Deaths
--WHERE location LIKE '%INDIA%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATIONS
--Joining two tables

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) AS Rolling_people_vaccinated
	--(Rolling_people_vaccinated/population)*100
FROM Covid_Project..Covid_Deaths dea
JOIN Covid_Project..Covid_vaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3 

--USE CTE

WITH Pop_vs_vac(continent,location,date,population,new_vaccinations,Rolling_people_vaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) AS Rolling_people_vaccinated
	--(Rolling_people_vaccinated/population)*100
FROM Covid_Project..Covid_Deaths dea
JOIN Covid_Project..Covid_vaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 
)
SELECT *,(Rolling_people_vaccinated/population)*100
FROM Pop_vs_vac


--TEMP TABLE
DROP TABLE if exists #Percent_population_vaccinated
CREATE TABLE #Percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric
)

INSERT INTO #Percent_population_vaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) AS Rolling_people_vaccinated
	--(Rolling_people_vaccinated/population)*100
FROM Covid_Project..Covid_Deaths dea
JOIN Covid_Project..Covid_vaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3 

SELECT *,(Rolling_people_vaccinated/population)*100
FROM #Percent_population_vaccinated



--Creating view to store data for later visualisation

CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) AS Rolling_people_vaccinated
	--(Rolling_people_vaccinated/population)*100
FROM Covid_Project..Covid_Deaths dea
JOIN Covid_Project..Covid_vaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 

SELECT *
FROM percent_population_vaccinated
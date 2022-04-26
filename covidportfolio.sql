SELECT *
FROM Portfolio_Project.Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- SELECT *
-- FROM Portfolio_Project.Covid_Vaccinations
-- ORDER BY 3,4;

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project.Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2; 

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you have covid in Ireland

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
FROM Portfolio_Project.Covid_Deaths
WHERE location like '%Ireland%'
AND continent IS NOT NULL
ORDER BY 1,2; 

-- Looking at Total Cases vs Population
-- Shows what percetantage of population got Covid

SELECT Location, date, Population, total_cases, (total_cases / Population) * 100 as PercentPopulationInfected
FROM Portfolio_Project.Covid_Deaths
WHERE location like '%Ireland%'
AND continent IS NOT NULL
ORDER BY 1,2; 

-- Looking Countries with highest infection rate against population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 as PercentPopulationInfected
FROM Portfolio_Project.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc; 

-- Showing Countries with Highest Deaths per Population

SELECT Location, MAX(CAST(total_deaths as SIGNED)) as TotalDeathCount
FROM Portfolio_Project.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc;

-- Showing continents with highest death counts

SELECT continent, MAX(CAST(total_deaths as UNSIGNED)) as TotalDeathCount
FROM Portfolio_Project.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as UNSIGNED)) AS total_deaths, SUM(CAST(new_deaths AS UNSIGNED))/ SUM(new_cases) * 100 as DeathPercentage
FROM Portfolio_Project.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2; 

-- Total Cases against Total Deaths Percentage

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as UNSIGNED)) AS total_deaths, SUM(CAST(new_deaths AS UNSIGNED))/ SUM(new_cases) * 100 as DeathPercentage
FROM Portfolio_Project.Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Join Tables

SELECT *
FROM Portfolio_Project.Covid_Deaths dea
JOIN  Portfolio_Project.Covid_Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date;

-- Looking at the total population that had been Vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Portfolio_Project.Covid_Deaths dea
JOIN  Portfolio_Project.Covid_Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.date) as sum_vaccinations
FROM Portfolio_Project.Covid_Deaths dea
JOIN  Portfolio_Project.Covid_Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, sum_vaccinations) 
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.date) as sum_vaccinations
FROM Portfolio_Project.Covid_Deaths dea
JOIN  Portfolio_Project.Covid_Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *,  (sum_vaccinations/population) * 100
FROM PopvsVac;

-- TEMP TABLE

DROP TABLE IF EXISTS PercentPopVacc;
CREATE TEMPORARY TABLE PercentPopVacc
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
sum_vaccinations numeric
);

INSERT INTO PercentPopVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.date) as sum_vaccinations
FROM Portfolio_Project.Covid_Deaths dea
JOIN  Portfolio_Project.Covid_Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Create views for later visualisations

USE Portfolio_Project;
CREATE VIEW Ireland as 
SELECT Location, date, Population, total_cases, (total_cases / Population) * 100 as PercentPopulationInfected
FROM Portfolio_Project.Covid_Deaths
WHERE location like '%Ireland%'
AND continent IS NOT NULL
ORDER BY 1,2; 

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.date) as sum_vaccinations
FROM Portfolio_Project.Covid_Deaths dea
JOIN  Portfolio_Project.Covid_Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3;






























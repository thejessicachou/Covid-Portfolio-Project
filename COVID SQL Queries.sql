--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract COVID in the United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases::float)*100 as DeathPercentage
FROM covid_deaths
WHERE location LIKE '%States'


--Looking at highest death percentage by country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases::float)*100 as DeathPercentage
FROM covid_deaths
WHERE (total_deaths/total_cases::float)*100 > 0
ORDER BY deathpercentage DESC


--Looking at countries with the Highest Infection Rate compared to Population
--Removed continents which appear as countries
SELECT covid_deaths.location, MAX(total_cases), covid_deaths.population, MAX((covid_deaths.total_cases/covid_deaths.population::float)*100) as Infection_Rate
FROM covid_deaths
WHERE continent is not null
GROUP BY covid_deaths.location, covid_deaths.population
ORDER BY MAX((covid_deaths.total_cases/covid_deaths.population::float)*100) DESC


--Looking at countries with the Total Death Count
SELECT covid_deaths.location, MAX(total_deaths) as Total_Death_Count
FROM covid_deaths
WHERE continent is not null
GROUP by Location
HAVING MAX(total_Deaths) > 0
Order by MAX(total_deaths) DESC


--Looking at Highest Death Counts by Continents
--Removed income level results
SELECT location, max(total_Deaths) as Total_Death_Count_by_Continent
FROM covid_deaths
WHERE continent is null 
AND location NOT LIKE '%income'
GROUP BY location
ORDER BY max(total_Deaths) DESC


--Looking at Total Population vs Vaccinations 
SELECT dea.continent, dea.location, MAX(dea.population) AS Population, SUM(vac.new_vaccinations) AS Total_Vaccinated, (SUM(vac.new_vaccinations)/MAX(dea.population)::float)*100 AS Percent_Vaccinated
FROM covid_deaths AS dea
INNER JOIN covid_vaccines AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.location
ORDER BY dea.location


--Looking at Total Population vs Vaccinations by Date

WITH PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM covid_deaths AS dea
INNER JOIN covid_vaccines AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)
SELECT *, (RollingPeopleVaccinated/Population::float)*100
FROM PopsVac


--Creating a temp table with previous data
CREATE TABLE PercentPopulationVaccinated
(Continent VARCHAR (50), 
 Location VARCHAR (150), 
 Date TIME,
 Population NUMERIC, 
 New_Vaccinations NUMERIC, 
 RollingPeopleVaccinated NUMERIC) 
 
INSERT INTO PercentPopulationVaccinated
(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM covid_deaths AS dea
INNER JOIN covid_vaccines AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)

DROP TABLE IF EXISTS PercentPopulationVaccinated
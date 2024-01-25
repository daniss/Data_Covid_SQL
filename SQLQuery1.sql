SELECT *
FROM CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- Données qu'on va utilisé

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2


-- Nombre Total De Cas vs Nombre Total De Morts
-- Montre la chance de mourir si on attrape la COVID

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PourcentageDeMort
FROM CovidDeaths
ORDER BY 1, 2


-- Nombre Total De Cas vs Nombre Population
-- Pourcentage de la population à avoir la COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PourcentageInfecté
FROM CovidDeaths
ORDER BY 1, 2


-- Pays avec le taux d'infection le plus élevés comparer a la population

SELECT location, MAX(total_cases) AS MaxInfecté, population, MAX((total_cases/population))*100 AS PourcentageInfecté
FROM CovidDeaths
GROUP BY location, population
ORDER BY PourcentageInfecté DESC


-- Pays avec le plus haut taux de mort par habitant

SELECT location, MAX(cast(total_deaths as int)) AS NombreDeMort
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY NombreDeMort DESC


-- Par continent

SELECT continent, MAX(cast(total_deaths as int)) AS NombreDeMort
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY NombreDeMort DESC


-- Nombre Global

SELECT SUM(new_cases) AS TotalDeCas, SUM(CAST(new_deaths AS int)) AS TotalDeMort, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 as PourcentageDeMort
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Nombre total population vs vacination

WITH PopvsVac (continent, location, date, population, new_vaccinations, CumuleVaccination)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS int)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS CumuleVaccination
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, (CumuleVaccination/population)*100
FROM PopvsVac


-- CREER VIEW

CREATE VIEW PourcentagePopVacinée AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS int)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS CumuleVaccination
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent IS NOT NULL
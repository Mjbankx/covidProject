/SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT * 
 FROM covid_vaccin
 ORDER BY 3,4;*/

SELECT "location" , date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1,2;

-- looking at total cases vs total Deaths--

-- this shows the likelyhood of dieingif you contact covid in nigeria.

SELECT "location", date, total_cases ,total_deaths, (total_deaths /total_cases)* 100 AS death_percentage 
    FROM covid_deaths
        WHERE "location" LIKE '%Nigeria%'
        ORDER BY 1,2;
        
--looking at total_cases vs population--

--shows what percentage of population got covid--

SELECT "location", date, total_cases ,population, (total_cases/population)*100 AS death_percentage 
    FROM covid_deaths
        WHERE "location" LIKE '%Nigeria%'
        ORDER BY 1,2;*/
 
 --looking at countries with highest infection rate--
 
 
SELECT "location", population, Max(total_cases) AS highest_infection , 
    MAX(total_cases/population)*100 AS percentage_of_population
    FROM covid_deaths
        --where "location" like '%Nigeria%'--
        GROUP BY "location", population
        ORDER BY percentage_of_population DESC;
        
 -- this is showing the country with the highest death count per population--
 
 --showing it by location--
SELECT "location", MAX(total_deaths) AS total_death_count 
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY "location"
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY total_death_count DESC;
 
 --Breaking it down by contintent--

SELECT "continent", MAX(total_deaths:: INT) AS total_death_count 
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY "continent"
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY total_death_count DESC;

--showing the location with the highest death_count per population--

SELECT "location", MAX(total_deaths:: INT) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY "location"
ORDER BY total_death_count DESC;

--showing the continent and the location table--

SELECT continent, "location" FROM covid_deaths;

--GLOBAL NUMBERS--

SELECT date, population, total_cases, total_deaths, (total_cases/population)*100 AS death_percentage 
    FROM covid_deaths
    WHERE continent IS NOT NULL
       -- where "location" like '%Nigeria%'--
        ORDER BY 1,2;
        
-- Lets show it as location with the highest death count per population--

SELECT "location", MAX(total_deaths:: INT) AS total_death_count
FROM covid_deaths
WHERE continent  IS NULL
GROUP BY "location"
ORDER BY total_death_count DESC;

-- Lets show  continent with the highest death count per population--

SELECT continent, MAX(total_deaths:: INT) AS total_death_count
FROM covid_deaths
WHERE continent  IS NOT  NULL
GROUP BY continent
ORDER BY total_death_count DESC;

--Showing Global Numbers--

SELECT date, total_cases, total_deaths, --(total_cases/population)*100 as death_percentage 
    FROM covid_deaths
    WHERE continent IS NOT NULL
       -- where "location" like '%Nigeria%'--
        ORDER BY 1,2;
        
SELECT date, sum(new_cases) AS total_cases , SUM(new_deaths) AS total_death, 
SUM(new_deaths)/SUM(new_cases)*100 AS Percentage
   FROM covid_deaths
    WHERE continent IS NOT NULL
    GROUP BY date
    ORDER BY 1,2;
    

    
    
SELECT (SUM(new_deaths)/SUM(new_cases))*100 FROM covid_deaths;
    
    
    -- Looking at total population vs vaccination--
   
SELECT dea.continent AS Con, dea.location, dea.date, dea.population, vcc.new_vaccinations,
 sum(vcc.new_vaccinations:: INT) OVER (PARTITION BY dea.location ORDER BY "dea"."location",dea.date) AS Rollingpeoplevaccinated
FROM covid_deaths dea
JOIN covid_vaccin vcc
ON dea.location = vcc.location
AND dea.date = vcc.date
WHERE dea.continent IS NOT NULL
AND vcc.new_vaccinations IS NOT NULL
ORDER BY 2,3;

   
-- USE A CTE

WITH PopvsVac (continent , "location",date,population, new_vaccinations, Rollingpeoplevaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vcc.new_vaccinations,
 sum(vcc.new_vaccinations:: INT) OVER (PARTITION BY dea.location ORDER BY "dea"."location",dea.date) AS Rollingpeoplevaccinated
FROM covid_deaths dea
JOIN covid_vaccin vcc
    ON dea.location = vcc.location
    AND dea.date = vcc.date
WHERE dea.continent IS NOT NULL
AND vcc.new_vaccinations IS NOT NULL
--order by 2,3
)

SELECT *, (Rollingpeoplevaccinated/population)*100

FROM PopvsVac;



-- Temp table

DROP TABLE IF EXISTS percentagepopulationvaccinated;

CREATE TABLE percentagepopulationvaccinated (
    continent TEXT,
    LOCATION TEXT,
    date date,
    population NUMERIC,
    new_vaccinations NUMERIC,
    Rollingpeoplevaccinated INTEGER
);
INSERT INTO percentagepopulationvaccinated (continent, LOCATION, date, population, new_vaccinations, Rollingpeoplevaccinated)
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vcc.new_vaccinations ,
    SUM(vcc.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM 
    covid_deaths dea
JOIN 
    covid_vaccin vcc ON dea.location = vcc.location AND dea.date = vcc.date
WHERE 
    dea.continent IS NOT NULL
    AND vcc.new_vaccinations IS NOT NULL;

SELECT 
    *, 
    (Rollingpeoplevaccinated / population) * 100 AS PercentagePopulationVaccinated
FROM 
    percentagepopulationvaccinated;

-- Creating views for later visualization


CREATE VIEW percentage_population_vaccinated
AS 
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vcc.new_vaccinations ,
    SUM(vcc.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM 
    covid_deaths dea
JOIN 
    covid_vaccin vcc ON dea.location = vcc.location AND dea.date = vcc.date
WHERE 
    dea.continent IS NOT NULL
    AND vcc.new_vaccinations IS NOT NULL
    --order by 2,3;
 
 SELECT * FROM percentage_population_vaccinated;
 
 
 
 



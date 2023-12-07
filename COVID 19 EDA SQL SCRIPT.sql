SELECT *
FROM [Portfolio Project]..Covid_Deaths
Where continent is not null
order by 3,4

--SELECT *
--FROM [Portfolio Project]..Covid_Vaccinations
--order by 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..Covid_Deaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
 SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM [Portfolio Project]..Covid_Deaths
WHERE location = 'United Kingdom'
order by 1,2
-- On 04/21/2020, the highest death percentage was recorded in United Kingdom to the tune of 22.92%


--To find the top 10 locations with the highest death rate
WITH RankedDeaths AS (
    SELECT
        Location,
        date,
        total_cases,
        total_deaths,
        (total_deaths / total_cases) * 100 AS Death_Percentage,
        ROW_NUMBER() OVER (ORDER BY (total_deaths / total_cases) DESC) AS Death_Rank
    FROM
        [Portfolio Project]..Covid_Deaths
)
SELECT
    Location,
    date,
    total_cases,
    total_deaths,
    Death_Percentage
FROM
    RankedDeaths
WHERE
    Death_Rank <= 10;

-- Total Cases vs Total Deaths
 SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM [Portfolio Project]..Covid_Deaths
WHERE location = 'United Kingdom'
order by 1,2
-- On 04/22/2020, the highest death percentage was recorded in United Kingdom to the tune of 22.92%

-- Top 10 Death_Percentage in United Kingdom
SELECT TOP 10
    Location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS Death_Percentage
FROM
    [Portfolio Project]..Covid_Deaths
WHERE
    location = 'United Kingdom'
ORDER BY
    (total_deaths / total_cases) DESC;
-- The  month with the highest death percentage is April 2020.

--Total Cases vs Population. Shows the % of population that got Covid (Covid_Infection_Rate)
SELECT Top 10
Location, date, population, total_cases, (total_cases/population)*100 AS Covid_Infection_Rate
FROM [Portfolio Project]..Covid_Deaths
WHERE location = 'United Kingdom'
order by Covid_Infection_Rate DESC
--The highest covid infection rate based on population in United Kingdom happened in November 2023-

--Top country with highest covid infection rate compared to the population
SELECT Top 1
Location, date, population, total_cases, (total_cases/population)*100 AS Covid_Infection_Rate
FROM [Portfolio Project]..Covid_Deaths
order by Covid_Infection_Rate DESC
--The country with the highest covid infection rate is San Marino with the infection rate up to 74.6% of the population

--Top 10 countries with highest covid infection rate compared to the population.
SELECT Top 10
Location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percentage_Population_Infected
FROM [Portfolio Project]..Covid_Deaths
Group by Location, population 
Order by Percentage_Population_Infected DESC
--The top 10 countries with the highestcovid infection rates are San Marino, Cyprus, Brunei, Austria, South Korea, Faeroe Islands, Slovenia, Gibraltar, Martinique, and Andorra.

--Top 10 Countries with the Highest death count and percentage per population 
SELECT Top 10
Location, population, MAX(total_deaths) AS Highest_Death_Count, MAX((total_deaths/population))*100 AS Percentage_Population_Death
FROM [Portfolio Project]..Covid_Deaths
Group by Location, population 
Order by Percentage_Population_Death DESC

--Top Country with the Highest death count and Percentage per population 
SELECT Top 1
Location, population, MAX(total_deaths) AS Highest_Death_Count, MAX((total_deaths/population))*100 AS Percentage_Population_Death
FROM [Portfolio Project]..Covid_Deaths
Group by Location, population 
Order by Percentage_Population_Death DESC
--The country with the highest covid infection death rate is Peru with the death rate up to 0.65% of the population

--Countries with the Highest death count
SELECT Location, population, MAX(total_deaths) AS Total_Death_Count
FROM [Portfolio Project]..Covid_Deaths
Group by Location, population 
Order by Total_Death_Count DESC

--Top 10 Countries with the Highest death count
SELECT Top 10
Location, MAX(total_deaths) AS Total_Death_Count
FROM [Portfolio Project]..Covid_Deaths
Group by Location
Order by Total_Death_Count DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
--Continent with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM [Portfolio Project]..Covid_Deaths
Where continent is not null
Group by continent
Order by Total_Death_Count DESC

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From [Portfolio Project]..Covid_Deaths
where continent is not null 
--Group By date
order by 1,2

--JOIN THE 2 TABLES TOGETHER
SELECT *
FROM [Portfolio Project]..Covid_Deaths
JOIN [Portfolio Project]..Covid_Vaccinations
ON [Portfolio Project]..Covid_Deaths.location = [Portfolio Project]..Covid_Vaccinations.location
and [Portfolio Project]..Covid_Deaths.date = [Portfolio Project]..Covid_Vaccinations.date
--     OR
SELECT *
FROM [Portfolio Project]..Covid_Deaths dea
JOIN [Portfolio Project]..Covid_Vaccinations vac
ON dea.location = vac.location
and dea.date = vac.date

--Total Population vs Vaccinations. Shows percentage of population that has received at least one covid vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [Portfolio Project]..Covid_Deaths dea
JOIN [Portfolio Project]..Covid_Vaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location  Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..Covid_Deaths dea
JOIN [Portfolio Project]..Covid_Vaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..Covid_Deaths dea
JOIN [Portfolio Project]..Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..Covid_Deaths dea
JOIN [Portfolio Project]..Covid_Vaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 


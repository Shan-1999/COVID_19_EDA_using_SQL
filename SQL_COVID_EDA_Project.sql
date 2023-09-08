Select * 
From CovidDeaths
where continent is not null
Order by 3,4

/*Select * 
From CovidVaccinations
	Order by 3,4 
	
Select Data that we are going to be using */
use Covid

Select Location, date, total_cases, new_cases, total_deaths,population
From CovidDeaths
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows Likelyhood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths,
CONVERT(float,total_deaths/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
	From CovidDeaths 
		where location like 'India'
		Order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

Select Location, date, population, total_cases,
CONVERT(float,total_deaths/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
	From CovidDeaths 
		where location in ('India')
		Order by 1,2

--Looking at countries with Highest Infection Rate compared to population

SELECT
    location,
    population,
	MAX(total_cases) AS Highest_Infection_Count,
    ((MAX(total_cases) / NULLIF(CAST(population AS FLOAT), 0)) * 100) AS Percentage_Infected
FROM
    CovidDeaths
GROUP BY
    location,
    population
ORDER BY
    Percentage_Infected DESC;

--To Show Countries with Highest Death Count per population


SELECT
    location,
    population,
	MAX(CAST(total_deaths AS INT)) AS Highest_Death_Count,
    ((MAX(total_deaths) / NULLIF(CAST(population AS FLOAT), 0)) * 100) AS Percentage_deaths
	
FROM
    CovidDeaths
Where continent is not null
GROUP BY
    location,
	population
ORDER BY
    Highest_Death_Count DESC;

--LETS BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population	

SELECT 
	continent, 
	MAX(CAST(total_deaths AS INT)) AS Max_deaths 
FROM 
	CovidDeaths
WHERE continent is not null
GROUP BY 
	continent
ORDER BY Max_deaths DESC;

--GLOBAL NUMBERS(New Cases)

Select 
	--date,
	SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS INT)) as total_deaths, 
	SUM(CAST(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
From 
	CovidDeaths
WHERE 
	continent is not null
--GROUP BY date
ORDER BY 
	1,2 
	
--Table #2---> Covid Vaccinations

--CTE

With PopvsVac (Continent, location,date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
		SUM(COALESCE(CAST(CV.new_vaccinations AS Bigint),0))
		OVER 
		(PARTITION BY CD.location Order By CD.location,CD.date)
		AS RollingPeopleVaccinated
From 
	CovidDeaths CD
JOIN 
	CovidVaccinations CV
ON 
	CD.location=CV.location
AND 
	CD.date=CV.date
WHERE 
	CD.continent is not null 
--ORDER BY 2,3

)
Select 
	*, (RollingPeopleVaccinated/population)
From 
	PopvsVac


--TEMP TABLE

DROP Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
		SUM(COALESCE(CAST(CV.new_vaccinations AS Bigint),0))
		OVER 
		(PARTITION BY CD.location Order By CD.location,CD.date)
		AS RollingPeopleVaccinated
	--	(RollingPeopleVaccinated/population)*100
From 
	CovidDeaths CD
JOIN 
	CovidVaccinations CV
ON 
	CD.location=CV.location
AND 
	CD.date=CV.date
--WHERE 
	--CD.continent is not null 
--ORDER BY 2,3

Select	*,(RollingPeopleVaccinated/population)*100
	from #PercentPopulationVaccinated

--Creating View to store data for later visualization

Create View PercentPopulationVaccinated
AS
	Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
		SUM(COALESCE(CAST(CV.new_vaccinations AS Bigint),0))
		OVER 
		(PARTITION BY CD.location Order By CD.location,CD.date)
		AS RollingPeopleVaccinated
	--	(RollingPeopleVaccinated/population)*100
From 
	CovidDeaths CD
JOIN 
	CovidVaccinations CV
ON 
	CD.location=CV.location
AND 
	CD.date=CV.date
WHERE 
	CD.continent is not null 
--ORDER BY 2,3
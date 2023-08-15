Select *
From Portfolio_Project..Covid_Deaths$
order by 3,4

--Select *
--From Portfolio_Project..Covid_Vac$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..Covid_Deaths$
order by 1,2



-- Looking at Total Cases vs. Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select 
location, 
date, 
total_cases, 
total_deaths,
CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)*100 AS death_rate
From Portfolio_Project..Covid_Deaths$
order by 1,2

-- Looking at Total Cases vs. Total Deaths in United States
Select 
location, 
date, 
total_cases, 
total_deaths,
CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)*100 AS death_rate
From Portfolio_Project..Covid_Deaths$
Where location like '%States%' and continent is not null
order by 1,2

-- Looking at Total Cases vs. Population in United States
-- Shows what percentage of population contracted covid
Select 
location, 
date, 
total_cases, 
population ,
CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)*100 AS Percentage_Contracted
From Portfolio_Project..Covid_Deaths$
Where location = 'United States'and continent is not null
order by 1,2

-- Countries with highest infection rate compared to population
Select 
location, 
population,
MAX(total_cases) as Highest_Infection_Count, 
MAX(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT))*100 AS Percentage_Population_Infected
From Portfolio_Project..Covid_Deaths$
Where continent is not null
Group by 
location, 
population
order by 
Percentage_Population_Infected desc

-- Shows the countries with the highest death count per population
Select 
location, 
MAX(cast(Total_deaths as int)) as Total_Death_Count
From Portfolio_Project..Covid_Deaths$
Where continent is null
Group by location
order by Total_Death_Count desc

-- Showing the continent with the highest death count
Select 
continent, 
MAX(cast(Total_deaths as int)) as Total_Death_Count
From Portfolio_Project..Covid_Deaths$
Where continent is not null
Group by continent
order by Total_Death_Count desc



-- DEATH PERCENTAGE PER DAY
Select
date,
SUM(new_cases) AS total_cases,
SUM(CAST(new_deaths AS INT)) AS total_deaths,
CASE
	WHEN SUM(new_cases) = 0 THEN NULL
	ELSE SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0) * 100
    END AS death_rate
From Portfolio_Project..Covid_Deaths$
Where continent IS NOT NULL
Group BY date
Order by date;


-- DEATH PERCENTAGE WORLDWIDE
Select
SUM(new_cases) AS total_cases,
SUM(CAST(new_deaths AS INT)) AS total_deaths,
CASE
	WHEN SUM(new_cases) = 0 THEN NULL
	ELSE SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0) * 100
	END AS death_rate
From Portfolio_Project..Covid_Deaths$
Where continent IS NOT NULL


-- Joining the covid death table with covid vaccination table
Select *
From Portfolio_Project..Covid_Deaths$ dth
join Portfolio_Project..Covid_Vac$ vac
     on dth.location = vac.location
	 and dth.date = vac.date

-- Looking at Total Population vs. Vaccination
-- Total people vaccinated
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (PARTITION BY dth.location Order by dth.location, dth.date) AS Rolling_Total_Vaccinations
From Portfolio_Project..Covid_Deaths$ dth
JOIN Portfolio_Project..Covid_Vac$ vac
     ON dth.location = vac.location
     AND dth.date = vac.date
Where dth.continent IS NOT NULL
Order by dth.location, dth.date;

-- How many people in each country are vaccinated
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (PARTITION BY dth.location Order by dth.location, dth.date) AS Rolling_Total_Vaccinations
--,(Rolling_Total_Vaccinations/population)*100
From Portfolio_Project..Covid_Deaths$ dth
JOIN Portfolio_Project..Covid_Vac$ vac
     ON dth.location = vac.location
     AND dth.date = vac.date
Where dth.continent IS NOT NULL
Order by 2,3


--USE CTE
with popvsVac (Continent, location, date, population, new_vaccinations, Rolling_Total_Vaccinations)
as 
(
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (PARTITION BY dth.location Order by dth.location, dth.date) AS Rolling_Total_Vaccinations
--,(Rolling_Total_Vaccinations/population)*100
From Portfolio_Project..Covid_Deaths$ dth
JOIN Portfolio_Project..Covid_Vac$ vac
     ON dth.location = vac.location
     AND dth.date = vac.date
Where dth.continent IS NOT NULL
--ORDER BY 2,3
)
Select *, (Rolling_Total_Vaccinations/population)*100
From PopvsVac



--Temp Table
DROP Table If exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
Rolling_Total_Vaccinations numeric
)

insert into #percentPopulationVaccinated
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (PARTITION BY dth.location Order by dth.location, dth.date) AS Rolling_Total_Vaccinations
--,(Rolling_Total_Vaccinations/population)*100
From Portfolio_Project..Covid_Deaths$ dth
JOIN Portfolio_Project..Covid_Vac$ vac
     ON dth.location = vac.location
     AND dth.date = vac.date
--WHERE dth.continent IS NOT NULL
--ORDER BY 2,3

Select *, (Rolling_Total_Vaccinations/population)*100
From #percentPopulationVaccinated



--Creating View

Create View PercentPopulationVaccinated as 
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) 
OVER (PARTITION BY dth.location Order by dth.location, dth.date) AS Rolling_Total_Vaccinations
--,(Rolling_Total_Vaccinations/population)*100
From Portfolio_Project..Covid_Deaths$ dth
JOIN Portfolio_Project..Covid_Vac$ vac
     ON dth.location = vac.location
     AND dth.date = vac.date
Where dth.continent IS NOT NULL
--ORDER BY 2,3

Select *
From percentPopulationVaccinated
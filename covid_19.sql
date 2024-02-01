Select *
From covid_deaths
Order By 3,4;

-- Select *
-- From covid_vaccinations
-- Order By 3,4;


-- Likelihood of dying from COVID-19, if contracted, in the United States
Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From covid_deaths
Where location Like '%states%'
and continent is not null
Order by 1,2;

-- Total cases vs population
-- Shows percentage of the population infected with COVID-19 in the United States
Select location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
From covid_deaths
Where location Like '%states%'
and continent is not null
Order By 2;

-- Countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as max_cases, MAX(total_cases/population)*100 as percent_population_infected
From covid_deaths
Where continent is not null
Group by location, population
Order by percent_population_infected Desc;

-- Countries with highest death count per population
Select location, MAX(total_deaths) as total_deaths
From covid_deaths
Where continent is not null
Group by location
Order by total_deaths Desc;

-- Continents with highest death count per population
Select location, MAX(total_deaths) as total_deaths
From covid_deaths
Where continent is null
Group by location
Order by total_deaths Desc;

-- Death percentage worldwide per day
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases)*100) as death_percentage
From covid_deaths
Where continent is not null
Group By date
Order By 1,2;

-- Total death percentage worldwide
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases)*100) as death_percentage
From covid_deaths
Where continent is not null
Order By 1,2;

-- Total population vs vaccinations 
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (Partition By d.location Order By d.location, d.date) as rolling_people_vaccinated
From covid_deaths as d
Join covid_vaccinations as v
	On d.location = v.location
    and d.date = v.date
Where d.continent is not null
Order by  1,2,3;

With pop_vs_vac
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (Partition By d.location Order By d.location, d.date) as rolling_people_vaccinated
From covid_deaths as d
Join covid_vaccinations as v
	On d.location = v.location
    and d.date = v.date
Where d.continent is not null
)
Select *, (rolling_people_vaccinated/population)*100 as rolling_percent_vaccinated
From pop_vs_vac;

DROP Table if exists percent_population_vaccinated;
Create Temporary Table percent_population_vaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (Partition By d.location Order By d.location, d.date) as rolling_people_vaccinated
From covid_deaths as d
Join covid_vaccinations as v
	On d.location = v.location
    and d.date = v.date
Where d.continent is not null

Select *, (rolling_people_vaccinated/population)*100 as rolling_percent_vaccinated
From percent_population_vaccinated;

Create View percent_population_vaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (Partition By d.location Order By d.location, d.date) as rolling_people_vaccinated
From covid_deaths as d
Join covid_vaccinations as v
	On d.location = v.location
    and d.date = v.date
Where d.continent is not null

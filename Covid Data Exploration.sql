Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidDeaths
--Order by 3,4

-- Data Exploration
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Death percentage by location
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where location like '%States%'
and continent is not null
order by 1,2

-- Percentage Population affected by location
Select location, date, population, total_cases, (total_cases/population)*100 as population_affected
From PortfolioProject..CovidDeaths
--where location like '%States%'
order by 1,2;

-- Population percentage infected by location
Select location, population, MAX(total_cases) as highest_infection_count, Max((total_cases/population))*100 as population_infected
From PortfolioProject..CovidDeaths
--where location like '%States%'
Group by location, population
order by population_infected desc

--total death count by location
Select location, Max(Cast (total_deaths as int)) as total_death_Count
From PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null
Group by location
order by total_death_Count desc

--total death count by continent
Select location, Max(Cast (total_deaths as int)) as total_death_Count
From PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is null
Group by location
order by total_death_Count desc

--continent highest death count 
Select continent, Max(Cast (total_deaths as int)) as total_death_Count
From PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null
Group by continent
order by total_death_Count desc

--total number of cases, death and death_percentage each day till now 
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(total_deaths as int))/sum(total_cases))*100 as death_percentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
--, (rolling_people_vaccinations/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
--, (rolling_people_vaccinations/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (rolling_people_vaccinations/population)*100
from PopvsVac

--Temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinations numeric
)
insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
--, (rolling_people_vaccinations/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select*, (rolling_people_vaccinations/population)*100
from #percentpopulationvaccinated


--createing view for data visvualisation.

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(conver(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinations
--, (rolling_people_vaccinations/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from percentpopulationvaccinated
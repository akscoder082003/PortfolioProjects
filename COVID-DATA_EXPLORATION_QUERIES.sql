select*from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select*from [PortfolioProject]..CovidVaccinations order by 3,4

--Select Data that we are going to be using
select Location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from PortfolioProject..CovidDeaths where location like 'india' order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths 
--where location like 'india' 
order by 1,2

-- Looking at countries with highest infection rate compared ti population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like 'india'
group by location, population 
order by PercentagePopulationInfected desc

-- showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'india'
where continent is not null
group by location
order by TotalDeathCount desc


-- Let's break things down by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like 'india'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing continent with the highest death count per population
select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location like 'india'
where continent is not null
-- group by date
order by 1,2


--Looking at total population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (ROllingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- use CTE
with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
select*, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- TEMP table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 

select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later Visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated


select *
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 3,4

select *
from [Portfolio Project]..CovidVaccinations$
order by 3,4

--select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from [Portfolio Project]..CovidDeaths$
order by 1,2

--Looking at Total cases vs Total deaths
--Shows Likelihood of dying if you conract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from [Portfolio Project]..CovidDeaths$
--where location like '%states%'
where continent is not null
order by 1,2

--Lookingat the total cases vs the population
--shows what percentage of population got covid

select location,date,total_cases,population, (total_cases/population)*100 as Percentpopulationinfected
from [Portfolio Project]..CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to thepopulation

select location,population, MAX(total_cases) as Highestinfectioncount, MAX(total_cases/population)*100 as Percentpopulationinfected
from [Portfolio Project]..CovidDeaths$
--where location like '%states%'
Group by location,population
order by Percentpopulationinfected DESC


--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing countries with the highest death count per population

select location, MAX (cast (total_deaths as int)) as Totaldeathcount
from [Portfolio Project]..CovidDeaths$
--where location like '%states%'
where continent is null
Group by location
order by  Totaldeathcount DESC

select continent, MAX (cast (total_deaths as int)) as Totaldeathcount
from [Portfolio Project]..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by  Totaldeathcount DESC


--Showing the continents with the highest deathcount per population

select continent, MAX (cast (total_deaths as int)) as Totaldeathcount
from [Portfolio Project]..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by  Totaldeathcount DESC


--GLOBAL NUMBERS

select date,SUM(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as deathpercentage
from [Portfolio Project]..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by date
order by 1,2

select SUM(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as deathpercentage
from [Portfolio Project]..CovidDeaths$
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2


--Covid vaccination table begins

--Looking at total  population vs vaccination

select *
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location= vac.location
	and dea.date= vac.date

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations))OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated,
--(rollingpeoplevaccinated/population)*100
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location= vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


--CTE

with PopvsVac (Continent,location,Date,Population,New_vaccinations, rollingpeoplevaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations))OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location= vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
) 
Select*,(rollingpeoplevaccinated/population)*100
From PopvsVac

 
 --TEMP TABLE

  DROP TABLE if exists #PercentPopulationVaccinated
 Create Table  #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 Location nvarchar(255),
 Date date,
 Population BIGINT,
 New_vaccinations BIGINT,
 Rollingpeoplevaccinated BIGINT
 )


 Insert into #PercentPopulationVaccinated
 Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as BIGINT))OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location= vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select*,(rollingpeoplevaccinated/population)*100
From #PercentPopulationVaccinated 

 
 --Creating view to store data for later Visualisations

 
 Create view PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as BIGINT))OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
	on dea.location= vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

-- To view the PercentPopulationVaccinated data stored in view

IF OBJECT_ID ('dbo.PercentPopulationVaccinated', 'V') IS NOT NULL
  DROP VIEW dbo.PercentPopulationVaccinated;
  go
 Create view dbo.PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations as BIGINT))OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100 as PercentPopulationVaccinated
from [Portfolio Project].[dbo].CovidDeaths$ dea
join [Portfolio Project].[dbo].CovidVaccinations$ vac
	on dea.location= vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select name, SCHEMA_NAME(schema_id) as schemaname, type_desc
from sys.views
where name= 'percentpopulationvaccinated';


select top 1000*
from dbo.PercentPopulationVaccinated;

Select*
from PercentPopulationVaccinated
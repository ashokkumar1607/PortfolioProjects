


--select data that is to be used
select location,date,total_cases,new_cases,total_deaths,population
from dbo.CovidDeaths
order by 1,2

-- Total Cases Vs Total Deaths
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 [Death Percentage]
from dbo.CovidDeaths
where location='India'
order by 2

--Total Cases Vs Population
select location,date,population,total_cases,(total_cases/population)*100 [Perecentage Population that got covid]
from dbo.CovidDeaths
where location='India' 
order by 2


--Countries with highest infection rates
select location,population,max(total_cases) [Total Infection Count],max((total_cases/population))*100 [Perecentage Population Infected]
from dbo.CovidDeaths
where continent is not null
group by location,population
order by [Perecentage Population Infected] desc

--Checking for the correctness of the data against World Health Organistion's data
select max(total_cases) [Total Cases in Cyprus]
from dbo.CovidDeaths 
where location='cyprus' and  continent is not null

--Countries with the highest death count
select location,max(total_deaths) [Total Death Count] 
from dbo.CovidDeaths
where continent is not null
group by location
order by [Total Death Count] desc



--Countries with highest death count per population
select location,population,max(total_deaths) [Total Death Count],max((total_deaths/population))*100 [Percentage Population Died]
from dbo.CovidDeaths
group by location,population 
order by [Percentage Population Died] desc

--Death Count by Continent 
select continent,max(total_deaths) [Total Death Count] 
from dbo.CovidDeaths
where continent is not null
group by continent
order by [Total Death Count] desc

--Global Numbers

select date,sum(new_cases) [Total Cases], sum(new_deaths) [Total Deaths],sum(new_deaths)/sum(new_cases)*100 [Death Percentage]
from dbo.CovidDeaths
where continent is not null and new_cases<>0 
group by date
order by date

--Global Deth Percentage
select sum(new_cases) [Total Cases], sum(new_deaths) [Total Deaths],sum(new_deaths)/sum(new_cases)*100 [Death Percentage]
from dbo.CovidDeaths
where new_cases<>0

--Joining the two tables
select *
from dbo.CovidDeaths dea
join dbo.CovidVaccinationsnew vac
on dea.location=vac.location and dea.date=vac.date

--Total Population Vs Vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from dbo.CovidDeaths dea
join dbo.CovidVaccinationsnew vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--Rolling Count of the number of new vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) [Rolling Count]
from dbo.CovidDeaths dea
join dbo.CovidVaccinationsnew vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--Rolling Count Vs Population
with populationvsvac(continent,location,date,population,new_vaccinations,[Rolling Count])
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) [Rolling Count]
from dbo.CovidDeaths dea
join dbo.CovidVaccinationsnew vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

)
select *,([Rolling Count]/population)*100 [Rolling Vs Population]
from populationvsvac


--temp table 
create table #percentpopulationvaccinated(
continent nvarchar(255),location nvarchar(255),date datetime,population numeric,new_vaccinations numeric,[Rolling Count] numeric
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) [Rolling Count]
from dbo.CovidDeaths dea
join dbo.CovidVaccinationsnew vac
on dea.location=vac.location and dea.date=vac.date

select *,([Rolling Count]/population)*100 
from #percentpopulationvaccinated


--View to store data for visulizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinationsnew vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null

select * from PercentPopulationVaccinated

create view view1 as 
select date,sum(new_cases) [Total Cases], sum(new_deaths) [Total Deaths],sum(new_deaths)/sum(new_cases)*100 [Death Percentage]
from dbo.CovidDeaths
where continent is not null and new_cases<>0 
group by date


select * from view1
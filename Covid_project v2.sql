select * 
from coviddeaths 
order by 3,4

select * 
from covidvaccination
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from coviddeaths 
order by 1,2

--looking for total Cases Vs total Deaths 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)
from coviddeaths
order by 1,2

--since totaldeath and toalcases have data type is : nvarchar which is string so change this into decimal 

--for this i firt copied table into another table now another copy is created 
select * 
into coviddeaths_copy
from coviddeaths 

alter table coviddeaths_copy alter column total_cases Decimal(18,2)
alter table coviddeaths_copy alter column total_deaths Decimal(18,2)

alter table coviddeaths alter column total_cases Decimal(18,2)
alter table coviddeaths alter column total_deaths Decimal(18,2)

--now it is done so Death_percentage 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from coviddeaths
order by 1,2

--if I want to see united states dealth rates
--likelhood of dying if you contract covid in your country 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from coviddeaths
where location like '%state%'
order by 1,2

--looking at total cases vs population 

select location, date, total_cases, population, (total_cases/population)*100 as PercentageInfected
from coviddeaths
where location like '%state%'
order by 1,2

--highest infection rate  
select location, population, max(total_cases) as highestinfected, max((total_cases/population))*100 as PercentageInfected
from coviddeaths
group by location, population
order by PercentageInfected desc

--countries with highest death count per population 
select location, max(cast(total_deaths as int)) as totaldeathcounts
from coviddeaths 
where continent is  not null
group by location
order by totaldeathcounts desc

--lets break this by contients 

select location, max(cast(total_deaths as int)) as totaldeathcounts
from coviddeaths 
where continent is null
group by location
order by totaldeathcounts desc

--continent, --showing continent with highest death rate 
select continent, max(cast(total_deaths as int)) as totaldeathcounts
from coviddeaths 
where continent is not null
group by continent
order by totaldeathcounts desc

--total cases each day--global numbers 

select  date, sum(new_cases) as total_cases 
from coviddeaths
where continent is not null
group by date
order by total_cases desc



--total death percentage 
select sum(new_cases) as total_cases, sum(new_deaths) as total_death, sum(new_deaths)/sum(new_cases)*100 as Deathpercentage 
from coviddeaths
where continent is not null
--group by date
order by 1,2


Select * from [dbo].[covidvaccination]

--lets join this two tables 

select d.continent, d.location, d.date, d.population, v.new_vaccinations
from coviddeaths as d
join covidvaccination as v 
 on d.location=v.location
 and d.date=v.date
where d.continent is not null 
order by 2,3

--rolling count 

select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as bigint)) over (Partition by d.location order by d.location, d.date rows unbounded preceding) 
from coviddeaths as d
join covidvaccination as v 
 on d.location=v.location
 and d.date=v.date
where d.continent is not null 
order by 2,3

--CTE Common Table Expression (can't have order by caluse)

With PopvsVac (continent, location, date, population, new_vacciantion, rollingvaccination)
as 
(select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as bigint)) over (Partition by d.location order by d.location, d.date rows unbounded preceding) as rollingvaccination
from coviddeaths as d
join covidvaccination as v 
 on d.location=v.location
 and d.date=v.date
where d.continent is not null 
--order by 2,3
)
select *, (rollingvaccination/population)*100
from PopvsVac


---Temp table 

drop table if exists #PercentPopulationVaccinated 

create table #PercentPopulationVaccianted
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccination numeric, 
rollingvaccination numeric
)



insert into #PercentPopulationVaccianted
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as bigint)) over (Partition by d.location order by d.location, d.date rows unbounded preceding) as rollingvaccination
from coviddeaths as d
join covidvaccination as v 
 on d.location=v.location
 and d.date=v.date
where d.continent is not null 
--order by 2,3

select *, (rollingvaccination/population)*100
from #PercentPopulationVaccianted


---Creating view to store data for later visualizations 

create view PercentPopulationVaccianted as 
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as bigint)) over (Partition by d.location order by d.location, d.date rows unbounded preceding) as rollingvaccination
from coviddeaths as d
join covidvaccination as v 
 on d.location=v.location
 and d.date=v.date
where d.continent is not null 
--order by 2,3

select * from PercentPopulationVaccianted
---checking the table contents
select top 5 *
from CovidDeaths

select top 5 *
from CovidVaccinations

--- compare total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from CovidDeaths
where location like 'Ita%'
Order by location, date

--- total cases vs population
select location, date, population, total_cases, (total_deaths / population) * 100 as DeathPercentage
from CovidDeaths
where location like 'Ita%'
Order by location, date

--- Countries with high infection rate compared to population
select location, population, max (total_cases) as Max_Cases
, avg (total_cases / population) * 100 as AvgInfection
, max (total_cases / population) * 100 as MaxInfection
from CovidDeaths
Group by location, population
Order by AvgInfection desc

--- avg deaths per infection cases
select location
, avg (total_deaths / total_cases) * 100 as AvgDeaths
from CovidDeaths
Group by location
Order by AvgDeaths desc

--- Total death rate per continent
select continent, max (cast (total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not NULL
group by continent
Order by TotalDeathCount desc

--- global numbers
select SUM (new_cases) as TotalCases
, SUM (cast (new_deaths as int)) as TotalDeaths
, SUM (cast (new_deaths as int)) / SUM (new_cases ) * 100 as DeathRate
from CovidDeaths
where continent is not NULL
order by 1, 2

--- CTE vaccinations over the tot population
WITH PopVac (Continent, Location, Date, Population, new_vaccinations, PeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum (cast (vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
--- (PeopleVaccinated / Population) * 100 is what I want to achieve
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
--- order by 1, 2, 3
)
select *, (PeopleVaccinated / Population) * 100 as VaccinatedPercent
from PopVac

--- TempTable vaccinations over the tot population
drop table if exists #PopVac
create table #PopVac (
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
PeopleVaccinated numeric
)
insert into #PopVac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum (cast (vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
--- (PeopleVaccinated / Population) * 100 is what I want to achieve
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
--- order by 1, 2, 3
select *, (PeopleVaccinated / Population) * 100 as VaccinatedPercent
from #PopVac

--- create view for data viz
create view PopVac as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum (cast (vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
-- (PeopleVaccinated / Population) * 100 is what I want to achieve
from CovidDeaths as dea
join CovidVaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
-- order by 1, 2, 3

--- view the view
select * 
from PopVac

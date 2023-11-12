select *
from dbo.CovidDeaths$
order by 3,4


select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from dbo.CovidDeaths$
where location = 'United States'
order by 1,2


select location, date, total_cases, population, (total_cases/population)*100 as death_percentage
from dbo.CovidDeaths$
--where location = 'Egypt'
order by 1,2


-- countries with most infection rate compared to population

select location, max(total_cases) as infection_count, population, max((total_cases/population)*100) as percentofpopulationinfection
from dbo.CovidDeaths$
group by location, population
--having location = 'Egypt'
order by 1,2

-- countries with most death rate compared to population

select location, max(total_deaths) as deaths_count, population, max((total_deaths/population)*100) as percentofpopulationdeaths
from dbo.CovidDeaths$
group by location, population
--having location = 'Egypt'
order by 1,2


select location, Max(cast(total_deaths as int)) as total_deaths
from dbo.CovidDeaths$
where continent is not null
group by location
order by total_deaths desc

-- Creating a View for late visualization of total deaths in each Country
Create view total_deaths_by_country as
select location, Max(cast(total_deaths as int)) as total_deaths
from dbo.CovidDeaths$
where continent is not null
group by location

select * from total_deaths_by_country order by total_deaths desc

select Sum(cast(total_deaths as int)) as total_deaths_count
from dbo.CovidDeaths$
where location = 'Egypt'




with PopvsVac (Continent, Location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select det.continent, det.location, det.date, det.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by det.location order by det.location, det.date) as rolling_people_vaccinated
from dbo.CovidVaccinations$ as vac
join dbo.CovidDeaths$ as det on det.location = vac.location
and det.date = vac.date
where det.continent is not null
)

select * , round((rolling_people_vaccinated/population) * 100,3) as vaccinated_percentege
from PopvsVac



Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into	#PercentPopulationVaccinated
select det.continent, det.location, det.date, det.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by det.location order by det.location, det.date) as rolling_people_vaccinated
from dbo.CovidVaccinations$ as vac
join dbo.CovidDeaths$ as det on det.location = vac.location
and det.date = vac.date
where det.continent is not null

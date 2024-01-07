select *
from covid.coviddeaths
where continent is not null 
order by 3,4;

-- select *
-- from covid.covidvaccinations
-- order by 3,4;

-- Select data that we are going to be using
select location, date, total_cases_per_million, new_cases, total_deaths_per_million, new_deaths, population
from covid.coviddeaths
ORDER BY 1, STR_TO_DATE(date, '%m/%d/%Y');

-- Looking at total cases per million versus total deaths, the likelihood of dying if you contract covid
select location, date, total_cases_per_million, total_deaths_per_million, (total_deaths_per_million/total_cases_per_million)*100 as DeathPercentage
from covid.coviddeaths
ORDER BY 1, STR_TO_DATE(date, '%m/%d/%Y');


-- Looking at total cases vs population 
select location, date, total_cases_per_million, population, ((total_cases_per_million*1000000)/population)*100 as PopulationWithCovid
from covid.coviddeaths
ORDER BY 1, STR_TO_DATE(date, '%m/%d/%Y');

-- Looking at countries with highest infection rate compared to population 
select location, population, max(total_cases_per_million) as HighestInfectionCount, max((total_cases_per_million/population))*100 as PercentPopulationInfected
from covid.coviddeaths
group by location, population
order by PercentPopulationInfected desc;


-- Showing countries with highest death count per population 
select location, max(CAST(total_deaths AS SIGNED)) as TotalDeathCount
from covid.coviddeaths
where continent is not null 
group by location
order by TotalDeathCount desc;


-- Global Numebers
select date, sum(new_cases), sum(cast(new_deaths as signed)) as total_deaths, sum(cast(new_deaths as signed))/sum(new_cases)*100 as DeathPercentage-- total_deaths, (total_deaths/total_cases_per_million)*100 as DeathPercentage
from covid.coviddeaths
where continent is not null
group by date
order by date asc, str_to_date(date, '%m%d%y');


-- Covid Vaccinations data
select *
from covid.covidvaccinations;


-- joining the data
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as signed)) OVER (partition by dea.location order by dea.location) as RollingPeopleVaccinated
FROM covid.coviddeaths dea
join covid.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- cannot use a newly created column to make another column, so one way to fix this is by making a CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as signed)) OVER (partition by dea.location order by dea.location) as RollingPeopleVaccinated
FROM covid.coviddeaths dea
join covid.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
)
select *
from PopvsVac;


-- another way is to make a temp table
-- create table #PercentPopulationVaccinated
-- (
-- continent nvarchar(255),
-- location nvarchar(255),
-- date datetime
-- population numeric, 
-- new_vaccinations numeric, 
-- RollingPeopleVaccinated numeric
-- )
-- Insert into #PercentPopulationVaccinated
-- select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as signed)) OVER (partition by dea.location order by dea.location) as RollingPeopleVaccinated
-- FROM covid.coviddeaths dea
-- join covid.covidvaccinations vac
-- 	on dea.location = vac.location
--     and dea.date = vac.date
-- where dea.continent is not null
-- select *, (RollingPeopleVaccinated/population)*100
-- from #PercentPopulationVaccinated;




-- CREATE TABLE #PercentPopulationVaccinated
-- (
--     continent nvarchar(255),
--     location nvarchar(255),
--     date datetime,
--     population numeric, 
--     new_vaccinations numeric, 
--     RollingPeopleVaccinated numeric
-- );
-- INSERT INTO #PercentPopulationVaccinated
-- select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated
-- FROM
--     covid.coviddeaths dea
-- JOIN
--     covid.covidvaccinations vac
-- ON
--     dea.location = vac.location
--     AND dea.date = vac.date
-- WHERE
--     dea.continent IS NOT NULL;
-- SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
-- FROM #PercentPopulationVaccinated;



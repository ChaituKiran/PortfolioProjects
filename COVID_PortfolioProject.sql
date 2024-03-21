Select *
From PortfolioProject.dbo.CovidDeaths
where continent is not Null
Order By 3,4

Select *
From PortfolioProject.dbo.CovidVaccinations
Order By 3,4

-- Select The data we are going to using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
where continent is not Null
Order By 1,2

-- Looking at Total cases vs Total Deaths
-- Shows likelihood  of dying if you  contract covid  in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
Order By 1,2

-- Looking at total cases vs Population
-- Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Order By 1,2

-- Looking at countries with highest infection rate compared to population

Select location, population, Max(total_cases) as HighestInfectioncount, Max((total_cases/population))*100 as
PercentagePopulationInfected
From PortfolioProject.dbo.CovidDeaths
Group By location,population
Order By PercentagePopulationInfected desc

-- Showing countries with the highest death count per population 

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
where continent is not Null
Group By location
Order By TotalDeathCount desc

-- LETS break things down by continent

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
where continent is Null
Group By location
Order By TotalDeathCount desc

-- Showing contienets with highest death counts

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
where continent is not Null
Group By continent
Order By TotalDeathCount desc

--Global numbers new cases and new deaths

Select date, Sum(new_cases) as total_cases,Sum(cast( new_deaths as int)) as total_deaths,
(Sum(cast( new_deaths as int)) /Sum(new_cases) )*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not Null
Group By date
Order By 1,2

-- global total cases and total deaths
Select  Sum(new_cases) as total_cases,Sum(cast( new_deaths as int)) as total_deaths,
(Sum(cast( new_deaths as int)) /Sum(new_cases) )*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not Null
--Group By date
Order By 1,2


-- Looking Total population vs Vaccinations
Select *
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date


Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
Sum(CONVERT(int,vac.new_vaccinations)) over (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)* 100
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
Order By 2,3


-- USE CTE

With PopvsVac(continent, Location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
Sum(CONVERT(int,vac.new_vaccinations)) over (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)* 100
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
-- Order By 2,3 //Order by wont work in cte
)
Select *, (RollingPeopleVaccinated/population)* 100
From PopvsVac


-- Temp Table
Drop Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
Sum(CONVERT(int,vac.new_vaccinations)) over (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)* 100
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
-- Where dea.continent is not Null
-- Order By 2,3 //Order by wont work in cte

Select *, (RollingPeopleVaccinated/population)* 100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
Sum(CONVERT(int,vac.new_vaccinations)) over (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)* 100
From PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not Null
-- Order By 2,3 it wont work in views also

Select *
From PercentPopulationVaccinated

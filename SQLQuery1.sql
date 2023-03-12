select date, location, population,total_cases from Officedatabase..CovidDeaths order by 1


select date, location,population,total_cases,total_deaths from Officedatabase..CovidDeaths order by 2

-- CHECKING PERCENTAGE OF INFECTION AS TO THE TOTAL POPULATION
-- group by location, population, total_cases

select date, location,population,total_cases, (total_cases / population) * 100 as Infection_Perc from Officedatabase..CovidDeaths 
where location like '%nigeri%' order by 2

-- CHECKING PERCENTAGE OF death AS TO THE TOTAL INFECTION

select date, location,population,total_cases, total_deaths, (total_deaths/total_cases) * 100 as Death_Perc from Officedatabase..CovidDeaths 
where location like '%nigeri%' order by 2

-- to get the total for a particular location of continent you make use of an aggregate function like MAX accompanied

select continent, location,population, max(total_cases) as Max_Infection, max(total_deaths) Max_deaths, Max((total_deaths/total_cases)) * 100 as Max_Death_Perc from Officedatabase..CovidDeaths 
where population is not null continent is not null
group by location, population, continent
order by 3 desc 


--the below gives you a view of the countries who had covid infection and death

select continent,location,population, max(total_cases) as Max_Infection, max(total_deaths) Max_deaths, Max((total_deaths/total_cases)) * 100 as Max_Death_Perc from Officedatabase..CovidDeaths 
where continent is not null
group by location,population, continent
order by 4 desc


-- for continent maximum covid infection and death

select continent, max(total_cases) as Max_Infection, max(total_deaths) Max_deaths, Max((total_deaths/total_cases)) * 100 as Max_Death_Perc from Officedatabase..CovidDeaths 
where continent is not null
group by continent
order by 1 

SELECT CONTINENT FROM Officedatabase..CovidDeaths


 -- for datewise distribution maximum covid infection and death per day

 select date , max(total_cases) as Max_Infection, max(total_deaths) Max_deaths, Max((total_deaths/total_cases)) * 100 as Max_Death_Perc from Officedatabase..CovidDeaths 
--where continent is not null
group by date
order by 1 

 -- for datewise distribution maximum covid infection as to death that occured per day less accurate answer

 select date , sum(total_cases) as Total_Infection, sum(cast(total_deaths as int)) as Total_Mortality, sum((total_deaths/total_cases)) * 100 as Max_Death_Perc from Officedatabase..CovidDeaths 
--where continent is not null
group by date
order by 1 

-- alternative for date wise and note the total date is nvarchar  datatype accurate answer

 select date , sum(total_cases) as Total_Infection, sum(cast(total_deaths as int)) as Total_Mortality, (sum(cast(total_deaths as int)) / sum(total_cases)) * 100 as Death_Per_cases from Officedatabase..CovidDeaths 
--where continent is not null
group by date
order by 1 

--trying to join to of the tables in order database

select * from Officedatabase..CovidDeaths dea join Officedatabase..CovidVaccination vac on dea.location=vac.location and dea.date=vac.date

--trying to get accustomed to join

select dea.continent, vac.location, dea.date,dea.new_cases, vac.new_tests from Officedatabase..CovidDeaths dea join Officedatabase..CovidVaccination vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and vac.location like 'nigeri%'
order by 2,3

--trying to get the new case as they go cummulatively by loaction and date 

select dea.continent, vac.location, dea.date,dea.new_cases,vac.people_vaccinated,sum(cast(dea.new_cases as int)) over
(partition by dea.location order by  dea.location,vac.date)  as Cummulative_cases
from Officedatabase..CovidDeaths dea join Officedatabase..CovidVaccination vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and dea.new_cases is not null and vac.location like 'nigeri%'
order by 2,3

--with the above partition by used to get a new column and you are trying to make use of the column within the same query.
--this can only be possible with as CTE or temp table


with deavac ( continent, location, date, new_cases, people_vaccinated, population, cummulative_cases

)

as

(
select dea.continent, vac.location, dea.date,dea.new_cases,vac.people_vaccinated,population, sum(cast(dea.new_cases as int)) over
(partition by dea.location order by  dea.location,vac.date)  as Cummulative_cases
-- (Cummulative_cases/population) * 100 as Percetage_vac  
from Officedatabase..CovidDeaths dea join Officedatabase..CovidVaccination vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and dea.new_cases is not null and vac.location like 'nigeri%'
--order by 2,3
)
--cte common table expression
select *,  (Cummulative_cases/population) * 100 from deavac
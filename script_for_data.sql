select * 
from COVID_DATA t
where t.continent is not null
order by 3, 4;

-- select data we are going to use
select t.location, t.date_cur, t.total_cases, t.new_cases, t.total_deaths, t.population
from COVID_DATA t
where t.continent is not null
order by 1, 2;

-- total_cases VS total_deaths
-- likelihood of death if you got infected in Russia
select t.location, t.date_cur, t.total_cases, t.total_deaths, (t.total_deaths/t.total_cases) * 100 death_percentage
from COVID_DATA t
where t.location = 'Russia'
order by 1, 2;

-- total_cases VS population
-- what percentage of population got COVID in Russia
select t.location, t.date_cur, t.total_cases, t.population, (t.total_cases/t.population) * 100 infected_percentage
from COVID_DATA t
where t.location = 'Russia'
order by 1, 2;

-- contries with highest infection rate compared to population
select t.location, t.population, max(t.total_cases) current_infection_count, max((t.total_cases/t.population)) * 100 infected_percentage
from COVID_DATA t
where t.continent is not null
group by t.location, t.population
order by infected_percentage desc nulls last;

-- contries with highest death rate
select t.location, max(t.total_deaths) current_death_count
from COVID_DATA t
where t.continent is not null
group by t.location
order by current_death_count desc nulls last;

-- parts of the world with highest death rate
select t.location, max(t.total_deaths) current_death_count
from COVID_DATA t
where t.continent is null
and t.location not like '%income'
group by t.location
order by current_death_count desc nulls last;

-- continents with highest death rate
select t.continent, max(t.total_deaths) current_death_count
from COVID_DATA t
where t.continent is not null
group by t.continent
order by current_death_count desc nulls last;

-- contries with highest death rate compared to population
select t.location, t.population, max(t.total_deaths) current_death_count, max((t.total_deaths/t.population)) * 100 death_percentage
from COVID_DATA t
where t.continent is not null
group by t.location, t.population
order by death_percentage desc nulls last;


-- GLOBAL NUMBERS
select t.date_cur, sum(t.new_cases) daily_cases, sum(t.new_deaths) daily_deaths, (sum(t.new_deaths)/sum(t.new_cases)) * 100 death_percentage
from COVID_DATA t
where t.continent is not null
group by t.date_cur
order by 1, 2;


-------------------------------------
-------------------------------------

-- total population VS vaccinations
select t.continent, t.location, t.date_cur, t.population, t.new_vaccinations, 
       sum(t.new_vaccinations) over (partition by t.location order by t.location, t.date_cur) rolling_peaple_vaccinated
from COVID_DATA t
where t.continent is not null
order by 2, 3;

-- with CTE
with pop_vs_vac as 
    (select t.continent, t.location, t.date_cur, t.population, t.new_vaccinations, 
           sum(t.new_vaccinations) over (partition by t.location order by t.location, t.date_cur) rolling_peaple_vaccinated
    from COVID_DATA t
    where t.continent is not null
    order by 2, 3)
select pv.*, (pv.rolling_peaple_vaccinated/pv.population) * 100 percentage_of_vaccinated
from pop_vs_vac pv;



-- TEMP TABLE
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE percent_population_vaccinated';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;

CREATE TABLE percent_population_vaccinated
(
continent varchar2(150),
location varchar2(150), 
date_cur date, 
population number, 
new_vaccinations number,
rolling_peaple_vaccinated number
);

insert into percent_population_vaccinated
select t.continent, t.location, t.date_cur, t.population, t.new_vaccinations, 
           sum(t.new_vaccinations) over (partition by t.location order by t.location, t.date_cur) rolling_peaple_vaccinated
    from COVID_DATA t
    where t.continent is not null;
    
select ppv.*, (ppv.rolling_peaple_vaccinated/ppv.population) * 100 percentage_of_vaccinated
from percent_population_vaccinated ppv;


-- VIEW
create or replace view v_percent_population_vaccinated as
select t.continent, t.location, t.date_cur, t.population, t.new_vaccinations, 
           sum(t.new_vaccinations) over (partition by t.location order by t.location, t.date_cur) rolling_peaple_vaccinated
    from COVID_DATA t
    where t.continent is not null;
    
select *
from v_percent_population_vaccinated;

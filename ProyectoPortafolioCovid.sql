/*
Covid 19 Explotación de DATA.
Habilidades Usadas: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From ProyectoPortafolio..CovidMuertes
Where continent is not null 
order by 3,4


-- Selecciono la data que usaremos para comenzar / Select Data that we are going to be starting with 

Select Location as Locación, date as Fecha, total_cases as Casos_Totales, 
new_cases as Nuevos_Casos, total_deaths as Muertes_Totales, population as Población
From ProyectoPortafolio..CovidMuertes
Where continent is not null 
order by 1,2


-- Casos Totales vs Muertes Totales / Total Cases vs Total Deaths
-- Muestra la probabilidad de morir si contrae covid en su país / Shows likelihood of dying if you contract covid in your country

Select Location as Locación, date as Fecha, total_cases as Casos_Totales,total_deaths as Muertes_Totales,
(total_deaths/total_cases)*100 as Porcentaje_Muertes
From ProyectoPortafolio..CovidMuertes
Where location like '%zuel%' or location like 'Chile'
and continent is not null 
order by 1,2


-- Casos Totales vs Población / Total Cases vs Population
-- Muestra qué porcentaje de población infectada con Covid / Shows what percentage of population infected with Covid

Select Location as Locación, date as Fecha, Population as Población, total_cases as Casos_Totales,
(total_cases/population)*100 as Porcentaje_Población_Infectada
From ProyectoPortafolio..CovidMuertes
--Where location like '%zuela%' or location like 'Chile'
order by 1,2


-- Paises con el mayor rango de infección comparado con la población / Countries with Highest Infection Rate compared to Population

Select Location as Locación, Population as Población, MAX(total_cases) as Cuenta_Cantidad_Mas_Alta,
Max((total_cases/population))*100 as Porcentaje_Población_Infectada
From ProyectoPortafolio..CovidMuertes
--Where location like '%zuela%' or location like 'Chile'
Group by Location, Population
order by Porcentaje_Población_Infectada desc


-- Paises con la cuenta de muertes más alta por población / Countries with Highest Death Count per Population

Select Location as Locación, MAX(cast(Total_deaths as int)) as Cantidad_Muertes_Totales
From ProyectoPortafolio..CovidMuertes
--Where location like '%zuela%' or location like 'Chile'
Where continent is not null 
Group by Location
order by Cantidad_Muertes_Totales desc



-- Desglose de la información por continente / BREAKING THINGS DOWN BY CONTINENT

/* Mostrando contingentes con el mayor recuento de muertes por población /
Showing contintents with the highest death count per population*/

Select continent as Continente, MAX(cast(Total_deaths as int)) as Cantidad_Muertes_Totales
From ProyectoPortafolio..CovidMuertes
--Where location like '%zuela%' or location like 'Chile'
Where continent is not null 
Group by continent
order by Cantidad_Muertes_Totales desc



-- Números Globales / GLOBAL NUMBERS --

Select SUM(new_cases) as Casos_Totales, SUM(cast(new_deaths as int)) as Muertes_Totales,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Porcentaje_Muertes
From ProyectoPortafolio..CovidMuertes
--Where location like '%zuela%' or location like 'Chile'
where continent is not null 
--Group By date
order by 1,2



-- Poblacion Total vs Vacunas / Total Population vs Vaccinations --
/* Muestra el porcentaje de población que ha recibido al menos una vacuna Covid / 
Shows Percentage of Population that has recieved at least one Covid Vaccine*/

Select CM.continent as Continente, CM.location as Locación, CONVERT(date,CM.date) as Fecha, CM.population as Población,
REPLACE(CV.new_vaccinations,',','') as Nuevas_Vacunas
, SUM(CAST(REPLACE(CV.new_vaccinations,',','') as int)) OVER (Partition by CM.Location Order by CM.location, CAST(CM.Date as date)) as Personas_Vacunadas
From ProyectoPortafolio..CovidMuertes CM
Join ProyectoPortafolio..CovidVacunación CV
	On CM.location = CV.location
	and CM.date = CV.date
where CM.continent is not null 
order by CM.population



/* Uso de CTE para realizar cálculos en la partición por en la consulta anterior /
Using CTE to perform Calculation on Partition By in previous query*/

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Personas_Vacunadas)
as
(
Select CM.continent as Continente, CM.location as Locación, CONVERT(date,CM.date) as Fecha, CM.population as Población,
REPLACE(CV.new_vaccinations,',','') as Nuevas_Vacunas
, SUM(CAST(REPLACE(CV.new_vaccinations,',','') as int)) OVER (Partition by CM.Location Order by CM.location, CAST(CM.Date as date)) as Personas_Vacunadas
From ProyectoPortafolio..CovidMuertes CM
Join ProyectoPortafolio..CovidVacunación CV
	On CM.location = CV.location
	and CM.date = CV.date
where CM.continent is not null 
)

Select *, (Personas_Vacunadas/Population)*100 as Porcentaje_Personas_Vacunadas
From PopvsVac



/*Uso de la tabla temporal para realizar cálculos en la partición por en la consulta anterior / 
Using Temp Table to perform Calculation on Partition By in previous query*/

DROP Table if exists #Porcentaje_Vacunas_Población
Create Table #Porcentaje_Vacunas_Población
(
Continente nvarchar(255),
Locación nvarchar(255),
Fecha datetime,
Población numeric,
Nuevas_Vacunas numeric,
Personas_Vacunadas numeric
)

Insert into #Porcentaje_Vacunas_Población
Select CM.continent, CM.location, CONVERT(date,CM.date), CM.population,
CAST(REPLACE(CV.new_vaccinations,',','') as bigint)
, SUM(CAST(REPLACE(CV.new_vaccinations,',','') as bigint)) OVER (Partition by CM.Location Order by CM.location, CAST(CM.Date as date)) as Personas_Vacunadas
From ProyectoPortafolio..CovidMuertes CM
Join ProyectoPortafolio..CovidVacunación CV
	On CM.location = CV.location
	and CM.date = CV.date


Select *, (Personas_Vacunadas/Población)*100 as porcentaje_Vacunados
From #Porcentaje_Vacunas_Población




-- Crear vista para almacenar datos para visualizaciones posteriores / Creating View to store data for later visualizations--

Create View Porcentaje_Vacunados as
Select CM.continent as Continente, CM.location as Locación, CONVERT(date,CM.date) as Fecha, CM.population as Población,
REPLACE(CV.new_vaccinations,',','') as Nuevas_Vacunas
, SUM(CAST(REPLACE(CV.new_vaccinations,',','') as int)) OVER (Partition by CM.Location Order by CM.location, CAST(CM.Date as date)) as Personas_Vacunadas
From ProyectoPortafolio..CovidMuertes CM
Join ProyectoPortafolio..CovidVacunación CV
	On CM.location = CV.location
	and CM.date = CV.date
where CM.continent is not null 

select * from Porcentaje_Vacunados


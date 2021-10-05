

--Consultas para Tableau / Query for tableau--

-- 1 --
SELECT SUM(new_cases) as CasosTotales, 
SUM(CAST(new_deaths as int)) as MuertesTotales,
SUM(new_cases)/SUM(CAST(new_deaths as int))*100 as PorcentajeMuertes
FROM ProyectoPortafolio..CovidMuertes
ORDER BY 1,2


-- 2 --

SELECT location AS Locaci�n,
SUM(CAST(new_deaths as int)) AS  CantidadTotalMuerte
FROM ProyectoPortafolio..CovidMuertes
WHERE continent is null
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY CantidadTotalMuerte DESC

-- 3 --

SELECT location AS Locaci�n,
population AS Poblaci�n,
MAX(Total_cases) AS CantidadM�ximaInfecci�n,
MAX(total_cases)/population*100 AS PorcentajePoblaci�nInfectada
FROM ProyectoPortafolio..CovidMuertes
GROUP BY location, population
ORDER BY PorcentajePoblaci�nInfectada DESC

-- 4 -- 

SELECT location as Locaci�n,
population as Poblaci�n,
date as Fecha,
MAX(total_cases) as CantidadM�ximaInfecci�n,
MAX((total_cases/population))*100 as PorcentajePoblaci�nInfectada
FROM ProyectoPortafolio..CovidMuertes
GROUP BY location,population,date
ORDER BY PorcentajePoblaci�nInfectada DESC
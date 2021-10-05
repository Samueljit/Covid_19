

--Consultas para Tableau / Query for tableau--

-- 1 --
SELECT SUM(new_cases) as CasosTotales, 
SUM(CAST(new_deaths as int)) as MuertesTotales,
SUM(new_cases)/SUM(CAST(new_deaths as int))*100 as PorcentajeMuertes
FROM ProyectoPortafolio..CovidMuertes
ORDER BY 1,2


-- 2 --

SELECT location AS Locación,
SUM(CAST(new_deaths as int)) AS  CantidadTotalMuerte
FROM ProyectoPortafolio..CovidMuertes
WHERE continent is null
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY CantidadTotalMuerte DESC

-- 3 --

SELECT location AS Locación,
population AS Población,
MAX(Total_cases) AS CantidadMáximaInfección,
MAX(total_cases)/population*100 AS PorcentajePoblaciónInfectada
FROM ProyectoPortafolio..CovidMuertes
GROUP BY location, population
ORDER BY PorcentajePoblaciónInfectada DESC

-- 4 -- 

SELECT location as Locación,
population as Población,
date as Fecha,
MAX(total_cases) as CantidadMáximaInfección,
MAX((total_cases/population))*100 as PorcentajePoblaciónInfectada
FROM ProyectoPortafolio..CovidMuertes
GROUP BY location,population,date
ORDER BY PorcentajePoblaciónInfectada DESC
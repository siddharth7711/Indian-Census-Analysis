SELECT * FROM project.dbo.data2

SELECT * FROM project.dbo.data1

-- total Numbers of rows in our dataset

SELECT COUNT(*) FROM project.dbo.data1

SELECT COUNT(*) FROM project.dbo.data2

-- dataset for Jharkhand and Bihar from data1

SELECT * FROM project.dbo.data1
WHERE state IN ('Jharkhand', 'Bihar')

-- total population of India

SELECT SUM(population) AS Total_Population
FROM project.dbo.data2

-- average growth of India in percentage

SELECT AVG(Growth)*100 AS Average_Growth_India
FROM project.dbo.data1

-- average growth percentage for each State

SELECT state,AVG(Growth)*100 AS average_growth
FROM project.dbo.data1
GROUP BY State

-- average sex ratio

SELECT AVG(Sex_Ratio) AS Average_Sex_Ratio_India
FROM project.dbo.data1

-- average sex ratio of each sate

SELECT state, AVG(Sex_Ratio) AS Average_Sex_Ratio
FROM project.dbo.data1
GROUP BY state

-- average sex ratio of each sate upto 2 Decimal places

SELECT state, ROUND(AVG(Sex_Ratio), 2) AS Average_Sex_Ratio
FROM project.dbo.data1
GROUP BY state

-- average literacy rate of each state upto 0 Decimal places

SELECT state, ROUND(AVG(Literacy), 0) AS Average_Literacy_Rate
FROM project.dbo.data1
GROUP BY state

-- states having average literacy rate greater than 90

SELECT state, ROUND(AVG(Literacy), 0) AS Average_Literacy_Rate
FROM project.dbo.data1
GROUP BY state
HAVING ROUND(AVG(Literacy), 0) > 90
ORDER BY Average_Literacy_Rate DESC

-- top 3 states having the highest growth ratio

SELECT TOP 3 state, AVG(Growth) AS average_growth
FROM project.dbo.data1
GROUP BY State
ORDER BY average_growth DESC

-- bottom 3 states having the lowest sex ratio

SELECT TOP 3 state, ROUND(AVG(Sex_Ratio), 2) AS Average_Sex_Ratio
FROM project.dbo.data1
GROUP BY state
ORDER BY Average_Sex_Ratio

-- states starting with letter 'a'

SELECT State FROM project.dbo.data1
WHERE LOWER(State) LIKE 'a%'
GROUP BY state

-- states starting with letter 'a' (altenative)

SELECT DISTINCT State FROM project.dbo.data1
WHERE LOWER(State) LIKE 'a%'

-- states starting with letter 'a' or 'b'

SELECT DISTINCT State FROM project.dbo.data1
WHERE LOWER(state) LIKE 'a%' or LOWER(state) LIKE 'b%'

-- states starting with letter 'a' and ending with letter 'h'

SELECT DISTINCT state FROM project.dbo.data1
WHERE LOWER(state) LIKE 'a%' and LOWER(state) LIKE '%h'




-- total numbers of males and females in each state

SELECT d1.district, d1.state, d1.sex_ratio/1000 AS sex_Ratio, d2.population
FROM project.dbo.data1 AS d1
INNER JOIN project.dbo.data2 AS d2
ON d1.District = d2.District

-- formula used is
-- males = population/(sex_ratio+1)
-- females = population-(population/(sex_ratio+1))
--         = population*(sex_ratio)/(sex_ratio+1)




SELECT d.state, SUM(d.males) AS total_males, SUM(d.females) AS total_female
FROM
(SELECT c.district, c.state, ROUND(c.population/(c.sex_ratio+1), 0) AS males, 
ROUND((c.population*c.sex_ratio)/(c.sex_ratio+1), 0) AS females
FROM
(SELECT d1.district, d1.state, d1.sex_ratio/1000 AS sex_Ratio, d2.population
FROM project.dbo.data1 AS d1
INNER JOIN project.dbo.data2 AS d2
ON d1.District = d2.District) AS c) AS d
GROUP BY d.state


-- number of literate and illiterate people in each state

SELECT d1.district, d1.state, d1.literacy, d2.population
FROM project.dbo.data1 AS d1
INNER JOIN project.dbo.data2 AS d2
ON d1.District = d2.District

-- formula used is
--literate people = (literacy/100)*population
-- illiterate people = population - literate people


SELECT m.state, SUM(m.literate_people) AS total_literate_people,
SUM(m.illiterate_people) AS total_illiterate_people
FROM
(SELECT l.district, l.state, ROUND(((l.literacy/100)*l.population), 0) AS
literate_people, ROUND((l.population - (l.literacy/100)*l.population), 0)
AS illiterate_people
FROM
(SELECT d1.district, d1.state, d1.literacy, d2.population
FROM project.dbo.data1 AS d1
INNER JOIN project.dbo.data2 AS d2
ON d1.District = d2.District) AS l) AS m
GROUP BY m.state


-- population in previous census and current census in each state

SELECT d1.district, d1.state, d1.Growth, d2.population
FROM project.dbo.data1 AS d1
INNER JOIN project.dbo.data2 AS d2
ON d1.District = d2.District

--formula uses is
--previous_population + ((growth/100)*previous_population) = population
-- previous population = population/(1+(growth/100))

SELECT d.district, d.state, d.population, ROUND(d.population / (1+(d.Growth/100)),0) AS previous_population
FROM
(SELECT d1.district, d1.state, d1.Growth, d2.population
FROM project.dbo.data1 AS d1
INNER JOIN project.dbo.data2 AS d2
ON d1.District = d2.District) AS d

SELECT e.state, SUM(e.previous_population) AS total_previous_population,
SUM(e.population) AS total_current_population
FROM
(SELECT d.district, d.state, d.population, ROUND(d.population / (1+(d.Growth/100)),0) AS previous_population
FROM
(SELECT d1.district, d1.state, d1.Growth, d2.population
FROM project.dbo.data1 AS d1
INNER JOIN project.dbo.data2 AS d2
ON d1.District = d2.District) AS d) AS e
GROUP BY e.state


-- total previous population and total current population

SELECT SUM(m.total_previous_population) AS previous_population, SUM(m.total_current_population)
AS current_population
FROM
(SELECT e.state, SUM(e.previous_population) AS total_previous_population,
SUM(e.population) AS total_current_population
FROM
(SELECT d.district, d.state, d.population, ROUND(d.population / (1+(d.Growth/100)),0) AS previous_population
FROM
(SELECT d1.district, d1.state, d1.Growth, d2.population
FROM project.dbo.data1 AS d1
INNER JOIN project.dbo.data2 AS d2
ON d1.District = d2.District) AS d) AS e
GROUP BY e.state) AS m

-- top 3 districts from each sate with highest literacy rate

SELECT district, state, literacy, rank() OVER(PARTITION BY state ORDER BY literacy DESC) AS rnk
FROM project.dbo.data1

SELECT a.*
FROM
(SELECT district, state, literacy, rank() OVER(PARTITION BY state ORDER BY literacy DESC) AS rnk
FROM project.dbo.data1) AS a
WHERE a.rnk in (1,2,3)
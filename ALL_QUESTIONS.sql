USE WHITEROCK_STREETLIGHT;

SELECT * FROM POLE

-- 1) I would like to know how many signal lights exist within a 5m radius of elementary school x.
SELECT DISTINCT POLE_ID FROM POLE WHERE POLE_NEAR_SCHOOL = 1;

-- 2) I would like to know how many street lights have traffic signals on them.
SELECT DISTINCT POLE_ID, POLE_LAT, POLE_LONG FROM POLE WHERE POLE_IS_TRAFFIC = 1;

-- 3) I would like to know which streetlights haven’t had any maintenance updates in the last 3 years. 
SELECT DISTINCT POLE.POLE_ID, MAINT_RECORD.MAINT_RECORD_DATE, POLE.POLE_HGT, POLE.POLE_LAT, POLE.POLE_LONG
FROM POLE
JOIN MAINT_RECORD
ON MAINT_RECORD.POLE_ID = POLE.POLE_ID
WHERE MAINT_RECORD.MAINT_TYPE = 'S' AND MAINT_RECORD.MAINT_RECORD_DATE < '2018-01-01 00:00:00'

-- 4) I would like to find out which technician creates the maintenance report for the streetlight on street X at the coordinates (lambda, phi).
SELECT MAINT_RECORD.EMPLOYEE_ID, EMPLOYEE.EMPLOYEE_FNAME, EMPLOYEE.EMPLOYEE_LNAME, POLE_LAT, POLE_LONG
FROM MAINT_RECORD
JOIN EMPLOYEE
ON MAINT_RECORD.EMPLOYEE_ID = EMPLOYEE.EMPLOYEE_ID
JOIN POLE
ON POLE.POLE_ID = MAINT_RECORD.POLE_ID
WHERE (POLE_LAT = 49.02922429) AND (POLE_LONG = -122.8010562);


-- 5) I would like to get a count on the total of the inspected streetlights for the year of 2019.
SELECT COUNT(MAINT_RECORD.MAINT_RECORD_DATE) AS [MAINTENANCE COUNT]
FROM MAINT_RECORD
WHERE	MAINT_RECORD.MAINT_RECORD_DATE >= '2019-01-01 00:00:00' 
		AND MAINT_RECORD.MAINT_RECORD_DATE <=  '2019-12-31 11:59:59'
-- 6) How many poles do we have in total?
SELECT COUNT(DISTINCT POLE_ID) AS "Total Poles"
FROM POLE;
-- 7) How many of each type/combination?
-- We can count each type and combination separately
SELECT COUNT(DISTINCT POLE_ID) AS "Number of Poles", POLE_IS_LIGHT, POLE_IS_TRAFFIC
FROM POLE
GROUP BY POLE_IS_LIGHT, POLE_IS_TRAFFIC;

-- 8) Have all poles been checked and maintained in the last year?
-- Assuming last year is 2020, we can compare the total amount of poles to the amount of poles maintained in 2020
SELECT POLE.POLE_ID, MAINT_RECORD_DATE
FROM POLE
JOIN (SELECT POLE_ID, MAINT_RECORD_DATE
FROM MAINT_RECORD
WHERE MAINT_RECORD_DATE < '2021-01-01 00:00:00' AND MAINT_RECORD_DATE > '2020-01-01 00:00:00') AS LAST_YEAR
ON LAST_YEAR.POLE_ID = POLE.POLE_ID;

-- 9) As the field tech, what is the location of the poles I will be checking?
-- Assume the field tech was assigned poles to check by pole ID (In this case, 1-5)
SELECT POLE_ID, POLE_LAT, POLE_LONG
FROM POLE
WHERE POLE_ID > 0 AND POLE_ID < 6
ORDER BY POLE_ID;

-- 10) How many techs do we have working to maintain all the poles in the city?
-- Make a Query for searches for individual Field Tech IDs
SELECT COUNT(DISTINCT EMPLOYEE_ID) AS "Active Tech Count"
FROM MAINT_RECORD;

-- 11) I am working with the Traffic department of the city. Can your database display the projects that will start the soonest?
--This is beyond the scope of this database, this database will only tell users details about different traffic and light poles within the city of white rock. It does not log information about construction projects occurring in the vicinity.
--The database does not support planned projects. The closest that you can do is to search by conditions of various properties to find ones in poor condition.

-- 12) I am an engineer. Can your database show parts and when they were installed?
-- Parts can be seen as attributes of the pole table. The installation date cannot be seen, but the condition of some parts can be seen and the year the pole installed can be

-- 13) I am a project manager - can your database show the cost of all the parts?
-- Price information cannot be obtained from this database, but another database with inventory information could join this database on the the part IDs

-- 14) I am in Roadworks and we are planning to create a new street. Can your database show us which traffic lights have been the most reliable?
-- If a pole has appeared in many maintenance reports without appearing in many maintenance update, then it is reliable
SELECT MAINT_RECORD.MAINT_ID, MAINT_RECORD_DATE, POLE_ID, MAINT_HAMMER_TEST_RESULT, MAINT_VISUAL_RUST, MAINT_LUMINAIRE_COND, MAINT_PANEL_COND, MAINT_ANCHOR_BOLTS_COND FROM MAINT_RECORD, MAINT_CONDITION 
WHERE MAINT_VISUAL_RUST = 'N' AND MAINT_LUMINAIRE_COND > 2 AND MAINT_ANCHOR_BOLTS_COND = 'GOOD' AND MAINT_PANEL_COND > 2 ORDER BY MAINT_RECORD_DATE DESC;

-- 15) As a manager, how often are poles repainted, is there an area where poles are repainted more often?
SELECT POLE_ID, MAINT_RECORD.MAINT_ID, MAINT_REPAINT_DATE FROM MAINT_RECORD, MAINT_SERVICE WHERE MAINT_RECORD.MAINT_ID = MAINT_SERVICE.MAINT_ID ORDER BY  MAINT_REPAINT_DATE DESC;

-- Yes, search by repaint date under maintenance record. If you sort by “repainted most recently” you can take the coordinates to find a geographical trend.
SELECT DISTINCT POLE.POLE_ID, POLE.POLE_LAT, POLE.POLE_LONG, MAINT_SERVICE.MAINT_REPAINT_DATE FROM POLE
JOIN MAINT_RECORD ON POLE.POLE_ID = MAINT_RECORD.POLE_ID
JOIN MAINT_SERVICE ON MAINT_RECORD.MAINT_ID = MAINT_SERVICE.MAINT_ID
ORDER BY MAINT_REPAINT_DATE DESC, POLE_LAT DESC, POLE_LONG DESC;

-- 16) As a manager, how often does each type of employee access the maintenance records?
-- This is not a database question, this relates to user account management (?)

-- 17) As a planner, how often does the city upgrade bulb types for streetlight poles?
-- Search by Pole IDt and then search by Relamp date.
SELECT POLE.POLE_ID, MAINT_SERVICE.MAINT_RELAMP_DATE FROM POLE
JOIN MAINT_RECORD ON POLE.POLE_ID = MAINT_RECORD.POLE_ID
JOIN MAINT_SERVICE ON MAINT_RECORD.MAINT_ID = MAINT_SERVICE.MAINT_ID
ORDER BY MAINT_RELAMP_DATE DESC;

-- 18) As a manager, how frequently are poles in x area relamped.
SELECT POLE.POLE_ID, POLE_LAT, POLE_LONG, MAINT_SERVICE.MAINT_RELAMP_DATE FROM POLE
JOIN MAINT_RECORD ON POLE.POLE_ID = MAINT_RECORD.POLE_ID
JOIN MAINT_SERVICE ON MAINT_RECORD.MAINT_ID = MAINT_SERVICE.MAINT_ID
ORDER BY POLE_LAT, POLE_LONG;

-- 19) As a field tech, I want to search for a list of poles that need to be maintained to find the fastest route between them.
-- The database doesn’t have an entity or attribute that directly tells us which pole needs maintenance most urgently (example high hammer test, visual rust, panel condition etc). But it does have the ability to give us the geographic location of the pole so if we manually selected the poles we wanted change, we could map them all and find the best route with geographical software.
SELECT POLE.POLE_ID, POLE_LAT, POLE_LONG FROM POLE
ORDER BY POLE_LAT, POLE_LONG;

-- 20) How many streetlights are replaced on average?
-- We can search the number of unique Pole IDs on each maintenance report. The farther back we go, the more accurate the average is. To compare one year’s from the last, for instance:

SELECT COUNT(DISTINCT POLE_ID) AS "NUMBER OF POLES UPDATED" FROM MAINT_RECORD
JOIN MAINT_SERVICE ON MAINT_RECORD.MAINT_ID = MAINT_SERVICE.MAINT_ID;
	

-- 21) Is there a correlation between streetlights that often have to be maintained and their location?
-- We can find out how often a pole occurs on a maintenance report and compare it to its location to find a geographic correlation.
SELECT POLE.POLE_ID, COUNT(POLE.POLE_ID) AS "NUMBER_OF_TIMES_MAINTENANCED", POLE_LAT, POLE_LONG FROM POLE
JOIN MAINT_RECORD ON POLE.POLE_ID = MAINT_RECORD.POLE_ID
JOIN MAINT_SERVICE ON MAINT_RECORD.MAINT_ID = MAINT_SERVICE.MAINT_ID
GROUP BY POLE.POLE_ID, POLE_LAT, POLE_LONG

-- 22) Adding onto the above what is the correlation between using certain materials for poles or certain types of lightbulbs and how often do they need to be replaced?
-- This information is out of the scope of this database

-- 23) How are we choosing which field techs maintain which poles?
-- This is beyond the scope of this database. Maybe if we had another table with field tech information and joined it on field tech ID, we could determine trends (experience, area of operation, salary etc)

-- 24) What are the newest and oldest poles? When were they each last maintained
SELECT POLE.POLE_ID, POLE_ESTIMATED_AGE, MAINT_RECORD_DATE FROM POLE, MAINT_RECORD 
WHERE POLE.POLE_ID = MAINT_RECORD.POLE_ID AND POLE.POLE_ESTIMATED_AGE = (SELECT MAX(POLE.POLE_ESTIMATED_AGE) FROM POLE) OR POLE.POLE_ID = MAINT_RECORD.POLE_ID AND POLE.POLE_ESTIMATED_AGE = (SELECT min(POLE.POLE_ESTIMATED_AGE) FROM POLE) ORDER BY MAINT_RECORD_DATE DESC;



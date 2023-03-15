USE Space_Missions
GO
-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Djibril968>
-- Create date: <3/6/2023>
-- Description:	<Space_missiona Project>
-- =============================================
ALTER PROCEDURE Space_Misions_Proj

AS

----step 1
---selecting required tables
SELECT * FROM space_missions

---step 2
-----data cleaning
----date conversion

--SELECT Date
--from space_missions


--SELECT CONVERT(Date, Date) as Date_launched
--from space_missions

--ALTER TABLE space_missions
--ADD Date_launched DATE;

--Update space_missions
--SET Date_launched = CONVERT(Date, Date)

--ALTER TABLE space_missions
--ADD Month_Launched VARCHAR (10);

--UPDATE space_missions
--SET Month_Launched = MONTH(date)

--ALTER TABLE space_missions
--ADD Year_Launched VARCHAR (10);

--UPDATE space_missions
--SET Year_Launched = Year(date)

---the above code was commented out due to a wrong move made when deleting unrequired columns... if not commented out, could affect altering/updating the procedure

SELECT *FROM space_missions

ALTER TABLE space_missions
ADD  Amount_Spent INT

UPDATE space_missions
SET Amount_Spent = Price

---breaking location into columns
----We can either use parsename or substring function to split colums but for this purpose we are using parsename function
--- to use parsename we have to first replace the (,) with (.) since PN only works with (.) as delimiter 

SELECT
PARSENAME(REPLACE(location, ',','.'),4) as Launch_Add,
PARSENAME(REPLACE(location, ',','.'),3) as Launch_Loc,
PARSENAME(REPLACE(location, ',','.'),2) as Launch_State,
PARSENAME(REPLACE(location, ',','.'),1) as Country 
FROM space_missions


ALTER TABLE space_missions
ADD Launch_Add VARCHAR (100),
Launch_Loc VARCHAR (100),
Launch_State VARCHAR (100),
Country VARCHAR (50)

UPDATE space_missions
SET
Launch_Add = PARSENAME(REPLACE(location, ',','.'),4),
Launch_Loc = PARSENAME(REPLACE(location, ',','.'),3),
Launch_State = PARSENAME(REPLACE(location, ',','.'),2),
Country = PARSENAME(REPLACE(location, ',','.'),1)

SELECT Location, Launch_Add, Launch_Loc,(Launch_Add + Launch_Loc) as Launch_Address 
FROM space_missions

ALTER TABLE space_missions
ADD Launch_Address VARCHAR (100)

UPDATE space_missions
SET Launch_Address = (Launch_Add + Launch_Loc)

---Here we use the select statements below to compare empty values for field of interest 

SELECT company, Location, Rocket Mission, RocketStatus, MissionStatus, Date_Launched, Launch_Add, Launch_Loc, Launch_Address, Launch_State, Country
FROM space_missions
WHERE Launch_Address IS NOT NULL

SELECT company, Location, Rocket Mission, RocketStatus, MissionStatus, Date_Launched,  Launch_Add, Launch_Loc, Launch_Address, Launch_State, Country
FROM space_missions
WHERE Launch_Address IS  NULL

----We could observe that some fields have null value after the break,this is due to the unequal number of delimiter present 
---here we will write a syntax to populate them
---skills to use :joins, ISNULL and UPDATE to populate them
---firstly we do a self join of the table to its self due to the perculiarity of this case where we are populating the the empty rows with
-------another column within the same table, after which ISNULL used populate empty rows in column a with that of column b 
----A unique ID is required since the table has no uniqe identifier to allow for the joining process
ALTER TABLE Space_missions
ADD UniqueID INT IDENTITY (1000,1) 

-----Using joins to populate empty rows for Launch_Addresss from Launch_Loc
SELECT a.Launch_Loc,  b.Launch_Address, ISNULL(b.Launch_Address, a.Launch_Loc) 
FROM space_missions a
JOIN space_missions b
	ON a.UniqueID = b.UniqueID
	WHERE a.Launch_address IS NULL

---Update	
UPDATE a
SET Launch_Address = ISNULL(b.Launch_Address, a.Launch_Loc)
FROM space_missions a
JOIN space_missions b
	ON a.UniqueID = b.UniqueID
	--AND a.UniqueID <> b.UniqueID
WHERE a.Launch_add IS NULL;




---Second join
SELECT a.Launch_State,  b.Launch_Address, ISNULL(b.Launch_Address, a.Launch_State) 
FROM space_missions a
JOIN space_missions b
	ON a.UniqueID = b.UniqueID
	WHERE a.Launch_address IS NULL

---Update	
UPDATE a
SET Launch_Address = ISNULL(b.Launch_Address, a.Launch_State)
FROM space_missions a
JOIN space_missions b
	ON a.UniqueID = b.UniqueID
	--AND a.UniqueID <> b.UniqueID
WHERE a.Launch_address IS NULL;


SELECT company, Location, Rocket Mission, RocketStatus, MissionStatus, Date_Launched, Launch_Address, Launch_State, Country
FROM space_missions
WHERE Launch_Address IS NULL



----Removing duplicates
---we first create a row_num field to rank the records, then use the over and partition by syntax
----after which we create a CTE to query and check for duplicates
WITH SpaceCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY Company, Location, Date_Launched, Rocket, Mission
	ORDER BY Date_Launched) row_num
FROM space_missions
)
SELECT * FROM space_missions
WHERE Launch_Add IS NULL AND Launch_State IS NOT NULL
ORDER BY Company


--WHERE Launch_address is NULL

----Removing unsed columns
--ALTER TABLE space_missions
--DROP COLUMN  Launch_Add

SELECT * FROM space_missions


END
GO

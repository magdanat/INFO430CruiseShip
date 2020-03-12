-- Rayna Tilley
-- Cruiseship Code

/*
SUMMARY:
Business Rules: IP
Stored Procedures: DONE
Computed Columns: DONE-ish
Views: IP
Synthetic Transactions: Not Started
*/
USE CRUISE

-- Business Rules
-- 1. Customers over 90 cannot book hiking excursions.
CREATE FUNCTION cruise_CustBookExcTrip_noHikesFor90()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
		IF EXISTS(SELECT *
			FROM tblCUST_BOOK_EXC_TRIP CBET
				JOIN tblCUST_BOOK CB ON CBET.CustBookingID = CB.CustBookingID
				JOIN tblBOOKING B ON CB.BookingID = B.BookingID
				JOIN tblBOOKING_STATUS BS ON B.BookStatusID = BS.BookStatusID
				JOIN tblEXCURSION_TRIP ET ON CBET.ExcursionTripID = ET.ExcursionTripID
				JOIN tblEXCURSION E ON ET.ExcursionID = E.ExcursionID
				JOIN tblEXCURSION_TYPE ETY ON E.ExcursionTypeID = ETY.ExcursionTypeID
				JOIN tblCUSTOMER C ON CB.CustID = C.CustID
			WHERE C.CustDOB < (ET.StartTime - 365.25 * 90)
				AND ETY.ExcursionTypeName = 'Hiking')
		BEGIN
			SET @Ret = 1
		END
	RETURN @Ret
END
GO
ALTER TABLE tblCUST_BOOK_EXC_TRIP
ADD CONSTRAINT NoHikesFor90
CHECK(dbo.cruise_CustBookExcTrip_noHikesFor90() = 0)
GO
-- 2. No more than the capacity for each cabin.
ALTER FUNCTION cruise_CustBookExcTrip_NoCanceled()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
		IF EXISTS(SELECT *
			FROM tblCUST_BOOK_EXC_TRIP CBET
				JOIN tblCUST_BOOK CB ON CBET.CustBookingID = CB.CustBookingID
				JOIN tblBOOKING B ON CB.BookingID = B.BookingID
				JOIN tblBOOKING_STATUS BS ON B.BookStatusID = BS.BookStatusID
				JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
				JOIN tblTRIP T ON TC.TripID = T.TripID
			WHERE BS.BookStatusName = 'Canceled'
				AND CBET.RegisTime < T.StartDate)
		BEGIN
			SET @Ret = 1
		END
	RETURN @Ret
END
GO
ALTER TABLE tblCUST_BOOK_EXC_TRIP
ADD CONSTRAINT CustBookExcTrip_NoCanceled
CHECK(dbo.cruise_CustBookExcTrip_NoCanceled() = 0)
GO

-- Stored Procedures
-- 1. Add new row in tblCUST_BOOK_EXC_TRIP
CREATE PROC cruise_NewRowCustBookExcTrip
@RegisTime datetime,
@ExcStart datetime,
@ExcEnd datetime,
@CustFname varchar(50),
@CustLname varchar(50),
@CustDOB date,
@BookingNumber char(7),
@ExcursionStartTime datetime,
@ExcursionEndTime datetime,
@ExcursionName varchar(50),
@ShipName varchar(50),
@TripStartDay date,
@TripEndDay date
AS
DECLARE @ExcursionTripID INT, @CustBookingID INT
EXEC cruise_GetCustBookingID
@Fname = @CustFname,
@Lname = @CustLname,
@DOB = @CustDOB,
@BookingNum = @BookingNumber,
@CB_ID = @CustBookingID OUTPUT
IF @CustBookingID IS NULL
BEGIN
	RAISERROR('@CustBookingID cannot be null.',11,1)
	RETURN
END
EXEC cruise_GetExcursionTripID
@STime = @ExcursionStartTime,
@ETime = @ExcursionEndTime,
@ExcName = @ExcursionName,
@SName = @ShipName,
@TripStart = @TripStartDay,
@TripEnd = @TripEndDay,
@ET_ID = @ExcursionTripID OUTPUT
IF @ExcursionTripID IS NULL
BEGIN
	RAISERROR('@ExcursionTripID cannot be null.',11,1)
	RETURN
END
BEGIN TRAN T1
SELECT * FROM tblCUST_BOOK_EXC_TRIP
INSERT INTO tblCUST_BOOK_EXC_TRIP(RegisTime, ExcursionTripID, CustBookingID)
VALUES(@RegisTime, @ExcursionTripID, @CustBookingID)
IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN T1
	END
ELSE
	COMMIT TRAN T1
GO
-- 2. Get CustBookingID
CREATE PROC cruise_GetCustBookingID
@Fname varchar(50),
@Lname varchar(50),
@DOB date,
@BookingNum char(7),
@CB_ID INT OUTPUT
AS
DECLARE @CustID INT, @BookingID INT
EXEC cruise_GetCustID
@F = @Fname,
@L = @Lname, 
@B = @DOB,
@C_ID = @CustID OUTPUT
EXEC cruise_GetBookingID
@BNum = @BookingNum,
@B_ID = @BookingID OUTPUT
SET @CB_ID = (SELECT CustBookingID FROM tblCUST_BOOK
	WHERE CustID = @CustID
		AND BookingID = @BookingID)
GO
-- 3. Get CustID
CREATE PROC cruise_GetCustID
@F varchar(50),
@L varchar(50),
@B date,
@C_ID INT OUTPUT
AS
SET @C_ID = (SELECT CustID FROM tblCUSTOMER 
	WHERE CustFName = @F AND CustLname = @L AND CustDOB = @B)
GO
-- 4. GetBookingID
CREATE PROC cruise_GetBookingID
@BNum char(7),
@B_ID INT OUTPUT
AS
SET @B_ID = (SELECT BookingID FROM tblBOOKING
	WHERE BookingNumber = @BNum)
GO
-- 5. Get ExcursionID
CREATE PROC cruise_GetExcursionID
@EName varchar(50),
@E_ID INT OUTPUT
AS
SET @E_ID = (SELECT ExcursionID FROM tblEXCURSION WHERE ExcursionName = @EName)
GO
-- 6. Get TripID -- Before we got rid of TripName...
CREATE PROC cruise_GetTripID
@ShipName varchar(50),
@Start date,
@End date,
@T_ID INT OUTPUT
AS
SET @T_ID = (SELECT TripID FROM tblTRIP
	WHERE CruiseshipID = (SELECT CruiseshipID FROM tblCRUISESHIP WHERE CruiseshipName = @ShipName)
		AND StartDate = @Start AND EndDate = @End)
GO
-- 7. Get ExcursionTripID
CREATE PROC cruise_GetExcursionTripID
@STime datetime,
@ETime datetime,
@ExcName varchar(50),
@SName varchar(50),
@TripStart date,
@TripEnd date,
@ET_ID INT OUTPUT
AS
DECLARE @TripID INT, @ExcursionID INT
EXEC cruise_GetExcursionID
@EName = @ExcName,
@E_ID = @ExcursionID OUTPUT
EXEC cruise_GetTripID
@ShipName = @SName,
@Start = @TripStart,
@End = @TripEnd,
@T_ID = @TripID OUTPUT
SET @ET_ID = (SELECT ExcursionTripID FROM tblEXCURSION_TRIP
	WHERE TripID = @TripID
		AND StartTime = @STime
		AND EndTime = @ETime
		AND ExcursionID = @ExcursionID)
GO

-- Computed Columns
-- 1. Number of incidents for each trip
CREATE FUNCTION cruise_NumDeckEmergencies_fn(@PK_ID INT)
RETURNS INT
AS
BEGIN 
	DECLARE @Ret INT =
	(SELECT COUNT(I.IncidentID)
	FROM tblTRIP T
		JOIN tblSTAFF_TRIP_POSITION STP ON T.TripID = STP.TripID
		JOIN tblINCIDENT I ON STP.StaffTripPosID = I.StaffTripPosID
		JOIN tblINCIDENT_TYPE IT ON I.IncidentTypeID = IT.IncidentTypeID
		JOIN tblPOSITION P ON STP.PositionID = P.PositionID
		JOIN tblPOSITION_TYPE PT ON P.PositionTypeID = PT.PositionTypeID
		JOIN tblVENUES V ON I.VenueID = V.VenueID
		JOIN tblVENUE_TYPE VT ON V.VenueTypeID = VT.VenueTypeID
	WHERE T.TripID = @PK_ID
		AND IT.IncidentTypeName = 'Emergency'
		AND PT.PositionTypeName = 'Living Space Department'
		AND VT.VenueTypeName = 'Deck')
RETURN @Ret
END
GO
ALTER TABLE tblTRIP ADD TotalDeckEmergencies AS (dbo.cruise_NumDeckEmergencies_fn(TripID))
-- 2. How many customers are on a trip (Check CUST_BOOK status)
--	  Confused about what is meant by this...
CREATE FUNCTION cruise_TotalActivePassengers_fn(@PK_ID INT)
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT =
	(SELECT COUNT(B.BookingID)
	FROM tblBOOKING B
		JOIN tblBOOKING_STATUS BS ON BS.BookStatusID = B.BookStatusID
		JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
		JOIN tblTRIP T ON TC.TripID = T.TripID
	WHERE T.TripID = @PK_ID
		AND BS.BookStatusName != 'Canceled')
RETURN @Ret
END
GO
ALTER TABLE tblTRIP ADD TotalPassengers AS (dbo.cruise_TotalActivePassengers_fn(TripID))
-- 3. Total custombers booked for each cabin_trip.
CREATE FUNCTION cruise_TotalCabinCapacity_fn(@PK_ID INT)
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT =
	(SELECT COUNT(B.BookingID)
	FROM tblBOOKING B
		JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
	WHERE TC.TripCabinID = @PK_ID)
RETURN @Ret
END
GO
ALTER TABLE tblTRIP_CABIN ADD TotCustCab AS (dbo.cruise_TotalCabinCapacity_fn(TripCabinID))
GO

-- Views
-- 1. View the distribution of ages for the Disney Cruise Line.
SELECT (CASE
	WHEN C.CustDOB < (GETDATE() - 65 * 365.25)
	THEN 'Seniors'
	WHEN C.CustDOB < (GETDATE() - 55 * 365.25)
	THEN 'Older Adult'
	WHEN C.CustDOB < (GETDATE() - 35 * 365.25)
	THEN 'Mid-Aged Adults'
	WHEN C.CustDOB < (GETDATE() - 25 * 365.25)
	THEN 'Adult'
	WHEN C.CustDOB < (GETDATE() - 18 * 365.25)
	THEN 'Young Adult'
	WHEN C.CustDOB < (GETDATE() - 10 * 365.25)
	THEN 'Teenager'
	WHEN C.CustDOB < (GETDATE() - 2 * 365.25)
	THEN 'Child'
	ELSE 'Baby'
END) AS AgeGroups, COUNT(*) AS TotDisneyCust
FROM tblCUSTOMER C
	JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
	JOIN tblBOOKING B ON CB.BookingID = B.BookingID
	JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
	JOIN tblCABIN CA ON TC.CabinID = CA.CabinID
	JOIN tblCRUISESHIP CR ON CA.CruiseshipID = CR.CruiseshipID
	JOIN tblCRUISELINE CL ON CR.CruiseLineID = CL.CruiseLineID
WHERE CL.CruiseLineName = 'Disney Cruise Line'
GROUP BY (CASE
	WHEN C.CustDOB < (GETDATE() - 65 * 365.25)
	THEN 'Seniors'
	WHEN C.CustDOB < (GETDATE() - 55 * 365.25)
	THEN 'Older Adult'
	WHEN C.CustDOB < (GETDATE() - 35 * 365.25)
	THEN 'Mid-Aged Adults'
	WHEN C.CustDOB < (GETDATE() - 25 * 365.25)
	THEN 'Adult'
	WHEN C.CustDOB < (GETDATE() - 18 * 365.25)
	THEN 'Young Adult'
	WHEN C.CustDOB < (GETDATE() - 10 * 365.25)
	THEN 'Teenager'
	WHEN C.CustDOB < (GETDATE() - 2 * 365.25)
	THEN 'Child'
	ELSE 'Baby'
END)
ORDER BY TotDisneyCust
-- 2. View top 15 customers who have spent the most on
--`   all excursions and activities in last 5 years...
--	  Who have also been to a port in Mexico during the 2010s.
--	  Who have also had an incident type 'injury' at the venue type 'bar'.
SELECT TOP 15 C.CustID, C.CustFname, C.CustLname, C.CustDOB, SUM(E.Cost) AS CummulativeSum
FROM tblCUSTOMER C
	JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
	JOIN tblBOOKING B ON CB.BookingID = B.BookingID
	JOIN tblBOOKING_STATUS BS ON B.BookStatusID = BS.BookStatusID
	JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
	JOIN tblTRIP T ON TC.TripID = T.TripID
	JOIN tblEXCURSION_TRIP EC ON TC.TripID = EC.TripID
	JOIN tblEXCURSION E ON EC.ExcursionID = E.ExcursionID
	JOIN tblCUST_BOOK_EXC_TRIP CBET ON EC.ExcursionTripID = CBET.ExcursionTripID
	JOIN tblCRUISESHIP CS ON T.CruiseshipID = CS.CruiseshipID
	JOIN tblVENUES V ON CS.CruiseshipID = V.CruiseshipID
	JOIN tblVENUE_TYPE VT ON V.VenueTypeID = V.VenueTypeID
	JOIN tblINCIDENT I ON V.VenueID = I.VenueID
	JOIN tblINCIDENT_TYPE IT ON I.IncidentTypeID = IT.IncidentTypeID
JOIN
	(SELECT C.CustID, C.CustFname, C.CustLname, C.CustDOB
	FROM tblCUSTOMER C
		JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
		JOIN tblBOOKING B ON CB.BookingID = B.BookingID
		JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
		JOIN tblTRIP T ON TC.TripID = T.TripID
		JOIN tblEXCURSION_TRIP EC ON TC.TripID = EC.TripID
		JOIN tblEXCURSION E ON EC.ExcursionID = E.ExcursionID
		JOIN tblROUTE_LOCATION RL ON E.RouteLocID = RL.RouteLocID
		JOIN tblLOCATION L ON RL.LocationID = L.LocationID
		JOIN tblCOUNTRY CO ON L.CountryID = CO.CountryID
	WHERE CO.CountryName = 'Mexico'
		AND T.StartDate BETWEEN '2010' AND '2019') AS SQ1 ON SQ1.CustID = C.CustID
WHERE EC.StartTime > (SELECT GETDATE() - 365.25 * 5)
	AND IT.IncidentTypeName = 'Injury'
	AND VT.VenueTypeName = 'Bar'
	AND BS.BookStatusName != 'Canceled'
GROUP BY C.CustID, C.CustFname, C.CustLname, C.CustDOB
ORDER BY SUM(E.Cost) DESC

-- Synthetic Transactions
-- 1. tblCUST_BOOK_ACT_TRIP
-- Is the the while loop function???
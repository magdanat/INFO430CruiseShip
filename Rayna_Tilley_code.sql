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
				AND ETY.ExcursionTypeName = 'Hiking'
				AND BS.BookStatusName = 'Valid')
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
-- 2. No booking an excursion if the booking status for the customer's trip is "Canceled"
CREATE FUNCTION cruise_CustBookExcTrip_NoCanceled()
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
@STime = @ExcStart,
@ETime = @ExcEnd,
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
BEGIN TRAN T
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
-- 6. Get TripID
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
-- 1. Number of "Emergency" incidents in living space departments for each trip.
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
ALTER TABLE tblTRIP
ADD TotalDeckEmergencies AS (dbo.cruise_NumDeckEmergencies_fn(TripID))
-- 2. How many customers are on a trip that are younger than 21.
CREATE FUNCTION cruise_TotalActivePassengersUnder21_fn(@PK_ID INT)
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT =
	(SELECT COUNT(CB.CustBookingID)
	FROM tblBOOKING B
		JOIN tblBOOKING_STATUS BS ON BS.BookStatusID = B.BookStatusID
		JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
		JOIN tblTRIP T ON TC.TripID = T.TripID
		JOIN tblCUST_BOOK CB ON B.BookingID = CB.BookingID
		JOIN tblCUSTOMER C ON CB.CustID = C.CustID
	WHERE T.TripID = @PK_ID
		AND BS.BookStatusName != 'Canceled'
		AND C.CustDOB > (B.BookingTime - 365.25 * 21)
RETURN @Ret
END
GO
ALTER TABLE tblTRIP
ADD TotalPassengersUnder21 AS (dbo.cruise_TotalActivePassengersUnder21_fn(TripID))
-- 3. Ratio of customers under 21 over customers older than 21 for each trip.
CREATE FUNCTION cruise_RatioCustUnder21Over21Up_fn(@PK_ID INT)
RETURNS numeric(8,6)
AS
BEGIN
	DECLARE @TotalUnder21 INT, @Total21AndOVer INT, @Ret INT
	SET @TotalUnder21 =
	(SELECT COUNT(CB.CustBookingID)
	FROM tblBOOKING B
		JOIN tblBOOKING_STATUS BS ON BS.BookStatusID = B.BookStatusID
		JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
		JOIN tblTRIP T ON TC.TripID = T.TripID
		JOIN tblCUST_BOOK CB ON B.BookingID = CB.BookingID
		JOIN tblCUSTOMER C ON CB.CustID = C.CustID
	WHERE T.TripID = @PK_ID
		AND BS.BookStatusName = 'Valid'
		AND C.CustDOB > (B.BookingTime - 365.25 * 21))
	SET @Total21AndOver =
	(SELECT COUNT(CB.CustBookingID)
	FROM tblBOOKING B
		JOIN tblBOOKING_STATUS BS ON BS.BookStatusID = B.BookStatusID
		JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
		JOIN tblTRIP T ON TC.TripID = T.TripID
		JOIN tblCUST_BOOK CB ON B.BookingID = CB.BookingID
		JOIN tblCUSTOMER C ON CB.CustID = C.CustID
	WHERE T.TripID = @PK_ID
		AND BS.BookStatusName = 'Valid'
		AND C.CustDOB <= (B.BookingTime - 365.25 * 21))
	IF @Total21AndOver = 0
		BEGIN
			SET @Total21AndOver = 1
		END
	SET @Ret = (CONVERT(FLOAT, @TotalUnder21) / @Total21AndOver)
RETURN @Ret
END
GO
ALTER TABLE tblTRIP
ADD RatioCustUnder21Over21Up AS (dbo.cruise_RatioCustUnder21Over21Up_fn(TripID))
-- 4. Ratio of customers that are female over customers that are male for each trip.
CREATE FUNCTION cruise_RatioCustFemOverMale_fn(@PK_ID INT)
RETURNS numeric(8,6)
AS
BEGIN
	DECLARE @TotalFemale INT, @TotalMale INT, @Ret INT
	SET @TotalFemale =
	(SELECT COUNT(CB.CustBookingID)
	FROM tblBOOKING B
		JOIN tblBOOKING_STATUS BS ON BS.BookStatusID = B.BookStatusID
		JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
		JOIN tblTRIP T ON TC.TripID = T.TripID
		JOIN tblCUST_BOOK CB ON B.BookingID = CB.BookingID
		JOIN tblCUSTOMER C ON CB.CustID = C.CustID
		JOIN tblGENDER G ON C.GenderID = G.GenderID
	WHERE T.TripID = @PK_ID
		AND BS.BookStatusName = 'Valid'
		AND G.GenderName = 'Female')
	SET @TotalMale =
	(SELECT COUNT(CB.CustBookingID)
	FROM tblBOOKING B
		JOIN tblBOOKING_STATUS BS ON BS.BookStatusID = B.BookStatusID
		JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
		JOIN tblTRIP T ON TC.TripID = T.TripID
		JOIN tblCUST_BOOK CB ON B.BookingID = CB.BookingID
		JOIN tblCUSTOMER C ON CB.CustID = C.CustID
		JOIN tblGENDER G ON C.GenderID = G.GenderID
	WHERE T.TripID = @PK_ID
		AND BS.BookStatusName = 'Valid'
		AND G.GenderName = 'Male')
	IF @TotalMale = 0
		BEGIN
			SET @TotalMale = 1
		END
	SET @Ret = (CONVERT(FLOAT, @TotalFemale) / @TotalMale)
RETURN @Ret
END
GO
ALTER TABLE tblTRIP
ADD RatioCustFemOverMale AS (dbo.cruise_RatioCustFemOverMale_fn(TripID))
SELECT * FROM tblTRIP
-- 5. Total customers booked for each cabin_trip.
CREATE FUNCTION cruise_TotalCabinCapacity_fn(@PK_ID INT)
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT =
	(SELECT COUNT(CB.CustBookingID)
	FROM tblBOOKING B
		JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
		JOIN tblCUST_BOOK CB ON B.BookingID = CB.BookingID
		JOIN tblBOOKING_STATUS BS ON B.BookStatusID = BS.BookStatusID
	WHERE TC.TripCabinID = @PK_ID
		AND BS.BookStatusName = 'Valid')
RETURN @Ret
END
GO
ALTER TABLE tblTRIP_CABIN
ADD TotCustCab AS (dbo.cruise_TotalCabinCapacity_fn(TripCabinID))
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
-- 1. tblCUST_BOOK_EXC_TRIP
ALTER PROCEDURE WRAPPER_cruise_NewRowCustBookExcTrip
@Run INT
AS
DECLARE @RegTime datetime, @EStart datetime, @EEnd datetime, @CFname varchar(50),
	@CLname varchar(50), @CDOB date, @BNum char(7), @ExcName varchar(50), 
	@SName varchar(50), @TStartDay date, @TEndDay date
DECLARE @CustBook_PK INT, @ExcTrip_PK INT
DECLARE @CustBookRowCount INT = (SELECT COUNT(*) FROM tblCUST_BOOK)
DECLARE @ExcTripRowCount INT = (SELECT COUNT(*) FROM tblEXCURSION_TRIP)
WHILE @Run > 0
BEGIN
	SET @CustBook_PK = (SELECT RAND() * @CustBookRowCount)
	SET @ExcTrip_PK = (SELECT RAND() * @ExcTripRowCount)
	SET @EStart = (SELECT StartTime FROM tblEXCURSION_TRIP WHERE ExcursionTripID = @ExcTrip_PK)
	-- Set @RegTime equal to a random datetime before EStart.
	SET @RegTime = (SELECT DATEADD(DAY, -3, @EStart))
	SET @EEnd = (SELECT EndTime FROM tblEXCURSION_TRIP WHERE ExcursionTripID = @ExcTrip_PK)
	SET @CFname = (SELECT C.CustFName FROm tblCUSTOMER C
			JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
		WHERE CB.CustBookingID = @CustBook_PK)
	SET @CLname = (SELECT C.CustLname FROm tblCUSTOMER C
			JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
		WHERE CB.CustBookingID = @CustBook_PK)
	SET @CDOB = (SELECT C.CustDOB FROm tblCUSTOMER C
			JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
		WHERE CB.CustBookingID = @CustBook_PK)
	SET @BNum = (SELECT BookingNumber FROM tblBOOKING B
			JOIN tblCUST_BOOK CB ON B.BookingID = CB.BookingID
		WHERE CB.CustBookingID = @CustBook_PK)
	SET @ExcName = (SELECT ExcursionName FROM tblEXCURSION E
			JOIN tblEXCURSION_TRIP ET ON E.ExcursionID = ET.ExcursionID
		WHERE ET.ExcursionTripID = @ExcTrip_PK)
	SET @SName = (SELECT CruiseshipName FROM tblCRUISESHIP C
			JOIN tblTRIP T ON C.CruiseshipID = T.CruiseshipID
			JOIN tblEXCURSION_TRIP ET ON T.TripID = ET.TripID
		WHERE ET.ExcursionTripID = @ExcTrip_PK)
	SET @TStartDay = (SELECT StartDate FROM tblTRIP T
			JOIN tblEXCURSION_TRIP ET ON T.TripID = ET.TripID
		WHERE ET.ExcursionTripID = @ExcTrip_PK)
	SET @TEndDay = (SELECT EndDate FROM tblTRIP T
			JOIN tblEXCURSION_TRIP ET ON T.TripID = ET.TripID
		WHERE ET.ExcursionTripID = @ExcTrip_PK)
	EXEC cruise_NewRowCustBookExcTrip
	@RegisTime = @RegTime,
	@ExcStart = @EStart,
	@ExcEnd = @EEnd,
	@CustFname = @CFname,
	@CustLname = @CLname,
	@CustDOB = @CDOB,
	@BookingNumber = @BNum,
	@ExcursionName = @ExcName,
	@ShipName = @SName,
	@TripStartDay = @TStartDay,
	@TripEndDay = @TEndDay
	SET @Run = @Run - 1
END
EXEC WRAPPER_cruise_NewRowCustBookExcTrip
@Run = 3
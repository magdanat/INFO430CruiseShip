-- Rayna Tilley
-- Cruiseship Code

/*
SUMMARY:
Business Rules: IP
Stored Procedures: DONE
Computed Columns: Not Started
Views: Not Started
Synthetic Transactions: Not Started
*/

USE CRUISE

-- Business Rules
-- 1. Staff can only be assigned to one trip at a time. If a staff member is currently on
--	  a trip, they cannot be scheduled to join another trip.

-- may need a while loop?

CREATE FUNCTION cruise_Staff_OneTripAtATime()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
		IF EXISTS(SELECT *
			FROM tbl)
		BEGIN
			SET @Ret = 1
		END
	RETURNS @Ret
END
GO
ALTER TABLE tbl
ADD CONSTRAINT OneTripAtATime
CHECK(dbo.cruise_Staff_OneTripAtATime() = 0)
GO
-- 2. No more than the capacity for each cabin.

-- may need a while loop?
CREATE FUNCTION cruise_CabinCapacity()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
		IF EXISTS(SELECT *
			FROM tbl)
		BEGIN
			SET @Ret = 1
		END
	RETURNS @Ret
END
GO
ALTER TABLE tbl
ADD CONSTRAINT OneTripAtATime
CHECK(dbo.cruise_CabinCapacity() = 0)
GO

-- Stored Procedures
-- 1. Add new row in tblCUST_BOOK_EXC_TRIP
CREATE PROC cruise_NewRowCustBookExcTrip
@Cost numeric(8,2),
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
@TripName varchar(50),
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
@TrName = @TripName,
@TripStart = @TripStartDay,
@TripEnd = @TripEndDay,
@ET_ID = @ExcursionTripID OUTPUT
IF @ExcursionTripID IS NULL
BEGIN
	RAISERROR('@ExcursionTripID cannot be null.',11,1)
	RETURN
END
BEGIN TRAN T1
INSERT INTO tblCUST_BOOK_EXC_TRIP(Cost, RegisTime, ExcursionTripID, CustBookingID)
VALUES(@Cost, @RegisTime, @ExcursionTripID, @CustBookingID)
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
@TName varchar(50),
@Start date,
@End date,
@T_ID INT OUTPUT
AS
SET @T_ID = (SELECT TripID FROM tblTRIP
	WHERE TripName = @TName AND StartDate = @Start AND EndDate = @End)
GO
-- 7. Get ExcursionTripID
CREATE PROC cruise_GetExcursionTripID
@STime datetime,
@ETime datetime,
@ExcName varchar(50),
@TrName varchar(50),
@TripStart date,
@TripEnd date,
@ET_ID INT OUTPUT
AS
DECLARE @TripID INT, @ExcursionID INT
EXEC cruise_GetExcursionID
@EName = @ExcName,
@E_ID = @ExcursionID OUTPUT
EXEC cruise_GetTripID
@TName = @TrName,
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
CREATE FUNCTION cruise_NumIncidentsPerTrip_fn(@PK_ID INT)
RETURNS INT
AS
BEGIN 
	DECLARE @Ret INT =
	(SELECT COUNT(I.IncidentID)
	FROM tblTRIP T
		JOIN tblSTAFF_TRIP_POSITION STP ON T.TripID = STP.TripID
		JOIN tblINCIDENT I ON STP.StaffTripPosID = I.StaffTripPosID
	WHERE T.TripID = @PK_ID)
RETURN @Ret
END
GO
ALTER TABLE tblTRIP ADD TotalIncidents AS (dbo.cruise_NumIncidentsPerTrip_fn(@TripID))

-- 2. How many customers are on a trip (Check CUST_BOOK status)
--	  Confused about what is meant by this...
CREATE FUNCTION cruise_TotalActivePassengers_fn(@PK_ID INT)
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT =
	(SELECT COUNT(C.CustID)
	FROM tblCUSTOMER C
		JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
		JOIN tblBOOKING B ON CB.BookingID = B.BookingID
		JOIN tblBOOKING_STATUS BS ON BS.BookStatusID = B.BookStatusID
		JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
		JOIN tblTRIP T ON TC.TripID = T.TripID
	WHERE T.TripID = @PK_ID)
RETURN @Ret
END
GO
ALTER TABLE tblTRIP ADD TotalPassengers AS (dbo.cruise_TotalActivePassengers_fn(@TripID INT))

-- Views
-- 1. View the top 10 curiseships that have the most trips within 5 years
SELECT TOP 5 C.*
FROM tblCRUISESHIP C
	JOIN tbl

-- 2. View top 100 customers who have spent the most on
--`   all excursions and activities in last 5 years

-- Synthetic Transactions
-- 1. tblCUST_BOOK_ACT_TRIP


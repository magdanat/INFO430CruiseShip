-- Computed Columns
-- Total Trip Cost for a Customer for Succesfully-Finished trips in the
-- past 10 years

-- Trip has to be in past 10 years
-- Succesfully Finished
-- Total Cost
Use Cruise
Go

Create Function fTotalCostPastTenYears
(@PK Int)

Returns Numeric(8,2)
As
Begin
	Declare @Ret Numeric(8, 2)
	Set @Ret = (
		Select Sum(CBT.Cost) From tblCUST_BOOK_TRIP CBT
			Join tblTRIP T On CBT.TripID = T.TripID
			Join tblCUST_BOOK CB On CBT.CustBookingID = CB.CustBookingID
			Join tblCUSTOMER C On CB.CustID = C.CustID
			Join tblBOOKING B On CB.BookingID = B.BookingID
			Join tblBOOKING_STATUS BS On B.BookingStatusID = BS.BookingStatusID
		Where T.StartDate >= (Select GetDate() - 365.25 * 10)
			And BS.BookStatusName = 'Valid'
			-- And T.EndDate <= (Select GetDate()
			And C.CustID = @PK)
	Return @Ret
End
Go

Alter Table tblCustomer
ADD TripCostRecent10Years As (dbo.fTotalCostPastTenYears(CustID))
Go

-- Total Number of Attendance for a Activity_Trip

Create Function fTotalAttendanceForActivity
(@AK Int, @TK Int)

Returns Int
As
Begin
	Declare @Ret Int
	Set @Ret = (
		Select Count(*) From tblCUST_BOOK_ACT_TRIP CBAT
			Join tblACTIVITY_TRIP ATP On CBAT.ActivityTripID = ATAP.ActivityTripID
			Join tblTRIP T On ATP.TripID = T.TripID	
		Where ATP.ActivityID = @AK
		And T.TripID = @TK)
	Return @Ret
End
Go

Alter Table ATP
Add TotalAttendanceForActivity As (dbo.fTotalAttendanceForActivity(ActivityID, TripID))
Go

-- Doris

/* Computed Columns */
/* CC 1
Total excursion cost for a customer for successfully-finished(status  be 'Valid') trips in the past 10 years */
CREATE FUNCTION totalExcursionSpent10Years(@PK INT)
RETURNS NUMERIC(8,2)
AS
BEGIN
    DECLARE @RET NUMERIC(8,2)
    SET @RET = (
        SELECT SUM(E.Cost) FROM tblEXCURSION E
            JOIN tblEXCURSION_TRIP EXT ON E.ExcursionID = EXT.ExcursionID
            JOIN tblCUST_BOOK_EXC_TRIP CBET ON EXT.ExcursionTripID = CBET.ExcursionTripID
            JOIN tblCUST_BOOK CK ON CBET.CustBookingID = CK.CustBookingID
            JOIN tblCUSTOMER C ON CK.CustID = C.CustID
            JOIN tblBOOKING B ON CK.BookingID = B.BookingID
            JOIN tblBOOKING_STATUS BS ON BS.BookStatusID = B.BookStatusID
            JOIN tblTRIP T ON EXT.TripID = T.TripID
        WHERE BS.BookStatusName != 'Valid'
            AND T.StartDate >= (SELECT GETDATE() - 365.25 * 10)
            AND T.EndDate <= (SELECT GETDATE())
            AND C.CustID = @PK)
    RETURN @RET
END

GO
ALTER TABLE tblCUSTOMER
ADD ExcursionSpentRecent10Years AS (dbo.totalExcursionSpent10Years(CustID))
GO

/* CC 2
Average number of passengers on board for each route within last 10 years */
CREATE FUNCTION averageNumPassengers(@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @Total INT, @TripCount INT, @RET INT
    SET @Total =
    (SELECT COUNT(DISTINCT CB.CustBookingID) FROM tblROUTE R
        JOIN tblCRUISESHIP C ON R.RouteID = C.RouteID
        JOIN tblTRIP T ON C.CruiseshipID = T.CruiseshipID
        JOIN tblTRIP_CABIN TC ON T.TripID = TC.TripID
        JOIN tblBOOKING B on TC.TripCabinID = B.TripCabinID
        JOIN tblBOOKING_STATUS BS ON B.BookStatusID = BS.BookStatusID
        JOIN tblCUST_BOOK CB ON B.BookingID = CB.BookingID
    WHERE BS.BookStatusName = 'Valid'
        AND T.StartDate <= (SELECT CONVERT(DATE, (Select GetDate())))
        AND T.EndDate <= (SELECT CONVERT(DATE, (Select GetDate())))
        AND T.EndDate >= (SELECT DATEADD(year, -10, (SELECT CONVERT(DATE, (Select GetDate())))))
        AND R.RouteID = @PK)

    SET @TripCount = (
        SELECT COUNT(DISTINCT T2.TripID) FROM tblROUTE R2
        JOIN tblCRUISESHIP C2 ON R2.RouteID = C2.RouteID
        JOIN tblTRIP T2 ON C2.CruiseshipID = T2.CruiseshipID
    WHERE T2.StartDate <= (SELECT CONVERT(DATE, (Select GetDate())))
        AND T2.EndDate <= (SELECT CONVERT(DATE, (Select GetDate())))
        AND T2.EndDate >= (SELECT DATEADD(year, -10, (SELECT CONVERT(DATE, (Select GetDate())))))
        AND R2.RouteID = @PK
        )
    IF(@TripCount = 0)
            SET @RET = 0
    ELSE
        SET @RET = (@Total / @TripCount)
    RETURN @RET
END
GO
ALTER TABLE tblROUTE
ADD averageNumPassengersRecent5Years AS (dbo.averageNumPassengers(RouteID))
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
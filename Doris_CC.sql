/* Computed Columns */
/* CC 1
Total excursion cost for a customer for successfully-finished(status cannot be 'canceled') trips in the past 10 years */
CREATE FUNCTION totalExcursionSpent10Years(@PK INT)
RETURNS NUMERIC(8,2)
AS
BEGIN
    DECLARE @RET NUMERIC(8,2)
    SET @RET =
    (SELECT SUM(CBET.Cost) FROM tblCUST_BOOK_EXC_TRIP CBET
        JOIN tblCUST_BOOK CB ON CBET.CustBookingID = CB.CustBookingID
        JOIN tblCUSTOMER C ON CB.CustID = C.CustID
        JOIN tblBOOKING B ON CB.BookingID = B.BookingID
        JOIN tblBOOKING_STATUS BS ON B.BookStatusID = BS.BookStatusID
        JOIN tblTRIP_CABIN TC on B.TripCabinID = TC.TripCabinID
        JOIN tblTRIP T on TC.TripID = T.TripID
    WHERE T.StartDate >= (SELECT GETDATE() - 365.25 * 10)
        AND BS.BookStatusName = 'Valid'
        AND T.EndDate <= (SELECT GETDATE()
        AND C.CustID = @PK))
    RETURN @RET
END

GO
ALTER TABLE tblCUSTOMER
ADD ExcursionSpentRecent10Years AS (dbo.totalExcursionSpent10Years(CustID))
GO

/* CC 2
Average number of passengers on board for each route within 5 years */
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
        AND T.StartDate <= (SELECT GETDATE())
        AND T.EndDate <= (SELECT GETDATE())
        AND T.EndDate >= (SELECT GETDATE() - 5 * 365.25)
        AND R.RouteID = @PK)

    SET @TripCount = (
        SELECT COUNT(DISTINCT T2.TripID) FROM tblROUTE R2
        JOIN tblCRUISESHIP C2 ON R2.RouteID = C2.RouteID
        JOIN tblTRIP T2 ON C2.CruiseshipID = T2.CruiseshipID
    WHERE T2.StartDate <= (SELECT GETDATE())
        AND T2.EndDate <= (SELECT GETDATE())
        AND T2.EndDate >= (SELECT GETDATE() - 5 * 365.25)
        AND R2.RouteID = @PK
        )

    SET @RET = @Total / @TripCount
    RETURN @RET
END
GO
ALTER TABLE tblROUTE
ADD averageNumPassengersRecent5Years AS (dbo.averageNumPassengers(RouteID))
GO

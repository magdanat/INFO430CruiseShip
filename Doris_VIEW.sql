/* VIEWS */
USE CRUISE
/* V1
View the top 10 routes with the most trips with 'Mainstream' cruiseship_type within the last 10 years */
CREATE VIEW vw_Top10RoutesWithMainstreamShip10Years
AS
    SELECT TOP 10 WITH TIES R.RouteID, R.RouteName, COUNT() FROM tblROUTE R
        JOIN tblCRUISESHIP C on R.RouteID = C.RouteID
        JOIN tblCRUISESHIP_TYPE CT on C.CruiseshipTypeID = CT.CruiseshipTypeID
        JOIN tblTRIP T ON C.CruiseshipID = T.CruiseshipID
    WHERE T.StartDate <= (SELECT GETDATE())
        AND T.EndDate <= (SELECT GETDATE())
        AND T.EndDate >= (SELECT GETDATE() - 10 * 365.25)
        AND CT.CruiseshipTypeName = 'Mainstream'
    GROUP BY R.RouteID, R.RouteName
    ORDER BY COUNT(DISTINCT T.TripID)
GO

/* Added, new V1
 Find the cruiseship that has the most valid booking in total, for which the 'BookingTime' is between 2010 and 2020
 for each Cruiseline using rank
 */
WITH CTE_ValidBookingCruiseship (CruiseshipID, CruiseshipName, CruiseLineID, numOfBooking, Dense_RankNumBooking)
AS
    (SELECT C.CruiseshipID, C.CruiseshipName, CRL.CruiseLineID, COUNT(DISTINCT B.BookingID) AS numOfBooking,
            DENSE_RANK() OVER (PARTITION BY CRL.CruiseLineID ORDER BY COUNT(DISTINCT B.BookingID) DESC)
                AS Dense_RankNumBooking
    FROM TBLCRUISELINE CRL
        JOIN tblCRUISESHIP C on CRL.CruiseLineID = C.CruiseLineID
        JOIN tblTRIP T ON C.CruiseshipID = T.CruiseshipID
        JOIN tblTRIP_CABIN TC on T.TripID = TC.TripID
        JOIN tblBOOKING B ON TC.TripCabinID = B.TripCabinID
        JOIN tblBOOKING_STATUS BS ON B.BookStatusID = BS.BookStatusID
    WHERE B.BookingTime BETWEEN '2010-01-01' AND '2020-12-31'
        AND BS.BookStatusName = 'Valid'
    GROUP BY C.CruiseshipID, C.CruiseshipName, CRL.CruiseLineID)

SELECT CruiseshipID, CruiseshipName, numOfBooking, Dense_RankNumBooking
FROM CTE_ValidBookingCruiseship
WHERE Dense_RankNumBooking = 1
ORDER BY numOfBooking, Dense_RankNumBooking


/* V2
View top 20 customers who have registered for more than 50 activities within all trips he/she attended in last 5 years
   and who have also successfully have more than 5 trips living in 'Suites' in last 5 years */
CREATE VIEW vw_ManyActivities5Years_MoreThan5Trips5Years
AS
    SELECT TOP 20 WITH TIES C.CustFname, C.CustLname, subQ.NumSuites5Years,
                    COUNT(DISTINCT CBAT.CustBookActTripID) AS numActivities5Years
    FROM tblTRIP T
        JOIN tblTRIP_CABIN TC ON T.TripID = TC.TripID
        JOIN tblBOOKING B ON TC.TripCabinID = B.TripCabinID
        JOIN tblBOOKING_STATUS BS ON B.BookStatusID = BS.BookStatusID
        JOIN tblCUST_BOOK CB ON B.BookingID = CB.BookingID
        JOIN tblCUSTOMER C ON CB.CustID = C.CustID
        JOIN tblCUST_BOOK_ACT_TRIP CBAT on CB.CustBookingID = CBAT.CustBookingID
        JOIN (
            SELECT COUNT(DISTINCT CB2.CustBookingID) AS NumSuites5Years, C2.CustID FROM tblTRIP T2
                JOIN tblTRIP_CABIN TC2 ON T2.TripID = TC2.TripID
                JOIN tblCABIN CA2 ON TC2.CabinID = CA2.CabinID
                JOIN tblCABIN_TYPE CT2 on CA2.CabinTypeID = CT2.CabinTypeID
                JOIN tblBOOKING B2 ON TC2.TripCabinID = B2.TripCabinID
                JOIN tblBOOKING_STATUS BS2 ON B2.BookStatusID = BS2.BookStatusID
                JOIN tblCUST_BOOK CB2 ON B2.BookingID = CB2.BookingID
                JOIN tblCUSTOMER C2 ON CB.CustID = C2.CustID
            WHERE BS2.BookStatusName = 'Valid'
                AND T2.StartDate <= (SELECT GETDATE())
                AND T2.EndDate <= (SELECT GETDATE())
                AND T2.EndDate >= (SELECT GETDATE() - 5 * 365.25)
                AND CT2.CabinTypeName = 'Suites'
            GROUP BY C2.CustID
            HAVING COUNT(DISTINCT CB2.CustBookingID) > 5
        ) AS subQ ON subQ.CustID = C.CustID
    WHERE BS.BookStatusName = 'Valid'
        AND T.StartDate <= (SELECT GETDATE())
        AND T.EndDate <= (SELECT GETDATE())
        AND T.EndDate >= (SELECT GETDATE() - 5 * 365.25)
    GROUP BY C.CustFname, C.CustLname
    HAVING COUNT(DISTINCT CBAT.CustBookingID) > 50
    ORDER BY COUNT(DISTINCT CBAT.CustBookActTripID) DESC
GO

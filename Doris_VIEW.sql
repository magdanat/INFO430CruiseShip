/* VIEWS */
USE CRUISE

/* V1
 Find the cruiseship that has the most valid booking in total, for which the 'BookingTime' is between 2010 and 2020
 for each Cruiseline using rank
 */
CREATE VIEW vw_validBooking AS
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

SELECT CruiseshipID, CruiseshipName, CruiseLineID, numOfBooking, Dense_RankNumBooking
FROM CTE_ValidBookingCruiseship
WHERE Dense_RankNumBooking = 1

/* V2
View all customers who have registered for more than 5 excursions within all trips he/she attended in next 10 years
   and who is also going to have more than 1 trip in next 10 years */

CREATE VIEW vw_ManyExcursions10Years_MoreThan1Trips10Years
AS
    SELECT C.CustFname, C.CustLname, subQ.NumTrip10Years,
                    COUNT(DISTINCT CBET.CustBookExcTripID) AS numExcursions10Years
    FROM tblTRIP T
        JOIN tblTRIP_CABIN TC ON T.TripID = TC.TripID
        JOIN tblBOOKING B ON TC.TripCabinID = B.TripCabinID
        JOIN tblBOOKING_STATUS BS ON B.BookStatusID = BS.BookStatusID
        JOIN tblCUST_BOOK CB ON B.BookingID = CB.BookingID
        JOIN tblCUSTOMER C ON CB.CustID = C.CustID
        JOIN tblCUST_BOOK_EXC_TRIP CBET on CB.CustBookingID = CBET.CustBookingID
        JOIN (
            SELECT COUNT(DISTINCT CB2.CustBookingID) AS NumTrip10Years, C2.CustID FROM tblTRIP T2
                JOIN tblTRIP_CABIN TC2 ON T2.TripID = TC2.TripID
                JOIN tblCABIN CA2 ON TC2.CabinID = CA2.CabinID
                JOIN tblCABIN_TYPE CT2 on CA2.CabinTypeID = CT2.CabinTypeID
                JOIN tblBOOKING B2 ON TC2.TripCabinID = B2.TripCabinID
                JOIN tblBOOKING_STATUS BS2 ON B2.BookStatusID = BS2.BookStatusID
                JOIN tblCUST_BOOK CB2 ON B2.BookingID = CB2.BookingID
                JOIN tblCUSTOMER C2 ON CB2.CustID = C2.CustID
            WHERE BS2.BookStatusName = 'Valid'
                AND T2.StartDate <= (SELECT DATEADD(year, 10, (SELECT CONVERT(DATE, (Select GetDate())))))
                AND T2.StartDate >= (SELECT CONVERT(DATE, (Select GetDate())))
            GROUP BY C2.CustID
            HAVING COUNT(DISTINCT CB2.CustBookingID) >= 2
        ) AS subQ ON subQ.CustID = C.CustID
    WHERE BS.BookStatusName = 'Valid'
        AND T.StartDate <= (SELECT DATEADD(year, 10, (SELECT CONVERT(DATE, (Select GetDate())))))
        AND T.StartDate >= (SELECT CONVERT(DATE, (Select GetDate())))
    GROUP BY C.CustFname, C.CustLname, subQ.NumTrip10Years
    HAVING COUNT(DISTINCT CBET.CustBookExcTripID) >= 5
GO
SELECT * FROM vw_ManyExcursions10Years_MoreThan1Trips10Years
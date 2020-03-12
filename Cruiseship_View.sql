-- Views
-- 1. View the top 10 curiseships that have the most trips within 5 years
-- Probably too simple...
-- Doris
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
   and who is also going to have more than 1 trips in next 10 years */

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

-- Rayna

SELECT TOP 10 with ties C.CruiseshipID, C.CruiseshipName, COUNT(T.TripID) AS TotalTrips
FROM tblCRUISESHIP C
	JOIN tblTRIP T ON C.CruiseshipID = T.CruiseshipID
WHERE T.StartDate > (SELECT GETDATE() - 365.25 * 5)
GROUP BY C.CruiseshipID, C.CruiseshipName
ORDER BY COUNT(T.TripID) DESC

-- 2. View top 15 customers who have spent the most on
--`   all excursions and activities in last 5 years...
--	  Who have also been to a port in Mexico during the 2010s.
SELECT TOP 15 C.CustID, C.CustFname, C.CustLname, C.CustDOB, SUM(CBET.Cost) AS CummulativeSum
FROM tblCUSTOMER C
	JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
	JOIN tblBOOKING B ON CB.BookingID = B.BookingID
	JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
	JOIN tblTRIP T ON TC.TripID = T.TripID
	JOIN tblEXCURSION_TRIP EC ON TC.TripID = EC.TripID
	JOIN tblEXCURSION E ON EC.ExcursionID = E.ExcursionID
	JOIN tblCUST_BOOK_EXC_TRIP CBET ON EC.ExcursionTripID = CBET.ExcursionTripID
JOIN
	(SELECT C.CustID, C.CustFname, C.CustLname, C.CustDOB
	FROM tblCUSTOMER C
		JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
		JOIN tblBOOKING B ON CB.BookingID = B.BookingID
		JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
		JOIN tblTRIP T ON TC.TripID = T.TripID
		JOIN tblEXCURSION_TRIP EC ON TC.TripID = EC.TripID
		JOIN tblEXCURSION E ON EC.ExcursionID = E.ExcursionID
		JOIN tblROUTE_PORT RP ON E.RoutePortID = RP.RoutePortID
		JOIN tblPORT P ON RP.PortID = P.PortID
		JOIN tblCITY CI ON P.CityID = CI.CityID
		JOIN tblCOUNTRY CO ON CI.CountryID = CO.CountryID
	WHERE CO.CountryName = 'Mexico'
		AND T.StartDate BETWEEN '2010' AND '2019') AS SQ1 ON SQ1.CustID = C.CustID
WHERE EC.StartTime > (SELECT GETDATE() - 365.25 * 5)
GROUP BY C.CustID, C.CustFname, C.CustLname, C.CustDOB
ORDER BY SUM(CBET.Cost) DESC

---View the numbers of each excursion types (number of excursion trip) in descending order

CREATE VIEW vw_NumExcurstionType 

AS 
  
   SELECT TOP 7 WITH TIES E.ExcursionID, E.ExcursionName, COUNT(DISTINCT ET.ExcursionTypeID) AS NumExcursionType FROM tblEXCURSION E
      JOIN tblEXCURSION ET ON ET.ExcursionTypeID = E.ExcursionTypeID
	  JOIN tblEXCURSION_TRIP ETR ON E.ExcursionID = ETR.ExcursionID
   GROUP BY E.ExcursionID, E.ExcursionName, NumExcursionType


GO

---View the top 50 cities that have the most trip_excursion

CREATE VIEW vw_Top50CitiesMostTripExcursion

AS

   SELECT TOP 50 WITH TIES C.CityID, C.CityName, COUNT(DISTINCT ETR.ExcursionTripID) AS NumTrip_Excursion FROM tblCity C
        JOIN tblPORT P ON C.CityID = P.CityID
		JOIN tblROUTE_PORT RP ON P.PortID = RP.PortID
		JOIN tblEXCURSION E ON RP.RoutePortID = E.RoutePortID 
		JOIN tblEXCURSION_TRIP ETR ON E.ExcursionID = ETR.ExcursionID
	GROUP BY C.CityID, C.CityName,NumTrip_Excursion


GO

-- Views

-- View 1
Create View vw_Top5CruiseLinesWithMostTrips10Years
As
	Select Top 5 with Ties CL.CruiseLineID, CL.CruiseLineName, Count(DISTINCT T.TripID) As NumTrips From tblCRUISELINE CL
		Join tblCRUISESHIP C On CL.CruiseLineID = C.CruiseLineID
		Join tblTRIP T On C.CruiseshipID = T.CruiseshipID
	Where T.StartDate <= (Select GetDate())
		And T.EndDate >= (Select GetDate() - 10 * 365.25)
	Group By CL.CruiseLineID, CL.CruiseLineName
Go
	
-- View 2
Create View vw_Top5RoutesMostIncidents
As
	Select Top 5 with Ties R.RouteID, R.RouteName, Count(DISTINCT I.IncidentID) As NumIncidents From tblROUTE R
		Join tblCRUISESHIP CS On R.RouteID = CS.RouteID
		Join tblVENUES V On CS.CruiseshipID = V.CruiseshipID
		Join tblINCIDENT I On V.VenueID = I.VenueID
	Group By R.RouteID, R.RouteName
Go
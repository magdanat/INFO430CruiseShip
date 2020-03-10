USE CRUISE
---View Staff who have been on more than 2 trips between 2009 and 2019, who have also deal with more than 5 incidents
CREATE VIEW vw_More2Trips_More5Incidents

AS

  SELECT S.StaffID, S.StaffFname, S.StaffLname, S.StaffDOB,COUNT(DISTINCT T.TripID) AS NumTrip FROM tblSTAFF S
         JOIN tblSTAFF_TRIP_POSITION STP ON S.StaffID = STP.StaffID
		 JOIN tblTRIP T ON STP.TripID = T.TripID
   JOIN(
     SELECT S.StaffID, S.StaffFname, S.StaffLname, S.StaffDOB, COUNT(DISTINCT I.IncidentID) AS NumIncident FROM tblSTAFF S
	    JOIN tblSTAFF_TRIP_POSITION STP ON S.StaffID = STP.StaffID
		JOIN tblINCIDENT I ON STP.StaffTripPosID = I.StaffTripPosID
		WHERE I.IncidentStartTime  BETWEEN '2009-01-01' AND '2019-12-31'
		 AND I.IncidentEndTime BETWEEN '2009-01-01' AND '2019-12-31'
		GROUP BY S.StaffID,S.StaffFname, S.StaffLname, S.StaffDOB
		Having COUNT(DISTINCT I.IncidentID)>= 5 ) AS Subq1 ON S.StaffID= Subq1.StaffID

   WHERE T.StartDate BETWEEN '2009-01-01' AND '2019-12-31'
		 AND T.EndDate BETWEEN '2009-01-01' AND '2019-12-31'
   GROUP BY S.StaffID, S.StaffFname, S.StaffLname, S.StaffDOB, subq1.NumIncident
   HAVING COUNT(DISTINCT T.TripID)>= 2

 SELECT * FROM vw_More2Trips_More5Incidents



---Use CTE and NTILE to devide customers into 50 parts based on their number of valid booking
WITH CTE_50CustomerPart(CustFname, CustLname, CustDOB, Divideby50Part) 

AS( 
     SELECT C.CustFname, C.CustLname, C.CustDOB, NTILE(50) OVER (ORDER BY B.BookingID) AS Divideby50Part
     FROM tblCUSTOMER C
       JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
       JOIN tblBOOKING B ON CB.BookingID = B.BookingID)
	 	
SELECT * FROM CTE_50CustomerPart

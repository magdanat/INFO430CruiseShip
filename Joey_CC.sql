USE CRUISE

---Total number of excursion_trips, whose excursion type is 'Wilderness & Wildlife' for each location between 2010 and 2030
CREATE FUNCTION fn_TotalNumExcursionTrip(@PK INT)
RETURNS INT
AS
BEGIN 
   DECLARE @RET INT =0
    SET @RET= (
	   SELECT COUNT(ET.ExcursionTripID) FROM tblEXCURSION_TRIP ET
		   JOIN tblEXCURSION E ON ET.ExcursionTripID = E.ExcursionTypeID
		   JOIN tblEXCURSION_TYPE ETY ON E.ExcursionTypeID = ETY.ExcursionTypeID
		   JOIN tblROUTE_LOCATION RL ON E.RouteLocID = RL.RouteLocTypeID
		   JOIN tblLOCATION L ON RL.LocationID = L.LocationID
		   WHERE ETY.ExcursionTypeName = 'Wilderness & Wildlife'
		   AND ET.StartTime = '2010-01-01'
		   AND ET.EndTime = '2030-12-31'
		   AND L.LocationID = @PK)
	 RETURN @RET
END

ALTER TABLE tblLOCATION
ADD NumExcursionTrip AS (dbo.fn_TotalNumExcursionTrip(LocationID))
GO



---Number of customers(CUST_BOOK) who have attend at least 1 excursion and 1 activity for each trip
CREATE FUNCTION fn_1Excursion_1activity(@EK INT, @AK INT)
RETURNS INT
AS
BEGIN 
   DECLARE @RET INT =0
    SET @RET= (
	   SELECT COUNT(E.ExcursionID) FROM tblEXCURSION E
	     JOIN tblEXCURSION_TRIP ET ON E.ExcursionID = ET.ExcursionID
		 JOIN tblACTIVITY_TRIP ACT ON ET.TripID = ACT.TripID
		 JOIN tblACTIVITY A ON ACT.ActivityTripID = A.ActivityTypeID
		WHERE ACT.ActivityID = @AK
		AND E.ExcursionID = @EK)

  RETURN @RET
END

ALTER TABLE tblTRIP
ADD Excursion_activity AS (dbo.fn_1Excursion_1activity(TripID))
GO

---Error
----Msg 313, Level 16, State 2, Line 45
----An insufficient number of arguments were supplied for the procedure or function dbo.fn_1Excursion_1activity.

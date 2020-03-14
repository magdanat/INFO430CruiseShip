CREATE FUNCTION fn_TotalNumExcursionTrip(@PK INT)
RETURNS INT
AS
BEGIN 
   DECLARE @RET INT 
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

select * from tblEXCURSION_TYPE

---total number of activity in any type and excursions, whose type is "family", for a trip
CREATE FUNCTION fn_TotalNumExcurActivity(@PK INT)
RETURNS INT
AS

BEGIN
    DECLARE @RET INT
    DECLARE @ExNum INT, @ActNum INT
    SET @ExNum = (
        SELECT COUNT(E.ExcursionID) FROM tblTRIP T
            JOIN tblEXCURSION_TRIP ETrip on T.TripID = ETrip.TripID
            JOIN tblEXCURSION E on ETrip.ExcursionID = E.ExcursionID
            JOIN tblEXCURSION_TYPE EType on E.ExcursionTypeID = EType.ExcursionTypeID
        WHERE EType.ExcursionTypeName = 'Family'
            AND T.TripID = @PK)

    SET @ActNum = (
        SELECT COUNT(A.ActivityID) FROM tblTRIP T
            JOIN tblACTIVITY_TRIP AT on T.TripID = AT.TripID
            JOIN tblACTIVITY A ON AT.ActivityID = A.ActivityID
            JOIN tblACTIVITY_TYPE ATT on A.ActivityTypeID = ATT.ActivityTypeID
           WHERE ATT.ActivityTypeName LIKE '%family%'
            AND A.ActivityID = @PK)
    SET @RET =@ExNum +@ActNum 
RETURN @RET
END

ALTER TABLE tblTRIP
ADD NumOfFamilyActExc AS (dbo.fn_TotalNumExcurActivity(TripID))


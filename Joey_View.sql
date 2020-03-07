
---View the numbers of each excursion types (number of excursion trip) in descending order

CREATE VIEW vw_NumExcurstionType 

AS 
  
   SELECT TOP 7 WITH TIES E.ExcursionID, E.ExcursionName, COUNT(DISTINCT ET.ExcursionTypeID) AS NumExcursionType FROM tblEXCURSION E
      JOIN tblEXCURSION ET ON ET.ExcursionTypeID = E.ExcursionTypeID
	  JOIN tblEXCURSION_TRIP ETR ON E.ExcursionID = ETR.ExcursionID
   GROUP BY E.ExcursionID, E.ExcursionName, NumExcursionType
   ORDER BY NumExcursionType DESC

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
	ORDER BY NumTrip_Excursion

GO



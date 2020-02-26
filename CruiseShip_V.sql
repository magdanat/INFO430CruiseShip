-- Views

-- View 1
Create View vw_Top5CruiseLinesWithMostTrips10Years
As
	Select Top 5 with Ties CL.CruiseLineID, CL.CruiseLineName, Count(DISTINCT T.TripID) As NumTrips From tblCRUISELINE CL
		Join tblCRUISESHIP C On CL.CruiseLineID = C.CruiseLineID
		Join tblTRIP T On C.CruiseshipID = T.CruiseshipID
	Where T.StartDate <= (Select GetDate())
		And T.EndDate >= (Select GetDate() - 10 * 365.25)
	Group By CL.CruiseLineID, CL.CruiseLineName, NumTrips
	Order By Count(DISTINCT T.TripID)
Go
	
-- View 2
Create View vw_Top5RoutesMostIncidents
As
	Select Top 5 with Ties R.RouteID, R.RouteName, Count(DISTINCT I.IncidentID) As NumIncidents From tblROUTE R
		Join tblCRUISESHIP CS On R.RouteID = CS.RouteID
		Join tblVENUES V On CS.CruiseshipID = V.CruiseshipID
		Join tblINCIDENT I On V.VenueID = I.VenueID
	Group By R.RouteID, R.RouteName, NumIncidents
	Order By Count(DISTINCT I.IncidentID)
Go
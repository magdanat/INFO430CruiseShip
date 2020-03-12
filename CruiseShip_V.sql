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

-- CTE
With mag_CTE_VenuesWithTheMostIncidentsIn2010s(VenueTypeID, VenueTypeName, NumIncidents)
As
(Select VT.VenueTypeID, VT.VenueTypeName, Count(*) As NumIncidents
	From tblActivity A
		Join tblVenues V On A.VenueID = V.VenueID
		Join tblVenue_Type VT On V.VenueTypeID = VT.VenueTypeID
		Join tblActivity_Trip ACT On A.ActivityID = ACT.ActivityID
		Join tblTrip T On ACT.TripID = T.TripID
		Join tblCruiseship CS On V.CruiseshipID = CS.CruiseshipID
		Join tblIncident IT On V.VenueID = IT.VenueID
		Join tblIncident_Type ITT On IT.IncidentTypeID = ITT.IncidentTypeID
	Where T.StartDate Between '2015-01-01' And '2020-01-01'
		And ITT.IncidentTypeName Like '%Injury%'
		Group By VT.VenueTypeID, VT.VenueTypeName)

Select VenueTypeID, VenueTypeName, NumIncidents, Dense_Rank() Over (Order By NumIncidents Desc) As RankNumIncidents
From mag_CTE_VenuesWithTheMostIncidentsIn2010s
Order By RankNumIncidents Asc
Go

Select * from tblINCIDENT_TYPE
Go

-- Creates a view that sees customers who have spent over 1000 dollars
-- on activities in locations in the USA on a cruieship
Create View mag_vw_CustomerMoneySpentInTheUSAOver1000
As
Select C.CustID, C.CustFname, C.CustLname, (Sum(CBAT.Cost)) As CustomerMoneySpent
	From tblCustomer C
		Join tblCust_Book CB On C.CustID = CB.CustID
		Join tblCust_Book_Act_Trip CBAT On CB.CustBookingID = CBAT.CustBookingID
		Join tblCust_Book_Exc_Trip CBET On CB.CustBookingID = CBET.CustBookingID
		Join tblActivity_Trip ACT On CBAT.ActivityTripID = ACT.ActivityTripID
		Join tblTrip T On ACT.TripID = T.TripID
		Join tblActivity A On ACT.ActivityID = A.ActivityID
		Join tblVenues V On A.VenueID = V.VenueID
		Join tblCruiseship CS On V.CruiseshipID = CS.CruiseshipID
		Join tblRoute R On  CS.RouteID = R.RouteID
		Join tblRoute_Location RL On R.RouteID = RL.RouteID
		Join tblLocation L On RL.LocationID = L.LocationID
		Join tblCountry CY On L.CountryID = CY.CountryID
	Where CY.CountryName Like '%USA%'
	Group By C.CustID, C.CustFname, C.CustLname
	Having Sum(CBAT.Cost) > 1000
Go

Select * from mag_vw_CustomerMoneySpentInTheUSAOver1000
Go

-- Creates a view that sees how much money has been spent
-- in various venues
Create View  mag_vw_MoneySpentInVariousVenueTypes
As
Select V.VenueID, V.VenueName, Sum(CBAT.Cost) As MoneySpent
From tblCustomer C
		Join tblCust_Book CB On C.CustID = CB.CustID
		Join tblCust_Book_Act_Trip CBAT On CB.CustBookingID = CBAT.CustBookingID
		Join tblCust_Book_Exc_Trip CBET On CB.CustBookingID = CBET.CustBookingID
		Join tblActivity_Trip ACT On CBAT.ActivityTripID = ACT.ActivityTripID
		Join tblTrip T On ACT.TripID = T.TripID
		Join tblActivity A On ACT.ActivityID = A.ActivityID
		Join tblVenues V On A.VenueID = V.VenueID
		Join tblVenue_Type VT On V.VenueTypeID = VT.VenueTypeID
	Where VT.VenueTypeName = '%Restaraunt%'
		Or VT.VenueTypeName = '%Lounge%'
		Or VT.VenueTypeName Like '%Casino%'
		Or VT.VenueTypeName Like '%Deck%'
		And T.StartDate Between '2019-01-01' And '2020-12-01'
	Group By V.VenueID, V.VenueName
Go

Select * from mag_vw_MoneySpentInVariousVenueTypes


/*Select * from tblCUST_BOOK_EXC_TRIP
Select * from tblIncident
Select * from tblCountry
Select * from tblCUST_BOOK_ACT_TRIP
Select * from tblTrip
Select * from tblLOCATION
Select * from tblCountry*/
Select * from tblVENUE_TYPE
Select * from tblSTAFF_TRIP_POSITION
Select * from tblSTAFF
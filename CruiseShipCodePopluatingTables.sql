Use Cruise
Go

-- Populating tblVenues
Insert Into dbo.tblVENUES(VenueTypeID, CruiseshipID, VenueName, VenueDescr, Capacity)
	Select VenueTypeID, CruiseshipID, VenueName, VenueDescr, Capacity
	From magdanat_Test.dbo.tblVenues

Select * from tblCruiseShip
Select * from tblVenue_Type
Select * from tblVenues


--	Populating tblActivity
Select * from tblActivity_Type
Select * from tblActivity

Select * from tblACTIVITY_TRIP
Select * from tblCUST_BOOK_ACT_TRIP
Select * from tblCustomer
Select * from tblBooking
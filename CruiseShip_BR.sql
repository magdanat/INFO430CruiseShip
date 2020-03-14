Use Cruise Go
-- Business Rules
-- No more than the capacity for each ship
-- NO LONGER WORKS WITH CURRENT ERD
Create Function fNoMoreCapacity()
Returns Int
As
Begin
	Declare @Ret Int = 0
		If Exists (
			Select * from tblCRUISESHIP CS
				Join tblTRIP TP On CS.CruiseshipID = TP.CruiseshipID
				Join tblTRIP_CABIN TC On TP.TripID = TC.TripID
				Join tblBOOKING B On TC.TripCabinID = B.TripCabinID
				Join tblBOOKING_STATUS BS On B.BookStatusID = BS.BookStatusID
				Join tblCUST_BOOK CB On B.BookingID = CB.BookingID
			Where (Select Count(*) From tblCUST_BOOK) > CS.Capacity)
				And TC.TripID = CB.TripID
		Begin Set @Ret = 1
		End 
		Return @Ret
	End
Go

Alter Table tblCUST_BOOK_TRIP
Add Constraint CK_NoMoreCapacity
Check (dbo.fNoMoreCapacity() = 0)
Go

-- No more than the capacity of the activity
Create Function fNoMoreActivityCapacity()
Returns Int
As
Begin
	Declare @Ret Int = 0
		If Exists (Select * 
			From tblCUST_BOOK_ACT_TRIP CBAT
				Join tblACTIVITY_TRIP ACT On CBAT.ActivityTripID = ACT.ActivityTripID
				Join tblACTIVITY ATY On ACT.ActivityID = ATY.ActivityID
			Where (Select Count(*) From tblCUST_BOOK_ACT_TRIP) > ATY.Capacity)
		Begin Set @Ret = 1
		End
		Return @Ret
	End
Go

Alter Table tblCUST_BOOK_ACT_TRIP 
Add Constraint CK_NoMoreActivityCapacity
Check (dbo.fNoMoreActivityCapacity() = 0)
Go

Select * from tblCountry
Select * from tblACTIVITY_TYPE
Select * from tblVENUE_TYPE
Go

-- Business rule 
-- No free entertainment and shopping activities at certain venues
-- for trips that are in the USA
Create Function fNoFreeEntertainmentAndShoppingActivitiesAtVenues()
Returns Int
As 
Begin
	Declare @Ret Int = 0
		If Exists (Select *
			From tblActivity_Type ACT
				Join tblActivity A On ACT.ActivityTypeID = A.ActivityTypeID
				Join tblVenues V On A.VenueID = V.VenueID
				Join tblVenue_Type VT On V.VenueTypeID = VT.VenueTypeID
				Join tblCruiseship CS On V.CruiseshipID = CS.CruiseshipID
				Join tblRoute R On CS.RouteID = R.RouteID
				Join tblRoute_Location RL On R.RouteID = RL.RouteID
				Join tblLocation L On RL.LocationID = L.LocationID
				Join tblCountry C On L.CountryID = C.CountryID
			Where C.CountryName Like '%USA%'
				Or ACT.ActivityTypeName Like '%Entertainment%'
				Or ACT.ActivityTypeName Like '%Shopping%'
				Or VT.VenueTypeName Like '%Theatre%'
				Or VT.VenueTypeName Like '%Gift Shop%'
				And A.Cost > 0)
			Begin Set @Ret = 1
			End
			Return @Ret
		End
	Go

Alter Table tblActivity
Add Constraint CK_NoActivityLessThanZeroCost
Check (dbo.fNoFreeEntertainmentAndShoppingActivitiesAtVenues() = 0)
Go

-- Business Rule
-- No activities can be made longer than 4 hours for activities that are food and dining or celebrations
Create Function fNoActivitiesLongerThan4Hours()
Returns Int
As
Begin
	Declare @Ret Int = 0
		If Exists (Select *
			From tblActivity A
				Join tblActivity_Trip ACT On A.ActivityID = ACT.ActivityID
				Join tblActivity_Type ACTT On A.ActivityTypeID = ACTT.ActivityTypeID
				Join tblVenues V On A.VenueID = V.VenueID
				Join tblVenue_Type VT On V.VenueTypeID = VT.VenueTypeID
			Where ACT.StartTime < (Select DateAdd(Hour, -4, ACT.EndTime))
				Or ACTT.ActivityTypeName Like '%Food & Dining%'
				Or ACTT.ActivityTypeName Like '%Celebration%'
				And VT.VenueTypeName Like '%Deck%')
			Begin Set @Ret = 1
			End
			Return @Ret
		End
	Go

Alter Table tblActivity
Add Constraint CK_fNoActivitiesLongerTha4Hours
Check (dbo.fNoActivitiesLongerThan4Hours() = 0)
Go


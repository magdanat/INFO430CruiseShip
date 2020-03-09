-- Business Rules
-- No more than the capacity for each ship
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
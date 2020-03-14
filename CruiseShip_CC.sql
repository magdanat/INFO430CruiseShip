-- Computed Columns
-- Total Trip Cost for a Customer for Succesfully-Finished trips in the
-- past 10 years

-- Trip has to be in past 10 years
-- Succesfully Finished
-- Total Cost
Use Cruise 
Go

Create Function fTotalCostPastTenYears
(@PK Int)

Returns Numeric(8,2)
As
Begin
	Declare @Ret Numeric(8, 2)
	Set @Ret = (
		Select Sum(CBAT.Cost + ET.Cost) From tblCUST_BOOK_ACT_TRIP CBAT
			Join tblActivity_Trip ATT On CBAT.ActivityTripID = ATT.ActivityTripID
			Join tblActivity ACY On ATT.ActivityID = ACY.ActivityID
			Join tblTRIP T On ATT.TripID = T.TripID
			Join tblCUST_BOOK CB On CBAT.CustBookingID = CB.CustBookingID
			join tblCUST_BOOK_EXC_TRIP CBET On  CB.CustBookingID = CBET.CustBookingID
			Join tblEXCURSION_TRIP EXT on CBET.ExcursionTripID = EXT.ExcursionTripID
			Join tblExcursion ET On EXT.ExcursionID = ET.ExcursionID
			Join tblCUSTOMER C On CB.CustID = C.CustID
			Join tblBOOKING B On CB.BookingID = B.BookingID
			Join tblBOOKING_STATUS BS On B.BookStatusID = BS.BookStatusID
		Where T.StartDate >= (Select DateAdd(Year, -10, GetDate()))				
			And BS.BookStatusName = 'Valid'
			And T.EndDate <= (Select GetDate())
			And C.CustID = @PK)
	Return @Ret
End
Go

Alter Table tblCustomer
ADD TripCostRecent10Years As (dbo.fTotalCostPastTenYears(CustID))
Go

-- Total Number of Attendance for a Activity_Trip
Create Function fTotalAttendanceForActivity
(@PK Int)

Returns Int
As
Begin
	Declare @Ret Int
	Set @Ret = (
		Select Count(*) From tblCUST_BOOK_ACT_TRIP CBAT
			Join tblACTIVITY_TRIP ATP On CBAT.ActivityTripID = ATP.ActivityTripID
			Join tblTRIP T On ATP.TripID = T.TripID	
			Join tblCust_Book CB On CBAT.CustBookingID = CB.CustBookingID
			Join tblCustomer C On CB.CustID = C.CustID
			Join tblGender G On C.GenderID = G.GenderID
		Where ATP.ActivityTripID = @PK
		And CBAT.ActivityTripID = @PK
		And G.GenderName = 'Female')
	Return @Ret
End
Go

Alter Table tblActivity_Trip
Add TotalAttendanceForActivity As (dbo.fTotalAttendanceForActivity(ActivityID, TripID))
Go
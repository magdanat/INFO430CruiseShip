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
		Select Sum(CBT.Cost) From tblCUST_BOOK_TRIP CBT
			Join tblTRIP T On CBT.TripID = T.TripID
			Join tblCUST_BOOK CB On CBT.CustBookingID = CB.CustBookingID
			Join tblCUSTOMER C On CB.CustID = C.CustID
			Join tblBOOKING B On CB.BookingID = B.BookingID
			Join tblBOOKING_STATUS BS On B.BookStatusID = BS.BookStatusID
		Where T.StartDate >= (Select GetDate() - 365.25 * 10)
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
(@AK Int, @TK Int)

Returns Int
As
Begin
	Declare @Ret Int
	Set @Ret = (
		Select Count(*) From tblCUST_BOOK_ACT_TRIP CBAT
			Join tblACTIVITY_TRIP ATP On CBAT.ActivityTripID = ATP.ActivityTripID
			Join tblTRIP T On ATP.TripID = T.TripID	
		Where ATP.ActivityID = @AK
		And T.TripID = @TK)
	Return @Ret
End
Go

Alter Table tblActivity_Trip
Add TotalAttendanceForActivity As (dbo.fTotalAttendanceForActivity(ActivityID, TripID))
Go
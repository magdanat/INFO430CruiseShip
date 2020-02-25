-- Stored Procedures
Create Procedure mag_getExcursionID
@E_N varchar(50),
@C Int, --Capacity
@E_ID Int Output
As

Set @E_ID = (Select ExcursionID
 From tblEXCURSION
 Where ExcursionName = @E_N
 And Capacity = @C)
Go

Create Procedure mag_getTripID
@T_N varchar(50),
@S_D Datetime,
@E_D Datetime,
@T_ID Int Output
As

Set @T_ID = (Select TripID
From tblTRIP
Where TripName = @T_N
And StartDate = @S_D
And EndDate = @E_D)

Go

Create Procedure mag_getCustID
@C_F varchar(50),
@C_L varchar(50),
@DOB Datetime,
@C_ID Int Output

As

Set @C_ID = (Select CustID
From tblCUSTOMER
Where CustFname = @C_F
And CustLName = @C_L
And DateOfBirth = @DOB)

Go

Create Procedure mag_getBookingID
@B_N char(7),
@B_T Datetime,
@B_ID Int Output

As

Set @B_ID = (Select BookingID
From tblBOOKING
Where BookingNumber = @B_N
And BookingTime = @B_T)

Go

Create Procedure mag_getCust_BookID
@Book_N char(7),
@Book_T Datetime,
@Cust_F varchar(50),
@Cust_L varchar(50),
@Cust_DOB Datetime,
@CB_ID Int Output

As

Declare @Book_ID Int, @Cust_ID Int

Execute mag_getBookingID
@B_N = @Book_N,
@B_T = @Book_T,
@B_ID = @Book_ID Output
Execute mag_getCustID
@C_F = @Cust_F,
@C_L = @Cust_L,
@DOB = @Cust_DOB,
@C_ID = @Cust_ID Output

Set @CB_ID = (Select CustBookingID
From tblCUST_BOOK
Where CustID = @CustID
And BookingID = @Book_ID)

If  @CB_ID Is Null
Begin
Print '@CB_ID Is Null'
Raiserror ('Null is breaking get statement', 11, 1)
Return
End
Go

Create Procedure mag_getExcursionTripID
@T_Name varchar(50),
@S_T Datetime,
@E_T Datetime,
@Start_Date Datetime,
@End_Date Datetime,
@Ex_Name varchar(50),
@Cap Int,
@ExcursionTripID Int Output

As

Declare @Ex_ID Int, @Tr_ID Int

Execute mag_getTripID
@T_N = @T_Name,
@S_D = @Start_Date,
@E_D = @End_Date,
@T_ID = @Tr_ID Output
Execute mag_getExcursionID
@E_N = @Ex_Name,
@C = @Cap,
@E_ID = @Ex_ID Output

Set @ExcursionTripID = (Select ExcursionTripID
From tblEXCURSION_TRIP
Where StartTime = @S_T
And EndTime = @E_T
And TripID = @Tr_ID
And ExcrusionID = @Ex_ID)

If @ExcursionTripID Is Null
Begin
Print '@ExcursionTripID is null'
Raiserror ('Null is breaking get statement', 11, 1)
Return
End
Go

Create Procedure uspNew_Cust_Book_Act_Trip
@C Numeric(8,2), -- Cost
@R Datetime, -- Registime
@Tr_Name varchar(50), -- Trip name
@St_Time Datetime, -- Start time
@En_Time Datetime, -- End time
@E_Name varchar(50), -- Excursion name
@St_Date Datetime, -- StartDate
@En_Date Datetime, -- EndDate
@Capac Int, -- Capacity
@Book_Num char(7), -- Booking number
@Book_Time Datetime,  -- Booking time
@Cust_First varchar(50),
@Cust_Last varchar(50),
@Cust_Birth Datetime

As
	Declare @CustB_ID Int, @ExcurT_ID Int

	Execute mag_getCust_BookID
		@Book_N = @Book_Num,
		@Book_T = @Book_Time,
		@Cust_F = @Cust_First,
		@Cust_L = @Cust_Last,
		@Cust_DOB = @Cust_Birth,
		@CB_ID = @CustB_ID Output
	Execute mag_getExcursionTripID
		@T_Name = @Tr_Name,
		@S_T = @St_Time,
		@E_T = @En_Time,
		@Start_date = @St_Date,
		@End_Date = @En_Date,
		@Ex_Name = @E_Name,
		@Cap = @Capac,
		@ExcursionTripID = @ExcurT_ID Output

	Insert into tblCUST_BOOK_EXC_tRIP(Cost, RegistTime, ExcursionTripID, CustBookingID)
	Values (@C, @R, @ExcurT_ID, @CustB_ID)

Go

Create Procedure mag_uspNewActivity
@A_N varchar(50),
@A_D varchar(500),
@C int

As
	
	If @A_N Is Null
	Begin
		Print '@A_N is null'
		Raiserror ('Null is breaking insert statement', 11, 1)
		Return
	End

	If @C Is Null
	Begin
		Print 'C is null'
		Raiserror ('Null is breaking insert statement', 11, 1)
		Return
	End

	Insert Into tblACTIVITY(ActivityName, ActivityDescr, Capacity)
	Values (@A_N, @A_D, @C)
Go

-- Computed Columns
-- Total Trip Cost for a Customer for Succesfully-Finished trips in the
-- past 10 years

-- Trip has to be in past 10 years
-- Succesfully Finished
-- Total Cost


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
			Join tblBOOKING_STATUS BS On B.BookingStatusID = BS.BookingStatusID
		Where T.StartDate >= (Select GetDate() - 365.25 * 10)
			And BS.BookStatusName = 'Valid'
			And T.EndDate <= (Select GetDate()
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
			Join tblACTIVITY_TRIP ATP On CBAT.ActivityTripID = ATAP.ActivityTripID
			Join tblTRIP T On ATP.TripID = T.TripID	
		Where ATP.ActivityID = @AK
		And T.TripID = @TK)
	Return @Ret
End
Go

Alter Table ATP
Add TotalAttendanceForActivity As (dbo.fTotalAttendanceForActivity(ActivityID, TripID))
Go

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

-- Synthetic Transactions 

-- Business Rules
-- No more than the capacity for each ship
Create Function fNoMoreCapacity
(@TripID Int)
Returns Int
As
Begin
	Declare @Ret Int = 0
		If Exists (
			Select * from tblCRUISESHIP CS
				Join tblTRIP TP On CS.CruiseshipID = TP.CruiseshipID
				Join tblCUST_BOOK_TRIP CBT On TP.TripID = CBT.TripID
			Where (Select Count(*) From tblCUST_BOOK_TRIP Where TripID = @TripID) > CS.Capacity)
		Begin Set @Ret = 1
		End Return @Ret
	End
Go

Alter Table tblCUST_BOOK_TRIP
Add Constraint CK_NoMoreCapacity
Check (dbo.fNoMoreCapacity() = 0)
Go

-- No more than the capacity of the activity
Create Function fNoMoreActivityCapacity
(@TripID Int)

Returns Int
As
Begin
	Declare @Ret Int = 0
		If Exists (Select * 
			From tblCUST_BOOK_ACT_TRIP CBAT
				Join tblACTIVITY_TRIP ACT On CBAT.ActivityTripID = ACT.ActivityTripID
				Join tblACTIVITY ATY On ACT.ActivityID = ATY.ActivityID
			Where (Select Count(*) From tblCUST_BOOK_ACT_TRIP Where TripID = @TripID) > ATY.Capacity)
		Begin Set @Ret = 1
		End
		Return @Ret
	End
Go

Alter Table tblCUST_BOOK_ACT_TRIP 
Add Constraint CK_NoMoreActivityCapacity
Check (dbo.fNoMoreActivityCapacity() = 0)
Go
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
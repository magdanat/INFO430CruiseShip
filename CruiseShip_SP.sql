-- Stored Procedures
Alter Procedure mag_getActivityID
@A_N varchar(50),
@C	Int,
@A_ID Int Output
As

Set @A_ID = (Select ActivityID
			From tblACTIVITY
			Where ActivityName = @A_N
			And Capacity = @C)
Go

Alter Procedure mag_getTripID
@S_D Date,
@E_D Date,
@T_ID Int Output
As

Set @T_ID = (Select TripID
From tblTRIP
Where StartDate = @S_D
And EndDate = @E_D)

Go

Alter Procedure mag_getCustID
@C_F varchar(50),
@C_L varchar(50),
@DOB Date,
@C_ID Int Output

As

Set @C_ID = (Select CustID
From tblCUSTOMER
Where CustFname = @C_F
And CustLName = @C_L
And CustDOB = @DOB)

Go

Alter Procedure mag_getBookingID
@B_N char(7),
@B_T Datetime,
@B_ID Int Output
As

Set @B_ID = (Select BookingID
From tblBOOKING
Where BookingNumber = @B_N
And BookingTime = @B_T)

Go

Alter Procedure mag_getCust_BookID
@Book_N char(7),
@Book_T Datetime,
@Cust_F varchar(50),
@Cust_L varchar(50),
@Cust_DOB Date,
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
Where CustID = @Cust_ID
And BookingID = @Book_ID)
Go

Alter Procedure mag_getActivity_TripID
@S_T	Datetime,
@E_T	Datetime,
@Ac_Na	varchar(50),
@Ca		Int,
@St_D	Date,
@En_D	Date,
@AT_ID	Int Output
As

Declare @ACT_ID Int, @TR_ID Int

	Execute mag_getActivityID
		@A_N = @Ac_Na,
		@C = @Ca,
		@A_ID = @ACT_ID Output
	Execute mag_getTripID
		@S_D = @St_D,
		@E_D = @En_D,
		@T_ID = @TR_ID Output

	Set @AT_ID = (Select ActivityTripID
				 From tblACTIVITY_TRIP
				Where TripID = @TR_ID
				And ActivityID = @Act_ID
				And StartTime = @S_T
				And EndTime = @E_T)
Go

Alter Procedure uspNew_Cust_Book_Act_Trip
@C Numeric(8,2), -- Cost
@R Datetime, -- Registime
@St_Time Datetime, -- Start time
@En_Time Datetime, -- End time
@A_Name varchar(50), -- Activity name
@St_Date Datetime, -- StartDate
@En_Date Datetime, -- EndDate
@Capac Int, -- Capacity
@Book_Num char(7), -- Booking number
@Book_Time Datetime,  -- Booking time
@Cust_First varchar(50),
@Cust_Last varchar(50),
@Cust_Birth Date

As
	Declare @CustB_ID Int, @ACTR_ID Int

	Execute mag_getCust_BookID
		@Book_N = @Book_Num,
		@Book_T = @Book_Time,
		@Cust_F = @Cust_First,
		@Cust_L = @Cust_Last,
		@Cust_DOB = @Cust_Birth,
		@CB_ID = @CustB_ID Output

	If @CustB_ID Is Null
	Begin
		Print '@CustB_ID is Null'
		Raiserror('Null is breaking insert statement', 11, 1)
		Return
	End

	Execute mag_getActivity_TripID
		@S_T = @St_Time,
		@E_T = @En_Time,
		@St_D = @St_Date,
		@En_D = @En_Date,
		@Ac_Na = @A_Name,
		@Ca = @Capac,
		@AT_ID = @ACTR_ID Output

	If @ACTR_ID Is Null
	Begin
		Print '@ACTR_ID Is Null'
		Raiserror('Null is breaking insert statement', 11, 1)
		Return
	End

Begin Tran T1
	Insert into tblCUST_BOOK_ACT_TRIP(CustBookingID, ActivityTripID, Cost, RegisTime)
	Values (@CustB_ID, @ACTR_ID, @C, @R)
	If @@ERROR <> 0 
		Begin
			Rollback Tran T1
			End
		Else
			Commit Tran T1
Go

-- Stored Procedure 2
-- Inserting a new activity that a customer went on

-- Gets ID of a cruiseship
Alter Procedure mag_getCruiseShipID
@C_N varchar(50),
@Capac Int,
@M_D Datetime,
@C_ID Int Output
As

Set @C_ID = (Select CruiseshipID
			From tblCRUISESHIP
			Where CruiseshipName = @C_N
				And Capacity = @Capac
				And ManufacturedDate = @M_D)
Go

-- Stored procedure for getting the id value of a venue
Alter Procedure mag_getVenueID
@Cru_N varchar(50),
@Cru_C Int,
@Cru_MD Datetime,
@V_N varchar(50),
@V_Capac Int,
@V_ID Int Output
As

	Declare @Cruise_ID Int

	Execute mag_getCruiseShipID
		@C_N = @Cru_N,
		@Capac = @Cru_C,
		@M_D = @Cru_MD,
		@C_ID = @Cruise_ID Output

	Set @V_ID = (Select VenueID
				From tblVenues
				Where VenueName = @V_N
					And Capacity = @V_Capac
					And CruiseshipID = @Cruise_ID)
Go

-- Stored procedure for getting activitytype ID
Alter Procedure mag_getActivityTypeID
@AT_N varchar(50),
@AT_ID Int Output
As
	Set @AT_ID = (Select ActivityTypeID from tblACTIVITY_TYPE
				 Where ActivityTypeName = @AT_N)
Go

-- Stored procedure for inserting a new activity
Alter Procedure mag_uspNewActivity
@A_N varchar(50),
@A_D varchar(500),
@A_C Int,
@A_Cost Numeric(8,2),
@Act_Na varchar(50),
@Cruise_Na varchar(50),
@Cruise_Capac Int,
@Cruise_MaD	Datetime,
@Venue_Na	varchar(50),
@Venue_Capac Int
As
	
	Declare @ActTy_ID Int, @Venue_ID Int

	Execute  mag_getActivityTypeID
		@AT_N = @Act_Na,
		@AT_ID = @ActTy_ID Output

	If @ActTy_ID Is Null
	Begin
		Print '@ActTy_ID is Null'
		Raiserror('Null is breaking insert statement', 11, 1)
		Return
	End

	Execute mag_getVenueID
		@V_N = @Venue_Na,
		@V_Capac = @Venue_Capac,
		@Cru_N = @Cruise_Na,
		@Cru_C = @Cruise_Capac,
		@Cru_MD = @Cruise_Mad,
		@V_ID = @Venue_ID Output

	If @Venue_ID Is Null
	Begin
		Print '@Venue_ID Is Null'
		Raiserror('Null is breaking insert statement', 11, 1)
		Return
	End

	Begin Tran T1
		Insert Into tblACTIVITY(VenueID, ActivityTypeID, ActivityName, ActivityDescr, Capacity, Cost)
		Values (@Venue_ID, @ActTy_ID, @A_N, @A_D, @A_C, @A_Cost)
		If @@ERROR <> 0
			Begin
				Rollback Tran t1
			End
		Else
			Commit Tran T1
Go
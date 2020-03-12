-- This file contains the code for stored procedures

USE CRUISE
Go


-- Rayna Tilley

-- Stored Procedures
-- 1. Add new row in tblCUST_BOOK_EXC_TRIP
CREATE PROC cruise_NewRowCustBookExcTrip
@Cost numeric(8,2),
@RegisTime datetime,
@ExcStart datetime,
@ExcEnd datetime,
@CustFname varchar(50),
@CustLname varchar(50),
@CustDOB date,
@BookingNumber char(7),
@ExcursionStartTime datetime,
@ExcursionEndTime datetime,
@ExcursionName varchar(50),
@TripName varchar(50),
@TripStartDay date,
@TripEndDay date
AS
DECLARE @ExcursionTripID INT, @CustBookingID INT
EXEC cruise_GetCustBookingID
@Fname = @CustFname,
@Lname = @CustLname,
@DOB = @CustDOB,
@BookingNum = @BookingNumber,
@CB_ID = @CustBookingID OUTPUT
IF @CustBookingID IS NULL
BEGIN
	RAISERROR('@CustBookingID cannot be null.',11,1)
	RETURN
END
EXEC cruise_GetExcursionTripID
@STime = @ExcursionStartTime,
@ETime = @ExcursionEndTime,
@ExcName = @ExcursionName,
@TrName = @TripName,
@TripStart = @TripStartDay,
@TripEnd = @TripEndDay,
@ET_ID = @ExcursionTripID OUTPUT
IF @ExcursionTripID IS NULL
BEGIN
	RAISERROR('@ExcursionTripID cannot be null.',11,1)
	RETURN
END
BEGIN TRAN T1
INSERT INTO tblCUST_BOOK_EXC_TRIP(Cost, RegisTime, ExcursionTripID, CustBookingID)
VALUES(@Cost, @RegisTime, @ExcursionTripID, @CustBookingID)
IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN T1
	END
ELSE
	COMMIT TRAN T1
GO
-- 2. Get CustBookingID
CREATE PROC cruise_GetCustBookingID
@Fname varchar(50),
@Lname varchar(50),
@DOB date,
@BookingNum char(7),
@CB_ID INT OUTPUT
AS
DECLARE @CustID INT, @BookingID INT
EXEC cruise_GetCustID
@F = @Fname,
@L = @Lname, 
@B = @DOB,
@C_ID = @CustID OUTPUT
EXEC cruise_GetBookingID
@BNum = @BookingNum,
@B_ID = @BookingID OUTPUT
SET @CB_ID = (SELECT CustBookingID FROM tblCUST_BOOK
	WHERE CustID = @CustID
		AND BookingID = @BookingID)
GO
-- 3. Get CustID
CREATE PROC cruise_GetCustID
@F varchar(50),
@L varchar(50),
@B date,
@C_ID INT OUTPUT
AS
SET @C_ID = (SELECT CustID FROM tblCUSTOMER 
	WHERE CustFName = @F AND CustLname = @L AND CustDOB = @B)
GO
-- 4. GetBookingID
CREATE PROC cruise_GetBookingID
@BNum char(7),
@B_ID INT OUTPUT
AS
SET @B_ID = (SELECT BookingID FROM tblBOOKING
	WHERE BookingNumber = @BNum)
GO
-- 5. Get ExcursionID
CREATE PROC cruise_GetExcursionID
@EName varchar(50),
@E_ID INT OUTPUT
AS
SET @E_ID = (SELECT ExcursionID FROM tblEXCURSION WHERE ExcursionName = @EName)
GO
-- 6. Get TripID
CREATE PROC cruise_GetTripID
@TName varchar(50),
@Start date,
@End date,
@T_ID INT OUTPUT
AS
SET @T_ID = (SELECT TripID FROM tblTRIP
	WHERE TripName = @TName AND StartDate = @Start AND EndDate = @End)
GO
-- 7. Get ExcursionTripID
CREATE PROC cruise_GetExcursionTripID
@STime datetime,
@ETime datetime,
@ExcName varchar(50),
@TrName varchar(50),
@TripStart date,
@TripEnd date,
@ET_ID INT OUTPUT
AS
DECLARE @TripID INT, @ExcursionID INT
EXEC cruise_GetExcursionID
@EName = @ExcName,
@E_ID = @ExcursionID OUTPUT
EXEC cruise_GetTripID
@TName = @TrName,
@Start = @TripStart,
@End = @TripEnd,
@T_ID = @TripID OUTPUT
SET @ET_ID = (SELECT ExcursionTripID FROM tblEXCURSION_TRIP
	WHERE TripID = @TripID
		AND StartTime = @STime
		AND EndTime = @ETime
		AND ExcursionID = @ExcursionID)
GO

/* Doris ---- Stored Procedures */
/* SP: Get CustBookingID (Related to Synthetic transaction)*/
CREATE PROCEDURE getCustBookID
@CustFname VARCHAR(50),
@CustLname VARCHAR(50),
@CustDOB Date,
@BookingNum char(7),
@CustBookID INT OUTPUT
AS
    SET @CustBookID = (
        SELECT CustBookingID FROM tblCUST_BOOK CB
            JOIN tblCUSTOMER C ON CB.CustID = C.CustID
            JOIN tblBOOKING B ON CB.BookingID = B.BookingID
        WHERE C.CustFname = @CustFname
            AND C.CustLname = @CustLname
            AND C.CustDOB = @CustDOB
            AND B.BookingNumber = @BookingNum
        )
GO

/* SP: Get ExcursionTripID (Related to Synthetic transaction)*/
CREATE PROCEDURE getExcurTripID
@ShipName varchar(50),
@TripStartDate Date,
@TripEndDate Date,
@ExcurName varchar(225),
@ExcurTripStartTime Datetime,
@ExcurTripEndTime Datetime,
@ExcurTripID INT OUTPUT
AS
    SET @ExcurTripID = (
        SELECT ET.ExcursionTripID FROM tblTRIP T
            JOIN tblCRUISESHIP C ON T.CruiseshipID = C.CruiseshipID
            JOIN tblEXCURSION_TRIP ET on T.TripID = ET.TripID
            JOIN tblEXCURSION E ON ET.ExcursionID = E.ExcursionID
        WHERE C.CruiseshipName = @ShipName
            AND T.StartDate = @TripStartDate
            AND T.EndDate = @TripEndDate
            AND E.ExcursionName = @ExcurName
            AND ET.StartTime = @ExcurTripStartTime
            AND ET.EndTime = @ExcurTripEndTime
        )
GO


/* SP 1 (Related to Synthetic transaction)
    Add new row in tblCUST_BOOK_EXC_TRIP */
CREATE PROCEDURE sp_insertCUST_BOOK_EXC_TRIP
@CustomerFname VARCHAR(50),
@CustomerLname VARCHAR(50),
@CustomerDOB Date,
@BookingNumber char(7),
@CruiseshipName varchar(50),
@Trip_StartDate Date,
@Trip_EndDate Date,
@ExcursionName varchar(225),
@ExcursionTStartTime Datetime,
@ExcursionTEndTime Datetime,
@RegisterTime DateTime
AS
    DECLARE @CB_ID INT, @ET_ID INT
    EXEC getExcurTripID
    @ShipName = @CruiseshipName,
    @TripStartDate = @Trip_StartDate,
    @TripEndDate = @Trip_EndDate,
    @ExcurName = @ExcursionName,
    @ExcurTripStartTime = @ExcursionTStartTime,
    @ExcurTripEndTime = @ExcursionTEndTime,
    @ExcurTripID = @ET_ID OUTPUT

    IF @ET_ID IS NULL
    BEGIN
        PRINT '@ET_ID is null'
        RAISERROR ('@ET_ID cannot be NULL', 11 , 1)
        RETURN
    END

    EXEC getCustBookID
    @CustFname = @CustomerFname,
    @CustLname = @CustomerLname,
    @CustDOB = @CustomerDOB,
    @BookingNum = @BookingNumber,
    @CustBookID = @CB_ID OUTPUT

    IF @CB_ID IS NULL
    BEGIN
        PRINT '@CB_ID is null'
        RAISERROR ('@CB_ID cannot be NULL', 11 , 1)
        RETURN
    END

    BEGIN TRANSACTION T1
        INSERT INTO tblCUST_BOOK_EXC_TRIP(RegisTime, ExcursionTripID, CustBookingID)
        VALUES (@RegisterTime, @ET_ID, @CB_ID)

        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION T1
        END
        ELSE
            COMMIT TRANSACTION T1
GO

/* SP 2
   Create procedure to add rows into tblROUTE_LOCATION table for arrival and departure locations,
   using nested stored procedures */

-- Find LocationID
CREATE PROCEDURE findLocationID
@LocName VARCHAR(100),
@LocID INT OUTPUT
AS
    SET @LocID = (
        SELECT LocationID FROM tblLOCATION WHERE LocationName = @LocName
    )
GO

-- Find RouteID
CREATE PROCEDURE findRouteID
@RouteName VARCHAR(100),
@RouteID INT OUTPUT
AS
    SET @RouteID = (
        SELECT RouteID
        FROM tblROUTE WHERE RouteName = @RouteName
    )
GO


--insert
CREATE PROCEDURE insertRouteLocArrDep
@RouName VARCHAR(300),
@DepLoc VARCHAR(100),
@ArrLoc VARCHAR(100)

AS
    DECLARE @RouID INT, @DepLocID INT, @ArrLocID INT
    EXEC findRouteID
    @RouteName = @RouName,
    @RouteID = @RouID OUTPUT

    IF @RouID IS NULL
        BEGIN
            PRINT 'RouteID is null, no such excursion for this trip'
            RAISERROR ('@RouID must not be null', 11, 1)
            RETURN
        END


    EXEC findLocationID
@LocName = @DepLoc,
@LocID = @DepLocID OUTPUT

    IF @DepLocID IS NULL
        BEGIN
            PRINT 'DepLocID is null, no such excursion for this trip'
            RAISERROR ('@DepLocID must not be null', 11, 1)
            RETURN
        END

    EXEC findLocationID
    @LocName = @ArrLoc,
    @LocID = @ArrLocID OUTPUT

    IF @ArrLoc IS NULL
        BEGIN
            PRINT 'ArrLoc is null, no such excursion for this trip'
            RAISERROR ('@ArrLoc must not be null', 11, 1)
            RETURN
        END

    BEGIN TRAN T1
        INSERT INTO tblROUTE_LOCATION(RouteID, RouteLocTypeID, LocationID)
        VALUES(@RouID, (SELECT RouteLocTypeID FROM tblROUTE_LOCATION_TYPE WHERE RouteLocTypeName = 'Departure'), @DepLocID)

        INSERT INTO tblROUTE_LOCATION(RouteID, RouteLocTypeID, LocationID)
        VALUES(@RouID, (SELECT RouteLocTypeID FROM tblROUTE_LOCATION_TYPE WHERE RouteLocTypeName = 'Arrival'), @ArrLocID)

        IF @@ERROR <> 0
            BEGIN
                ROLLBACK TRAN T1
            END
        ELSE
            COMMIT TRAN T1
GO

-- Joey

/*1)Add new row in tblINCIDENT */

CREATE PROCEDURE GetIncidentID
@Inci_N VARCHAR(50),
@Inci_ST DATETIME
@Inci_ET DATETIME
@Inci_ID INT OUTPUT

AS

SET @Inci_ID = (SELECT IncidentID FROM tblINCIDENT
                WHERE IncidentName = @Inci_N
				AND IncidentStartTime = @Inci_ST
				AND IncidentEndTime = @Inci_ET)
GO

CREATE PROCEDURE GetIncidentTypeID
@ITName VARCHAR(50),
@IT_ID INT OUTPUT

AS

SET @IT_ID = (SELECT IncidentTypeID from tblINCIDENT_TYPE IT
                           JOIN tblINCIDENT I ON IT.IncidentTypeID = I.IncidentTypeID
						   WHERE IncidentTypeName = @ITName)
GO

CREATE PROCEDURE GetVenueID
@VName VARCHAR(50),
@C INT,--capacity
@V_ID INT OUTPUT

AS

SET @V_ID = (SELECT VenueID FROM tblVENUES V
              JOIN tblVenue_TypeID VT on VT.VenueTypeID = V.VenueTypeID
			  JOIN tblCRUISESHIP C ON C.CruiseshipID = V.CruiseshipID
			  WHERE VenueName = @VName
			  AND Capacity = @C)
GO



CREATE PROCEDURE INSERT_INCIDENT
@InciName VARCHAR(50),
@InciST DATETIME,
@InciET DATETIME,
@InciTypeName VARCHAR(50),


AS

DECLARE  @I_ID INT @IType_ID INT, @Ve_ID INT

EXEC getIncidentID
@Inci_N = @I_Name
@Inci_ST = @I_StartTime
@Inci_ET = @I_EndTime
@Inci_ID = @I_ID OUTPUT

IF @I_ID IS null,
    BEGIN
	    PRINT 'I_ID IS null'
		RAISERROR ('I_ID shouldnot be null',11,1)
		RETURN
	END

EXEC getIncidentTypeID
@ITName = @IT_N
@IT_ID = @IType_ID OUTPUT

IF @IType_ID IS null,
    BEGIN
	    PRINT 'IType_ID IS null'
		RAISERROR ('IType_ID shouldnot be null',11,1)
		RETURN
	END

EXEC getVenueID
@VName = @V_N
@C = @Capacity
@V_ID = @Ve_ID


IF @Ve_ID IS null,
    BEGIN
	    PRINT 'Ve_ID IS null'
		RAISERROR ('Ve_ID shouldnot be null',11,1)
		RETURN
	END

BEGIN TRAN T1
INSERT INTO tblINCIDENT(IncidentID,IncidentTypeID, VenueID, IncidentName, IncidentDescr, IncidentStartTime,IncidentEndTime)
VALUES (@I_ID, @IType_ID, @Ve_ID, @InciName, @InciST,@InciET)

IF @@ERROR <>0
    BEGIN
	   ROLLBACK TRAN T1
	END
ELSE
       COMMIT TRAN T1





/*2)Add new row in tblSTAFF_TRIP_POSITION with new staff but existing position */

CREATE PROCEDURE GetStaffID
@S_F VARCHAR(50),
@S_L VARCHAR(50),
@S_DOB DATE
@S_ID INT OUTPUT

AS

SET @S_ID = (SELECT StaffID FROM tblSTAFF
             WHERE StaffFname = @S_F
			 AND StaffLname = @S_L
			 AND StaffDOB = @S_DOB)
GO

CREATE PROCEDURE GetPositionID
@PosName VARCHAR(50),
@POS_ID INT OUTPUT

AS

SET @POS_ID = (SELECT PositionID FROM tblPOSITION
               WHERE PositionName = @PosName)
GO

CREATE PROCEDURE GetTripID
@T_N VARCHAR(50),
@S_D DATE,
@E_D DATE,
@T_ID INT OUTPUT

AS

SET @T_ID =(SELECT TripID FROM tblTRIP
            WHERE TripName = @T_N
			AND StartDate = @S_D
			AND EndDate = @E_D)
GO

CREATE PROCEDURE GetStaffTripPosition
@Sta_F VARCHAR(50),
@Sta_L VARCHAR(50),
@Sta_DOB DATE,
@T_Name VARCHAR(50),
@T_SD DATE,
@T_ED DATE,
@PName VARCHAR(50),
@STP_ID INT OUTPUT

AS

DECLARE @Staff_ID INT, @Position_ID INT, @Trip_ID INT,

EXEC GetStaffID
@S_F = @Sta_F
@S_L = @Sta_L
@S_DOB = @Sta_DOB
@S_ID = @Staff_ID OUTPUT

IF @Staff_ID IS NULL
   BEGIN
      PRINT 'Staff_ID is null'
	  RAISERROR ('Staff_ID should not be null', 11,0)
	  RETURN
   END


EXEC GetPositionID
@PosName = @PName
@POS_ID = @Position_ID OUTPUT

IF @Position_ID IS NULL
   BEGIN
      PRINT 'Position_ID is null'
	  RAISERROR ('Position_ID should not be null', 11,0)
	  RETURN
   END

EXEC GetTripID
@T_N = @T_Name
@S_D = @T_SD
@E_D = @T_ED
@T_ID = @Trip_ID OUTPUT

IF @Trip_ID IS NULL
   BEGIN
      PRINT 'Trip_ID is null'
	  RAISERROR ('Trip_ID should not be null', 11,0)
	  RETURN
   END



CREATE PROCEDURE uspNEW_STAFF_TRIP_POSITION
@Staff_F VARCHAR(50),
@Staff_L VARCHAR(50),
@Staff_DOB DATE,
@Position_N VARCHAR(50),
@Trip_N VARCHAR (50),
@Trip_SD DATE
@Trip_ED DATE

AS

DECLARE @STP_ID INT,

SET @STP_ID = (SELECT StaffTripPositionID FROM tblSTAFF_TRIP_POSITION
               WHERE StaffID = @Staff_ID
			   AND TripID = @Trip_ID
			   AND PositionID = @Position_ID)

IF @STP_ID IS NULL,
   BEGIN
   PRINT '@STP_ID is null'
   RAISERROR ('@STP_ID should not be null',11,1)
   RETURN
   END
GO

BEGIN TRAN T1

INSERT INTO tblSTAFF_TRIP_POSITION(StaffTripPosID, StaffID, TripID, PositionID)
VALUES (@STP_ID, @Staff_ID,@Trip_ID, @Position_ID)

IF @@ERROR <>0
    BEGIN
	   ROLLBACK TRAN T1
	END
ELSE
       COMMIT TRAN T1
GO

-- Nathan

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

Alter Procedure mag_getActivityTypeID
@AT_N varchar(50),
@AT_ID Int Output
As
	Set @AT_ID = (Select ActivityTypeID from tblACTIVITY_TYPE
				 Where ActivityTypeName = @AT_N)
Go

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
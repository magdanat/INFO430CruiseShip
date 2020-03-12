Use Cruise
Go

-- Nathan

Alter Procedure wrapper_Synthetic
@Run Int
As 

Declare @Cost Numeric(8,2) -- Cost
Declare @Registr_Time Datetime --Registime
Declare @Strt_Time Datetime -- Start Time
Declare @End_Time Datetime -- End Time
Declare @Activity_Name varchar(50)
Declare @Start_Date Date
Declare @End_Date	Date
Declare @Act_Capac	Int
Declare @Booking_Num char(7)
Declare @Booking_Time Datetime
Declare @Customer_Fn	varchar(50)
Declare @Customer_Ln	varchar(50)
Declare @Customer_Birthy Date

-- Row Counts for relevant tables customer, booking, excursion, trip
Declare @RowCustomerBookingCount Int = (Select Count(*) From tblCust_Book)
Declare @RowActivityTripCount Int = (Select Count(*) From tblActivity_Trip)

-- Random PK values to be determined
Declare @CB_PKID Int, @AT_PKID Int

While @Run > 0 
	Begin
		Set @CB_PKID = (Select Rand() * @RowCustomerBookingCount + 1)
		Print '@CB_PKID ='
		Print @CB_PKID
		Set @AT_PKID = (Select Rand() * @RowActivityTripCount + 1)
		Print '@AT_PKID ='
		Print @AT_PKID

		-- Customer Information
		Set @Customer_Fn = (Select C.CustFname From tblCustomer C
								Join tblCust_Book CB On C.CustID = CB.CustID
								Join tblBooking B On CB.BookingID = B.BookingID
							Where CB.CustBookingID = @CB_PKID)
		Print '@Customer_Fn = '
		Print @Customer_Fn
		Set @Customer_Ln = (Select C.CustLname From tblCustomer C
								Join tblCust_Book CB On C.CustID = CB.CustID
								Join tblBooking B On CB.BookingID = B.BookingID
							Where CB.CustBookingID = @CB_PKID)
		Print '@Customer_Ln'
		Print @Customer_Ln
		Set @Customer_Birthy = (Select C.CustDOB From tblCustomer C
								Join tblCust_Book CB On C.CustID = CB.CustID
								Join tblBooking B On CB.BookingID = B.BookingID
							Where CB.CustBookingID = @CB_PKID)
		Print '@Customer_Birthy = '
		Print @Customer_Birthy
		-- Booking Information
		Set @Booking_Num = (Select B.BookingNumber From tblBooking B
								Join tblCust_Book CB On B.BookingID = CB.BookingID
								Where CB.CustBookingID = @CB_PKID)
		Print '@Booking_Num = '
		Print @Booking_Num
		Set @Booking_Time = (Select B.BookingTime From tblBooking B
								Join tblCust_Book CB On B.BookingID = CB.BookingID
								Where CB.CustBookingID = @CB_PKID)

		-- Trip Information
		Set @Start_Date = (Select T.StartDate from tblTrip T
							Join tblActivity_Trip ACT On T.TripID = ACT.TripID
							Where ACT.ActivityTripID = @AT_PKID)
		Print '@Start_Date = '
		Print @Start_Date

		Set @End_Date = (Select T.EndDate from tblTrip T
							Join tblActivity_Trip ACT On T.TripID = ACT.TripID
							Where ACT.ActivityTripID = @AT_PKID)
		Print '@End_Date = '
		Print @End_Date

		-- Activity Information
		Set @Activity_Name = (Select AC.ActivityName from tblActivity AC
								Join tblActivity_Trip ACT On AC.ActivityID = ACT.ActivityID
								Where ACT.ActivityTripID = @AT_PKID)
		Print '@Activity_Name = '
		Print @Activity_Name

		Set @Act_Capac = (Select AC.Capacity from tblActivity AC
							Join tblActivity_Trip ACT On AC.ActivityID = ACT.ActivityID
							Where ACT.ActivityTripID = @AT_PKID)
		Print '@Act_Capac = '
		Print @Act_Capac

		Set @Strt_Time = (Select ACT.StartTime From tblActivity_Trip ACT
								Join tblActivity AC On ACT.ActivityID = AC.ActivityID
								Where ACT.ActivityTripID = @AT_PKID)
		Print '@Strt_Time = ' 
		Print @Strt_Time

		Set @End_Time = (Select ACT.EndTime From tblActivity_Trip ACT
								Join tblActivity AC on ACT.ActivityID = AC.ActivityID
								Where ACT.ActivityTripID = @AT_PKID)	
		Print '@End_Time = '
		Print @End_Time

		Set @Registr_Time = (@Booking_Time + FLOOR(RAND() * 10))
		Print '@Registr_Time = ' 
		Print @Registr_Time

		Set @Cost = (Select AC.Cost from tblActivity AC
						Join tblActivity_Trip ACT On AC.ActivityID = ACT.ActivityID
						Where ACT.ActivityTripID = @AT_PKID)
		Print '@Cost = ' 
		Print @Cost

		Execute uspNew_Cust_Book_Act_Trip
			@C = @Cost,
			@R = @Registr_Time,
			@St_Time = @Strt_Time,
			@En_Time = @End_Time,
			@A_Name = @Activity_Name,
			@St_Date = @Start_Date,
			@En_Date = @End_Date,
			@Capac = @Act_Capac,
			@Book_Num = @Booking_Num,
			@Book_Time = @Booking_Time,
			@Cust_First = @Customer_Fn,
			@Cust_Last = @Customer_Ln,
			@Cust_Birth = @Customer_Birthy

		Set @Run = @Run - 1
		Print @Run
	End

Execute wrapper_Synthetic
@Run = 1000
Go

-- Joey

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

CREATE PROCEDURE sp_insertCUST_BOOK
@CustomerFname VARCHAR(50),
@CustomerLname VARCHAR(50),
@CustomerDOB Date,
@BookingNumber char(7),

AS

DECLARE @CB_ID INT

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

        INSERT INTO tblCUST_BOOK(CustBookingID)---only one ID ?
        VALUES (@CB_ID)

        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION T1
        END
        ELSE
            COMMIT TRANSACTION T1
GO


CREATE PROCEDURE WRAPPER_Insert_CUST_BOOK
@RUN INT
AS
  DECLARE @RowCount_CID INT, @RowCount_BID INT, @RandPK_CID INT, @RandPK_BID INT
  SET @RowCount_CID = (SELECT COUNT(*) FROM tblCUST_BOOK)
  SET @RowCount_BID = (SELECT COUNT(*) FROM tblBOOKING)

WHILE @RUN > 0
BEGIN
  SET @RandPK_CID = (SELECT RAND() * @RowCount_CID + 1)
  SET @RandPK_BID = (SELECT RAND() * @RowCount_BID + 1)
 
  DECLARE @C_Fname VARCHAR(50), 
          @C_Lname VARCHAR(50), 
		  @C_DOB Date,
		  @B_Num DATE

        SET @C_Fname = (SELECT C.CustFname FROM tblCUSTOMER C
                            JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
						     WHERE CB.CustID = @RandPK_CID)
        SET @C_Lname = (SELECT C.CustLname FROM tblCUSTOMER C
                            JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID 
							WHERE CB.CustID = @RandPK_CID)
        SET @C_DOB = (SELECT C.CustDOB FROM tblCUSTOMER C
                            JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
                             WHERE CB.CustID = @RandPK_CID)
        SET @B_Num = (Select B.BookingNumber From tblBooking B
								Join tblCust_Book CB On B.BookingID = CB.BookingID
								Where CB.BookingID = @RandPK_BID)

	 EXEC Insert_CUST_BOOK
        @CustomerFname = @C_Fname,
        @CustomerLname = @C_Lname,
        @CustomerDOB = @C_DOB,
		@BookingNum = @B_Num
        SET @RUN = @RUN - 1
    END

-- Doris

/*
 WRAPPER tblCUST_BOOK_EXC_TRIP
 Populate tblCUST_BOOK_EXC_TRIP
 */

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

EXEC WRAPPER_Insert_CUST_BOOK
@RUN = 1000
GO

/*
 Wrapper sp_insertCUST_BOOK_EXC_TRIP
 */
CREATE PROCEDURE WRAPPER_insertCUST_BOOK_EXC_TRIP
@RUN INT
AS
    DECLARE @RowCount_ET INT, @RowCount_CB INT, @RandPK_ET INT, @RandPK_CB INT
    SET @RowCount_ET = (SELECT COUNT(*) FROM tblEXCURSION_TRIP)
    SET @RowCount_CB = (SELECT COUNT(*) FROM tblCUST_BOOK)

    DECLARE @C_Fname VARCHAR(50), @C_Lname VARCHAR(50), @C_DOB Date
    DECLARE @B_Number char(7), @C_Name varchar(50)
    DECLARE @T_StartDate Date, @T_EndDate Date, @E_Name varchar(225), @ET_StartTime Datetime, @ET_EndTime Datetime
    DECLARE @R_Time DateTime, @RandInt INT

    WHILE @RUN > 0
    BEGIN
        SET @RandPK_ET = (SELECT RAND() * @RowCount_ET + 1)
        SET @RandPK_CB = (SELECT RAND() * @RowCount_CB + 1)
        PRINT @RandPK_ET
        PRINT @RandPK_CB

        SET @C_Fname = (SELECT C.CustFname FROM tblCUSTOMER C
                            JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
                            JOIN tblBOOKING B ON CB.BookingID = B.BookingID
                        WHERE CB.CustBookingID = @RandPK_CB)
        SET @C_Lname = (SELECT C.CustLname FROM tblCUSTOMER C
                            JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
                            JOIN tblBOOKING B ON CB.BookingID = B.BookingID
                        WHERE CB.CustBookingID = @RandPK_CB)
        SET @C_DOB = (SELECT C.CustDOB FROM tblCUSTOMER C
                            JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
                            JOIN tblBOOKING B ON CB.BookingID = B.BookingID
                        WHERE CB.CustBookingID = @RandPK_CB)
        SET @B_Number = (SELECT B.BookingNumber FROM tblBOOKING B
                            JOIN tblCUST_BOOK CB ON B.BookingID = CB.BookingID
                        WHERE CB.CustBookingID = @RandPK_CB)
        SET @C_Name = (SELECT C.CruiseshipName FROM tblCRUISESHIP C
                            JOIN tblTRIP T ON C.CruiseshipID = T.CruiseshipID
                            JOIN tblEXCURSION_TRIP ET ON T.TripID = ET.TripID
                        WHERE ET.ExcursionTripID = @RandPK_ET)

        SET @T_StartDate = (SELECT T.StartDate FROM tblTRIP T
                                JOIN tblEXCURSION_TRIP ET on T.TripID = ET.TripID
                            WHERE ET.ExcursionTripID = @RandPK_ET)

        SET @T_EndDate = (SELECT T.EndDate FROM tblTRIP T
                                JOIN tblEXCURSION_TRIP ET on T.TripID = ET.TripID
                            WHERE ET.ExcursionTripID = @RandPK_ET)

        SET @E_Name = (SELECT E.ExcursionName FROM tblEXCURSION E
                            JOIN tblEXCURSION_TRIP ET ON E.ExcursionID = ET.ExcursionID
                       WHERE ET.ExcursionTripID = @RandPK_ET)
        SET @ET_StartTime = (SELECT ET.StartTime  FROM tblEXCURSION E
                                JOIN tblEXCURSION_TRIP ET ON E.ExcursionID = ET.ExcursionID
                            WHERE ET.ExcursionTripID = @RandPK_ET)

        SET @ET_EndTime = (SELECT ET.EndTime FROM tblEXCURSION E
                                JOIN tblEXCURSION_TRIP ET ON E.ExcursionID = ET.ExcursionID
                            WHERE ET.ExcursionTripID = @RandPK_ET)

        SET @RandInt = (SELECT FLOOR(RAND() * 10))
        SET @R_Time = ((SELECT B.BookingTime FROM tblBOOKING B
                            JOIN tblCUST_BOOK CB on B.BookingID = CB.BookingID
                        WHERE CB.CustBookingID = @RandPK_CB) + @RandInt * 365.25)

        EXEC sp_insertCUST_BOOK_EXC_TRIP
        @CustomerFname = @C_Fname,
    @CustomerLname = @C_Lname,
    @CustomerDOB = @C_DOB,
    @BookingNumber = @B_Number,
    @CruiseshipName = @C_Name,
    @Trip_StartDate = @T_StartDate,
    @Trip_EndDate = @T_EndDate,
    @ExcursionName = @E_Name,
    @ExcursionTStartTime = @ET_StartTime,
    @ExcursionTEndTime = @ET_EndTime,
    @RegisterTime = @R_Time

        SET @RUN = @RUN - 1
    END

EXEC WRAPPER_insertCUST_BOOK_EXC_TRIP
@RUN = 1000
GO
/* Doris ---- Stored Procedures */
USE CRUISE

/*1. Add a new tblBOOKING and a new tblCUST_BOOK with an existing customer */
CREATE PROCEDURE getCustID
@F VARCHAR(50),
@L VARCHAR(50),
@B DATE,
@CustID INT OUTPUT
AS
    SET @CustID = (
        SELECT CustID FROM tblCUSTOMER
            WHERE CustFname = @F
                AND CustLname = @L
                AND CustDOB = @B)
GO

-- getTripID
CREATE PROCEDURE getTripID
@CrName VARCHAR(50),
@TStart Date,
@TEnd Date,
@TID INT OUTPUT
AS
    DECLARE @Cr_ID INT = (SELECT CruiseshipID FROM tblCRUISESHIP WHERE CruiseshipName = @CrName)
    SET @TID = (
        SELECT TripID FROM tblTRIP
        WHERE CruiseshipID = @Cr_ID
            AND StartDate = @TStart
            AND EndDate = @TEnd
        )
GO
-- getTripCabinID
CREATE PROCEDURE getTripCabinID
@CSName VARCHAR(50),
@TripStartDay Date,
@TripEndDay Date,
@CabinNum INT,
@TCID INT OUTPUT
AS
    DECLARE @T_ID INT, @C_ID INT, @Cr_ID INT
    SET @Cr_ID = (SELECT CruiseshipID FROM tblCRUISESHIP WHERE CruiseshipName = @CSName)

    EXEC getTripID
    @CrName = @CSName,
        @TStart = @TripStartDay,
    @TEnd = @TripEndDay,
        @TID = @T_ID OUTPUT

    IF @T_ID IS NULL
    BEGIN
        PRINT 'No such trip in the system. Check again!'
        RAISERROR ('@T_ID must not be null', 11, 1)
        RETURN
    END

    SET @C_ID = (SELECT CabinID FROM tblCABIN
                WHERE CabinNum = @CabinNum
                    AND CruiseshipID = @Cr_ID)

    IF @C_ID IS NULL
    BEGIN
        PRINT 'No such Cabin in the system. Check again!'
        RAISERROR ('@C_ID must not be null', 11, 1)
        RETURN
    END

    SET @TCID = (
        SELECT TripCabinID FROM tblTRIP_CABIN
        WHERE TripID = @T_ID
        AND CabinID = @C_ID
        )
GO

-- Insert into tblBOOKING
CREATE PROCEDURE insertNewBOOKING
@CruiseShipName VARCHAR(50),
@TripStartTime  Date,
@TripEndTime Date,
@CabNum INT,
@BookingTime Datetime,
@BookingNumber Char(7)
AS
    DECLARE @TripCabinID INT
    EXEC getTripCabinID
    @CSName = @CruiseShipName,
@TripStartDay = @TripStartTime,
@TripEndDay = @TripEndTime,
@CabinNum = @CabNum,
@TCID = @TripCabinID OUTPUT

    BEGIN TRAN T1
        INSERT INTO tblBOOKING(BookingNumber, BookStatusID, TripCabinID, BookingTime)
        VALUES(@BookingNumber, (SELECT BookStatusID FROM tblBOOKING_STATUS WHERE BookStatusName = 'Valid'), @TripCabinID, @BookingTime)
        IF @@ERROR <> 0
            BEGIN
                ROLLBACK TRAN T1
            END
        ELSE
            COMMIT TRAN T1
GO

-- Insert into tblCUST_BOOK

CREATE PROCEDURE insertNewBookingCustForExistingCust
@Fname VARCHAR(50),
@Lname VARCHAR(50),
@BirthDate Date,
@CName VARCHAR(50),
@TStartTime  Date,
@TEndTime Date,
@CabinNumber INT,
@BTime Datetime,
@BNumber Char(7)
AS
    DECLARE @Cust_ID INT, @B_ID INT
    EXEC getCustID
@F = @Fname,
    @L = @Lname,
@B = @BirthDate,
        @CustID = @Cust_ID OUTPUT

    IF @Cust_ID IS NULL
        BEGIN
            PRINT 'No such customer in the system. Check again!'
            RAISERROR ('@Cust_ID must not be null', 11, 1)
            RETURN
        END

    EXEC insertNewBOOKING
@CruiseShipName = @CName,
@TripStartTime  = @TStartTime,
@TripEndTime = @TEndTime,
@CabNum = @CabinNumber,
@BookingTime = @BTime,
@BookingNumber = @BNumber

    SET @B_ID = SCOPE_IDENTITY()
    IF @B_ID IS NULL
    BEGIN
        PRINT 'No such booking in the system. Check again!'
        RAISERROR ('@B_ID must not be null', 11, 1)
        RETURN
    END

    BEGIN TRAN T2
    INSERT INTO tblCUST_BOOK(CustID, BookingID)
    VALUES(@Cust_ID, @B_ID)
    IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRAN T2
        END
    ELSE
        COMMIT TRAN T2
GO

/*
2. Add a new row in EXCURSION_TRIP with exisiting Trip and existing excursion (ExcursionName is unque)
 */

CREATE PROCEDURE insertExcurTrip
@CruiseShip_Name VARCHAR(50),
@Trip_Start_Time Date,
@Trip_End_Time Date,
@ExcName VARCHAR(225)
AS
    DECLARE @Ex_ID INT, @T_ID INT
    SET @Ex_ID = (SELECT ExcursionID FROM tblEXCURSION WHERE ExcursionName = @ExcName)

    IF @Ex_ID IS NULL
    BEGIN
        PRINT 'No such excursion in the system. Check again!'
        RAISERROR ('@Ex_ID must not be null', 11, 1)
        RETURN
    END

     EXEC getTripID
    @CrName = @CruiseShip_Name,
    @TStart = @Trip_Start_Time,
    @TEnd = @Trip_End_Time,
    @TID = @T_ID OUTPUT

    IF @T_ID IS NULL
    BEGIN
        PRINT 'No such Trip in the system. Check again!'
        RAISERROR ('@T_ID must not be null', 11, 1)
        RETURN
    END

    BEGIN TRAN T3
    INSERT INTO tblEXCURSION_TRIP(TripID, StartTime, EndTime, ExcursionID)
    VALUES(@T_ID, @Trip_Start_Time, @Trip_End_Time, @Ex_ID)
    IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRAN T3
    END
    ELSE
        COMMIT TRAN T3
GO



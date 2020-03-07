/* Doris ---- Stored Procedures */
USE CRUISE

/* SP 1
Get CustBookingID */
CREATE PROCEDURE getCustBookingID
@CustFname VARCHAR(50),
@CustLname VARCHAR(50),
@CustDOB Datetime,
@BookingNumber char(7),
@CustBookingID INT OUTPUT
AS
    DECLARE @BookingID INT, @CustID INT
    SET @CustID =
        (SELECT CustID FROM tblCUSTOMER
        WHERE CustFname = @CustFname
            AND CustLname = @CustLname
            AND CustDOB = @CustDOB)
    SET @BookingID = (SELECT BookingID FROM tblBOOKING
                        WHERE BookingNumber = @BookingNumber)
    SET @CustBookingID =
            (SELECT CustBookingID FROM tblCUST_BOOK
                WHERE CustID = @CustID
                AND BookingID = @BookingID)

/* SP 2
Add new row in tblCUST_BOOK_EXC_TRIP */
CREATE PROCEDURE insertCUST_BOOK_EXC_TRIP
@CustF VARCHAR(50),
@CustL VARCHAR(50),
@CustBD Datetime,
@BookingNum char(7),
@ExcN VARCHAR(50),
@TripN VARCHAR(50),
@RegisTime DATETIME,
@Cost NUMERIC(8,2)
AS
    DECLARE @CustBooking_ID INT, @ExcursionTrip_ID INT
    EXEC getCustBookingID
    @CustFname = @CustF,
    @CustLname = @CustL,
    @CustDOB = @CustBD,
    @BookingNumber = @BookingNum,
    @CustBookingID = @CustBooking_ID OUTPUT
    IF @CustBooking_ID IS NULL
    BEGIN
        PRINT 'CustBookingID is null, no such customer for this booking'
        RAISERROR ('@CustBooking_ID must not be null', 11, 1)
        RETURN
    END

    SET @ExcursionTrip_ID =
        (SELECT ExcursionTripID FROM tblEXCURSION_TRIP ET
            JOIN tblEXCURSION E ON ET.ExcursionID = E.ExcursionID
            JOIN tblTRIP T ON ET.TripID = T.TripID
        WHERE T. = @TripN
            AND E.ExcursionName = @ExcN)
    IF @ExcursionTrip_ID IS NULL
    BEGIN
        PRINT 'ExcursionTrip_ID is null, no such excursion for this trip'
        RAISERROR ('@ExcursionTripID must not be null', 11, 1)
        RETURN
    END

    BEGIN TRAN T1
    INSERT INTO tblCUST_BOOK_EXC_TRIP (Cost, RegisTime, ExcursionTripID, CustBookingID)
    VALUES(@Cost, @RegisTime, @ExcursionTrip_ID, @CustBooking_ID)
    IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRAN T1
        END
    ELSE
        COMMIT TRAN T1

/* Added, new SP
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
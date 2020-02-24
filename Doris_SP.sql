/* Doris ---- Stored Procedures */
/* SP 1
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
        WHERE T.TripName = @TripN
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

/* SP 2
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
            AND DateOfBirth = @CustDOB)
    SET @BookingID = (SELECT BookingID FROM tblBOOKING
                        WHERE BookingNumber = @BookingNumber)
    SET @CustBookingID =
            (SELECT CustBookingID FROM tblCUST_BOOK
                WHERE CustID = @CustID
                AND BookingID = @BookingID)

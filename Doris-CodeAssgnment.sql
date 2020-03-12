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

    IF @TripCabinID IS NULL
    BEGIN
        PRINT 'No such TripCabin in the system. Check again!'
        RAISERROR ('@TripCabinID must not be null', 11, 1)
        RETURN
    END

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

    SELECT * FROM tblEXCURSION_TRIP

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


/* Doris ---- Business Rules */
/* BR 1
Enforce the business rule to prevent adding a row into tblBAGGAGE if the cabin_type is ‘Interior’
   and the total baggage weight is already 50kg for a cruiseshipType to be 'Expedition Cruise Ship'
 */

SELECT * FROM tblCRUISESHIP_TYPE
USE CRUISE
CREATE FUNCTION no20kgBaggageForInteriorCabin()
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = 0
    IF EXISTS (
        SELECT * FROM tblBOOKING B
            JOIN tblBAGGAGE BA ON B.BookingID = BA.BookingID
            JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
            JOIN tblCABIN C ON TC.CabinID = C.CabinID
            JOIN tblCABIN_TYPE CT ON C.CabinTypeID = CT.CabinTypeID
            JOIN tblCRUISESHIP CR on C.CruiseshipID = CR.CruiseshipID
            JOIN tblCRUISESHIP_TYPE CST on CR.CruiseshipTypeID = CST.CruiseshipTypeID
        WHERE CT.CabinTypeName = 'Interior'
            AND CST.CruiseshipTypeName = 'Expedition Cruise Ship'
        GROUP BY B.BookingID
        HAVING SUM(BA.BaggageWeight) >= 50
        )
    BEGIN
        SET @RET = 1
    END
    RETURN @RET
END
GO

ALTER TABLE tblBAGGAGE
ADD CONSTRAINT CK_noMoreBaggageInteriorCabin
CHECK (dbo.no20kgBaggageForInteriorCabin() = 0)
GO

/* BR 2
Enforce the business rule to prevent new inserts into CUST_BOOK for if the customer is not older than 3 years old
   for an 'Expedition Cruise Ship' type */
CREATE FUNCTION noCustBookingForInfants()
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = 0
    IF EXISTS (
        SELECT * FROM tblBOOKING B
            JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
            JOIN tblTRIP T ON TC.TripID = T.TripID
            JOIN tblCRUISESHIP C ON T.CruiseshipID = C.CruiseshipID
            JOIN tblCRUISESHIP_TYPE CT ON C.CruiseshipTypeID = CT.CruiseshipTypeID
            JOIN tblCUST_Book CB ON B.BookingID = CB.BookingID
            JOIN tblCUSTOMER CUS ON CB.CustID = CUS.CustID
        WHERE DATEDIFF(year,  CUS.CustDOB, CAST(B.BookingTime AS DATE)) <= 3
            AND CT.CruiseshipTypeName = 'Expedition Cruise Ship'
        )
    BEGIN
        SET @RET = 1
    END
    RETURN @RET
END
GO

ALTER TABLE tblCUST_BOOK
ADD CONSTRAINT CK_noCustBookingForInfants
CHECK(dbo.noCustBookingForInfants() = 0)
GO



/* Doris ---- Computed Columns */
/* CC 1
Total excursion cost for a customer for successfully-finished(status  be 'Valid') trips in the past 10 years */
CREATE FUNCTION totalExcursionSpent10Years(@PK INT)
RETURNS NUMERIC(8,2)
AS
BEGIN
    DECLARE @RET NUMERIC(8,2)
    SET @RET = (
        SELECT SUM(E.Cost) FROM tblEXCURSION E
            JOIN tblEXCURSION_TRIP EXT ON E.ExcursionID = EXT.ExcursionID
            JOIN tblCUST_BOOK_EXC_TRIP CBET ON EXT.ExcursionTripID = CBET.ExcursionTripID
            JOIN tblCUST_BOOK CK ON CBET.CustBookingID = CK.CustBookingID
            JOIN tblCUSTOMER C ON CK.CustID = C.CustID
            JOIN tblBOOKING B ON CK.BookingID = B.BookingID
            JOIN tblBOOKING_STATUS BS ON BS.BookStatusID = B.BookStatusID
            JOIN tblTRIP T ON EXT.TripID = T.TripID
        WHERE BS.BookStatusName != 'Valid'
            AND T.StartDate >= (SELECT DATEADD(year, -10, (SELECT CONVERT(DATE, (Select GetDate())))))
            AND T.EndDate <= (SELECT CONVERT(DATE, (Select GetDate())))
            AND C.CustID = @PK)
    RETURN @RET
END

GO
ALTER TABLE tblCUSTOMER
ADD ExcursionSpentRecent10Years AS (dbo.totalExcursionSpent10Years(CustID))
GO

/* CC 2
Average number of passengers on board for each route within last 10 years */
CREATE FUNCTION averageNumPassengers(@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @Total INT, @TripCount INT, @RET INT
    SET @Total =
    (SELECT COUNT(DISTINCT CB.CustBookingID) FROM tblROUTE R
        JOIN tblCRUISESHIP C ON R.RouteID = C.RouteID
        JOIN tblTRIP T ON C.CruiseshipID = T.CruiseshipID
        JOIN tblTRIP_CABIN TC ON T.TripID = TC.TripID
        JOIN tblBOOKING B on TC.TripCabinID = B.TripCabinID
        JOIN tblBOOKING_STATUS BS ON B.BookStatusID = BS.BookStatusID
        JOIN tblCUST_BOOK CB ON B.BookingID = CB.BookingID
    WHERE BS.BookStatusName = 'Valid'
        AND T.StartDate <= (SELECT CONVERT(DATE, (Select GetDate())))
        AND T.EndDate <= (SELECT CONVERT(DATE, (Select GetDate())))
        AND T.EndDate >= (SELECT DATEADD(year, -10, (SELECT CONVERT(DATE, (Select GetDate())))))
        AND R.RouteID = @PK)

    SET @TripCount = (
        SELECT COUNT(DISTINCT T2.TripID) FROM tblROUTE R2
        JOIN tblCRUISESHIP C2 ON R2.RouteID = C2.RouteID
        JOIN tblTRIP T2 ON C2.CruiseshipID = T2.CruiseshipID
    WHERE T2.StartDate <= (SELECT CONVERT(DATE, (Select GetDate())))
        AND T2.EndDate <= (SELECT CONVERT(DATE, (Select GetDate())))
        AND T2.EndDate >= (SELECT DATEADD(year, -10, (SELECT CONVERT(DATE, (Select GetDate())))))
        AND R2.RouteID = @PK
        )
    IF(@TripCount = 0)
            SET @RET = 0
    ELSE
        SET @RET = (@Total / @TripCount)
    RETURN @RET
END
GO
ALTER TABLE tblROUTE
ADD averageNumPassengersRecent5Years AS (dbo.averageNumPassengers(RouteID))
GO


/* Doris ---- VIEWS */
/* V1
 Find the cruiseship that has the most valid booking in total, for which the 'BookingTime' is between 2010 and 2020
 for each Cruiseline using rank
 */
CREATE VIEW vw_validBooking AS
WITH CTE_ValidBookingCruiseship (CruiseshipID, CruiseshipName, CruiseLineID, numOfBooking, Dense_RankNumBooking)
AS
    (SELECT C.CruiseshipID, C.CruiseshipName, CRL.CruiseLineID, COUNT(DISTINCT B.BookingID) AS numOfBooking,
            DENSE_RANK() OVER (PARTITION BY CRL.CruiseLineID ORDER BY COUNT(DISTINCT B.BookingID) DESC)
                AS Dense_RankNumBooking
    FROM TBLCRUISELINE CRL
        JOIN tblCRUISESHIP C on CRL.CruiseLineID = C.CruiseLineID
        JOIN tblTRIP T ON C.CruiseshipID = T.CruiseshipID
        JOIN tblTRIP_CABIN TC on T.TripID = TC.TripID
        JOIN tblBOOKING B ON TC.TripCabinID = B.TripCabinID
        JOIN tblBOOKING_STATUS BS ON B.BookStatusID = BS.BookStatusID
    WHERE B.BookingTime BETWEEN '2010-01-01' AND '2020-12-31'
        AND BS.BookStatusName = 'Valid'
    GROUP BY C.CruiseshipID, C.CruiseshipName, CRL.CruiseLineID)

SELECT CruiseshipID, CruiseshipName, CruiseLineID, numOfBooking, Dense_RankNumBooking
FROM CTE_ValidBookingCruiseship
WHERE Dense_RankNumBooking = 1


/* V2
View all customers who have registered for more than 5 excursions within all trips he/she attended in next 10 years
   and who is also going to have more than 1 trip in next 10 years */

CREATE VIEW vw_ManyExcursions10Years_MoreThan1Trips10Years
AS
    SELECT C.CustFname, C.CustLname, subQ.NumTrip10Years,
                    COUNT(DISTINCT CBET.CustBookExcTripID) AS numExcursions10Years
    FROM tblTRIP T
        JOIN tblTRIP_CABIN TC ON T.TripID = TC.TripID
        JOIN tblBOOKING B ON TC.TripCabinID = B.TripCabinID
        JOIN tblBOOKING_STATUS BS ON B.BookStatusID = BS.BookStatusID
        JOIN tblCUST_BOOK CB ON B.BookingID = CB.BookingID
        JOIN tblCUSTOMER C ON CB.CustID = C.CustID
        JOIN tblCUST_BOOK_EXC_TRIP CBET on CB.CustBookingID = CBET.CustBookingID
        JOIN (
            SELECT COUNT(DISTINCT CB2.CustBookingID) AS NumTrip10Years, C2.CustID FROM tblTRIP T2
                JOIN tblTRIP_CABIN TC2 ON T2.TripID = TC2.TripID
                JOIN tblCABIN CA2 ON TC2.CabinID = CA2.CabinID
                JOIN tblCABIN_TYPE CT2 on CA2.CabinTypeID = CT2.CabinTypeID
                JOIN tblBOOKING B2 ON TC2.TripCabinID = B2.TripCabinID
                JOIN tblBOOKING_STATUS BS2 ON B2.BookStatusID = BS2.BookStatusID
                JOIN tblCUST_BOOK CB2 ON B2.BookingID = CB2.BookingID
                JOIN tblCUSTOMER C2 ON CB2.CustID = C2.CustID
            WHERE BS2.BookStatusName = 'Valid'
                AND T2.StartDate <= (SELECT DATEADD(year, 10, (SELECT CONVERT(DATE, (Select GetDate())))))
                AND T2.StartDate >= (SELECT CONVERT(DATE, (Select GetDate())))
            GROUP BY C2.CustID
            HAVING COUNT(DISTINCT CB2.CustBookingID) >= 2
        ) AS subQ ON subQ.CustID = C.CustID
    WHERE BS.BookStatusName = 'Valid'
        AND T.StartDate <= (SELECT DATEADD(year, 10, (SELECT CONVERT(DATE, (Select GetDate())))))
        AND T.StartDate >= (SELECT CONVERT(DATE, (Select GetDate())))
    GROUP BY C.CustFname, C.CustLname, subQ.NumTrip10Years
    HAVING COUNT(DISTINCT CBET.CustBookExcTripID) >= 5
GO
SELECT * FROM vw_ManyExcursions10Years_MoreThan1Trips10Years
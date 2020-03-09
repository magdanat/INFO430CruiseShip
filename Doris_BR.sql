/* Business Rules */
/* BR 1
Enforce the business rule to prevent adding a row into tblBAGGAGE if the cabin_type is ‘Interior’
   and the total baggage weight is already 50kg
 */
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
        WHERE CT.CabinTypeName = 'Interior'
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
        WHERE DATEDIFF()
              CUS.CustDOB > (B.BookingTime - 365.25 * 3)
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



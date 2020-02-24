/* Business Rules */
/* BR 1
Enforce the business rule to prevent adding more baggage to a booking if the cabin_type is ‘Interior’
   and the total baggage weight is 20kg
 */
CREATE FUNCTION no20kgBaggageForInteriorCabin()
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = 0
    IF EXISTS (
        SELECT * FROM tblBOOKING B
            JOIN tblBAGGAGE BA ON B.BookingID = BA.BaggageID
            JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
            JOIN tblCABIN C ON TC.CabinID = C.CabinID
            JOIN tblCABIN_TYPE CT ON C.CabinTypeID = CT.CabinTypeID
        WHERE CT.CabinTypeName = 'Interior'
        GROUP BY B.BookingID
        HAVING SUM(BA.BaggageWeight) >= 20
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
Enforce the business rule to prevent assigning new booking to a trip that has already started */
CREATE FUNCTION noBookingForStartedTrip()
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = 0
    IF EXISTS (
        SELECT * FROM tblBOOKING B
            JOIN tblTRIP_CABIN TC ON B.TripCabinID = TC.TripCabinID
            JOIN tblTRIP T ON TC.TripID = T.TripID
        WHERE T.StartDate > B.BookingTime
        )
    BEGIN
        SET @RET = 1
    END
    RETURN @RET
END
GO

ALTER TABLE tblBOOKING
ADD CONSTRAINT CK_noBookingStartedTrip
CHECK(dbo.noBookingForStartedTrip() = 0)
GO

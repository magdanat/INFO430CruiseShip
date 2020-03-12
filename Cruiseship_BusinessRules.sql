-- Business Rules
-- 1. Staff can only be assigned to one trip at a time. If a staff member is currently on
--	  a trip, they cannot be scheduled to join another trip.
-- Rayna

CREATE FUNCTION cruise_Staff_OneTripAtATime()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
		IF EXISTS(SELECT *
			FROM tbl)
		BEGIN
			SET @Ret = 1
		END
	RETURN @Ret
END
GO
ALTER TABLE tbl
ADD CONSTRAINT OneTripAtATime
CHECK(dbo.cruise_Staff_OneTripAtATime() = 0)
GO
-- 2. No more than the capacity for each cabin.

-- may need a while loop?
CREATE FUNCTION cruise_CabinCapacity()
RETURNS INT
AS
BEGIN
	DECLARE @Ret INT = 0
		IF EXISTS(SELECT *
			FROM tbl)
		BEGIN
			SET @Ret = 1
		END
	RETURN @Ret
END
GO
ALTER TABLE tbl
ADD CONSTRAINT OneTripAtATime
CHECK(dbo.cruise_CabinCapacity() = 0)
GO

-- Doris
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
DROP FUNCTION noCustBookingForInfants()
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


-- Joey

CREATE FUNCTION fn_noUnder21atBar()
RETURNS INT

AS

BEGIN 
 
    DECLARE @RET INT = 0
	   IF EXISTS(
	       SELECT * FROM tblVENUE V
		     JOIN tblVENUE_TYPE VT ON V.VenueTypeID = VT.VenueType.ID
		     JOIN tblCRUISESHIP C ON V.CruiseshipID = C.CruiseshipID
		     JOIN tblTRIP T ON C.CruiseshipID = T.CruiseshipID
		     JOIN tblTRIP_CABIN TC ON T.TripID = TC.TripID
		     JOIN tblBOOKING B ON TC.TripCabinID = B.TripCabinID
		     JOIN tblCUST_BOOK CB ON B.BookingID = CB.BookingID
		     JOIN tblCUSTOMER CUS ON CB.CustID = CUS.CustID
		   WHERE CUS.CustDOB >= (Select GetDate() - 365.25 * 21)
		     AND V.VenueTypeName = 'Bar'
			 )

    BEGIN
	   SET @RET = 1
	END
	RETURN @RET 
END

ALTER TABLE tblVenue
ADD CONSTRAINT ck_noUnder21atBar
CHECK(dbo.fn_noUnder21atBar()=0)


---When a trip has happened you can’t book it
CREATE FUNCTION fn_noBookingwhenTripStarts()
RETURNS INT

AS

BEGIN 
 
    DECLARE @RET INT = 0
	   IF EXISTS(
	       SELECT * FROM tblTRIP T
		      JOIN tblTRIP_CABIN TC ON T.TripID = TC.TripID
			  JOIN tblBOOKING B ON TC.TripCabinID = B.TripCabinID
		   WHERE T.StartDate > (Select GetDate() - B.BookingTime)
		   )
		Begin Set @Ret = 1
		End
		Return @Ret
 End
Go

Alter Table tblBooking 
Add Constraint CK_noBookingwhenTripStarts
Check (dbo.fn_noBookingwhenTripStarts() = 0)

GO

-- Nathan
-- No more than the capacity for each ship
Create Function fNoMoreCapacity()
Returns Int
As
Begin
	Declare @Ret Int = 0
		If Exists (
			Select * from tblCRUISESHIP CS
				Join tblTRIP TP On CS.CruiseshipID = TP.CruiseshipID
				Join tblTRIP_CABIN TC On TP.TripID = TC.TripID
				Join tblBOOKING B On TC.TripCabinID = B.TripCabinID
				Join tblBOOKING_STATUS BS On B.BookStatusID = BS.BookStatusID
				Join tblCUST_BOOK CB On B.BookingID = CB.BookingID
			Where (Select Count(*) From tblCUST_BOOK) > CS.Capacity)
				And TC.TripID = CB.TripID
		Begin Set @Ret = 1
		End 
		Return @Ret
	End
Go

Alter Table tblCUST_BOOK_TRIP
Add Constraint CK_NoMoreCapacity
Check (dbo.fNoMoreCapacity() = 0)
Go

-- No more than the capacity of the activity
Create Function fNoMoreActivityCapacity()
Returns Int
As
Begin
	Declare @Ret Int = 0
		If Exists (Select * 
			From tblCUST_BOOK_ACT_TRIP CBAT
				Join tblACTIVITY_TRIP ACT On CBAT.ActivityTripID = ACT.ActivityTripID
				Join tblACTIVITY ATY On ACT.ActivityID = ATY.ActivityID
			Where (Select Count(*) From tblCUST_BOOK_ACT_TRIP) > ATY.Capacity)
		Begin Set @Ret = 1
		End
		Return @Ret
	End
Go

Alter Table tblCUST_BOOK_ACT_TRIP 
Add Constraint CK_NoMoreActivityCapacity
Check (dbo.fNoMoreActivityCapacity() = 0)
Go

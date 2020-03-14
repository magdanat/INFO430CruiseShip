---No customer who is under 21 can attend entertainment takes place at venue_type ‘bar’.
USE CRUISE

CREATE FUNCTION fn_noUnder21atBar()
RETURNS INT

AS

BEGIN 
 
    DECLARE @RET INT = 0
	   IF EXISTS(
	       SELECT * FROM tblVENUES V
		     JOIN tblVENUE_TYPE VT ON V.VenueTypeID = VT.VenueTypeID
		     JOIN tblCRUISESHIP C ON V.CruiseshipID = C.CruiseshipID
		     JOIN tblTRIP T ON C.CruiseshipID = T.CruiseshipID
		     JOIN tblTRIP_CABIN TC ON T.TripID = TC.TripID
		     JOIN tblBOOKING B ON TC.TripCabinID = B.TripCabinID
		     JOIN tblCUST_BOOK CB ON B.BookingID = CB.BookingID
		     JOIN tblCUSTOMER CUS ON CB.CustID = CUS.CustID
		   WHERE CUS.CustDOB >= (Select GetDate() - 365.25 * 21)
		     AND V.VenueName = 'Bar'
			 )

    BEGIN
	   SET @RET = 1
	END
	RETURN @RET 
END

ALTER TABLE tblVENUES
ADD CONSTRAINT ck_noUnder21atBar
CHECK(dbo.fn_noUnder21atBar()=0)

GO

SELECT * FROM tblVENUES


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
		   WHERE T.StartDate > B.BookingTime
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

Use Cruise
Go

Select * from tblACTIVITY_TRIP
Select * from tblActivity
Select * from tblActivity_Type
Select * from tblVenues
Go

Create Procedure wrapper_Synthetic
@Run Int
As 

Declare @Cost Numeric(8,2)
Declare @Registr_Time Datetime
Declare @Strt_Time Datetime
Declare @End_Time Datetime
Declare @Activity_Name varchar(50)
Declare @Start_Date Datetime
Declare @End_Date	Datetime
Declare @Act_Capac	Int
Declare @Booking_Num Int
Declare @Booking_Time Datetime
Declare @Customer_Fn	varchar(50)
Declare @Customer_Ln	varchar(50)
Declare @Customer_Birthy	Datetime

-- Row Counts for relevant tables customer, booking, excursion, trip
Declare @RowCustomerBookingCount Int = (Select Count(*) From tblCust_Book)
Declare @RowActivityTripCount Int = (Select Count(*) From tblActivity_Trip)

-- Random PK values to be determined
Declare @CB_PKID Int, @AT_PKID Int

While @Run > 0 
	Begin
		Set @CB_PKID = (Select Rand() * @RowCustomerBookingCount + 1)
		Set @AT_PKID = (Select Rand() * @RowActivityTripCount + 1)

		-- Customer Information
		Set @Customer_Fn = (Select C.CustFname From tblCustomer C
								Join tblCust_Book CB On C.CustID = CB.CustID
								Join tblBooking B On CB.BookingID = B.BookingID
							Where CB.CustBookingID = @CB_PKID)

		Set @Customer_Ln = (Select C.CustLname From tblCustomer C
								Join tblCust_Book CB On C.CustID = CB.CustID
								Join tblBooking B On CB.BookingID = B.BookingID
							Where CB.CustBookingID = @CB_PKID)

		Set @Customer_Birthy = (Select C.CustDOB From tblCustomer C
								Join tblCust_Book CB On C.CustID = CB.CustID
								Join tblBooking B On CB.BookingID = B.BookingID
							Where CB.CustBookingID = @CB_PKID)

		-- Booking Information
		Set @Booking_Num = (Select B.BookingNumber From tblBooking B
								Join tblCust_Book CB On B.BookingID = CB.BookingID
								Where CB.BookingID = @CB_PKID)

		Set @Booking_Time = (Select B.BookingTime From tblBooking B
								Join tblCust_Book CB On B.BookingID = CB.BookingID
								Where CB.BookingID = @CB_PKID)

		-- Trip Information
		Set @Start_Date = (Select T.StartDate from tblTrip T
							Join tblActivity_Trip ACT On T.TripID = ACT.TripID
							Where ACT.ActivityTripID = @AT_PKID)

		Set @End_Date = (Select T.EndDate from tblTrip T
							Join tblActivity_Trip ACT On T.TripID = ACT.TripID
							Where ACT.ActivityTripID = @AT_PKID)

		-- Activity Information
		Set @Activity_Name = (Select AC.ActivityName from tblActivity AC
								Join tblActivity_Trip ACT On AC.ActivityID = ACT.ActivityID
								Where ACT.ActivityTripID = @AT_PKID)

		Set @Strt_Time = (Select ACT.StartTime From tblActivity_Trip ACT
								Join tblActivity AC On ACT.ActivityID = AC.ActivityID
								Where ACT.ActivityTripID = @AT_PKID)

		Set @End_Time = (Select ACT.EndTime From tblActivity_Trip ACT
								Join tblActivity AC on ACT.ActivityID = AC.ActivityID
								Where ACT.ActivityTripID = @AT_PKID)	

		Set @Registr_Time = ((Select B.BookingTime From tblBooking B) + Floor(Rand() *10))

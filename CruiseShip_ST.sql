Use Cruise
Go

/*Select * from tblACTIVITY_TRIP
Select * from tblActivity
Select * from tblActivity_Type
Select * from tblVenues
Go*/

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

		--Select * from tblCust_book Where CustBookingID = 2158
/*Select C.CustLname From tblCustomer C
								Join tblCust_Book CB On C.CustID = CB.CustID
								Join tblBooking B On CB.BookingID = B.BookingID
							Where CB.CustBookingID = 6897*/

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

/*Delete From tblCUST_BOOK_ACT_TRIP Where CustBookActTripID > 0
DBCC CheckIdent (tblCust_book_Act_Trip, Reseed, 0)

Select * from tblCUST_BOOK_ACT_TRIP

Select * from tblACTIVITY_TRIP*/
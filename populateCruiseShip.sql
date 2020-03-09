Alter Procedure insActivity_Trip
@Run Int
As
Declare @ActivityRowCount Int = (Select Count(*) From tblActivity)
Declare @TripRowCount Int  = (Select Count(*) From tblTrip)

Declare @Activity_PK Int
Declare @Trip_PK Int

Declare @ST Datetime  
Declare @SST Datetime
Declare @ET Datetime
Declare @EET Datetime

While @Run > 0
Begin



	Set @Activity_PK = (Select Rand() * @ActivityRowCount)
	Set @Trip_PK = (Select Rand() * @TripRowCount)

	Set @ST = (Select StartDate
			  From tblTrip
			  Where TripID = @Trip_PK)

	Set @SST = DateAdd(Hour, ABS(CheckSum(NewID()) % 12), @ST)

	Set @ET = DATEADD(Hour, ABS(CheckSum(NEWID()) % 12), @SST)

	Set @EET = DateAdd(Minute, 30, @ET)


	Insert Into tblActivity_Trip(ActivityID, TripID, StartTime, EndTime)
	Values (@Activity_PK, @Trip_PK, @SST, @EET)

Set @Run = @Run - 1
Print @Run
End


Execute insActivity_Trip
@Run = 1000

Select * from tblACTIVITY_TRIP

/*As

	


	Set @A_ID = (Select ActivityID
				From tblActivity
				Where */
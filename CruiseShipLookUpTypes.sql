Use CRUISESHIP
Go

Insert Into tblExcursion_Type(ExcursionTypeName)
Values ('General Sight-Seeing Tours'), ('Water Sports Shore Excursion'), ('Adventure Tours'),
	   ('Cuisine & Culture Tours'), ('Wildnerness & Wildlife')

Select * from tblExcursion_Type

Insert Into tblActivity_Type(ActivityTypeName)
Values ('Entertainment'), ('Food & Dining'), ('Enriching Activity'), ('Kids/Teens/Family'), ('Wellness'),
	   ('Celebration'), ('Shopping')

Select * from tblActivity_Type

Insert Into tblIncident_Type(IncidentTypeName)
Values ('Injury'), ('Property Damage'), ('Illness'), ('Emergency'), ('Environment')

Select * from tblIncident_Type

-- Need to define capacities
Insert Into tblVenue_Type(VenueTypeName)
Values ('Restaurant'), ('Gift Shop'), ('Sport Field'), ('Conference Room'), ('Theatre'), ('Bar'),
		('Lounge'), ('Deck'), ('Casino')

Insert Into tblBooking_Status(BookStatusName)
Values ('Valid'), ('Canceled')

Select * from tblBooking_Status

Insert Into tblRoute_Port_Type(RoutePortTypeName)
Values ('Departure'), ('Arrival'), ('Stop')

Select * from tblRoute_Port_Type

Insert Into tblGender(GenderName, GenderDescr)
Values ('Male', 'Male Human'), ('Female', 'Female Human'), ('Other', 'Other gender besides male and female')

Select * from tblGender

Insert Into tblPosition_Type(PositionTypeName, PositionTypeDescr)
Values ('Deck Department', 'In charge of keeping the ship running smoothly and on course'), ('Ship Maintenence Department', 'Handles maintenence of the ship'), ('Catering Department', 'Handles providing food services to all passengers in the ship'), ('Living Space Department', 'Cleaning cabins, doing laundry, and a wide range of other duties')

Select * from tblPosition_Type

-- Need to specify number of windows
Insert Into tblCabin_Type(CabinTypeName)
Values ('Interior'), ('Oceanview'), ('Balcony'), ('Minisuites'), ('Suites')

Insert Into tblCruiseShip_Type(CruiseshipTypeName)
Values ('Mega'), ('Ocean'), ('Luxury'), ('Small'), ('Mainstream'), ('Adventure')

Select * from tblCruiseShip_Type
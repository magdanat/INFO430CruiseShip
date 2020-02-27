-- USE master
-- USE CRUISE

-- tables
-- Table: tblACTIVITY
CREATE TABLE tblACTIVITY (
    ActivityID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    VenueID int  NOT NULL,
    ActivityTypeID int  NOT NULL,
    ActivityName varchar(50)  NOT NULL,
    ActivityDescr varchar(500)  NULL,
    Capacity int  NOT NULL
);

-- Table: tblACTIVITY_TRIP
CREATE TABLE tblACTIVITY_TRIP (
    ActivityTripID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    TripID int  NOT NULL,
    ActivityID int  NOT NULL,
    StartTime datetime  NOT NULL,
    EndTime datetime  NOT NULL
);

-- Table: tblACTIVITY_TYPE
CREATE TABLE tblACTIVITY_TYPE (
    ActivityTypeID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    ActivityTypeName varchar(50)  NOT NULL,
    ActivityTypeDescr varchar(500)  NULL
);

-- Table: tblBAGGAGE
CREATE TABLE tblBAGGAGE (
    BaggageID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    BookingID int  NOT NULL,
    BaggageWeight numeric(8,2)  NOT NULL,
    Quantity int  NOT NULL
);

-- Table: tblBOOKING
CREATE TABLE tblBOOKING (
    BookingID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    BookingNumber char(7)  NOT NULL,
    BookStatusID int  NOT NULL,
    TripCabinID int  NOT NULL,
    BookingTime datetime  NOT NULL
);

-- Table: tblBOOKING_STATUS
CREATE TABLE tblBOOKING_STATUS (
    BookStatusID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    BookStatusName varchar(50)  NOT NULL,
    BookStatusDescr varchar(500)  NULL
);

-- Table: tblCABIN
CREATE TABLE tblCABIN (
    CabinID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    CabinTypeID int  NOT NULL,
    CruiseshipID int  NOT NULL,
    CabinNum int  NOT NULL,
    FloorNum int  NOT NULL,
    CabinDescr varchar(500)  NULL
);

-- Table: tblCABIN_TYPE
CREATE TABLE tblCABIN_TYPE (
    CabinTypeID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    CabinTypeName varchar(50)  NOT NULL,
    CabinTypeDescr varchar(500)  NULL,
    Capacity int  NOT NULL,
    NumWindows int  NOT NULL
);

-- Table: tblCITY
CREATE TABLE tblCITY (
    CityID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    CountryID int  NOT NULL,
    CityName Varchar(50)  NOT NULL,
    CityDescr Varchar(500)  NULL,
);

-- Table: tblCOUNTRY
CREATE TABLE tblCOUNTRY (
    CountryID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    CountryName varchar(50)  NOT NULL,
    CountryDescr varchar(500)  NULL
);

-- Table: tblCRUISELINE
CREATE TABLE tblCRUISELINE (
    CruiseLineID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    CruiseLineName varchar(50)  NOT NULL,
    CruiseLineDescr varchar(500)  NULL
);

-- Table: tblCRUISESHIP
CREATE TABLE tblCRUISESHIP (
    CruiseshipID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    CruiseLineID int  NOT NULL,
    CruiseshipTypeID int  NOT NULL,
    RouteID int  NOT NULL,
    CruiseshipName varchar(50)  NOT NULL,
    CruiseshipDescr varchar(500)  NULL,
    Capacity int  NOT NULL,
    ManufacturedDate datetime  NOT NULL
);

-- Table: tblCRUISESHIP_TYPE
CREATE TABLE tblCRUISESHIP_TYPE (
    CruiseshipTypeID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    CruiseshipTypeName varchar(50)  NOT NULL,
    CruiseshipTypeDescr varchar(500)  NULL
);

-- Table: tblCUSTOMER
CREATE TABLE tblCUSTOMER (
    CustID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    GenderID int  NOT NULL,
    CustFname varchar(50)  NOT NULL,
    CustLname varchar(50)  NOT NULL,
    DateOfBirth datetime  NOT NULL
);

-- Table: tblCUST_BOOK
CREATE TABLE tblCUST_BOOK (
    CustBookingID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    CustID int  NOT NULL,
    BookingID int  NOT NULL
);

-- Table: tblCUST_BOOK_ACT_TRIP
CREATE TABLE tblCUST_BOOK_ACT_TRIP (
    CustBookActTripID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    CustBookingID int  NOT NULL,
    ActivityTripID int  NOT NULL,
    Cost numeric(8,2)  NOT NULL,
    RegisTime datetime  NOT NULL
);

-- Table: tblCUST_BOOK_EXC_TRIP
CREATE TABLE tblCUST_BOOK_EXC_TRIP (
    CustBookExcTripID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Cost numeric(8,2)  NOT NULL,
    RegisTime datetime  NOT NULL,
    ExcursionTripID int  NOT NULL,
    CustBookingID int  NOT NULL
);

-- Table: tblEXCURSION
CREATE TABLE tblEXCURSION (
    ExcursionID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    ExcursionTypeID int  NOT NULL,
    RoutePortID int  NOT NULL,
    ExcursionName varchar(50)  NOT NULL,
    ExcursionDescr varchar(500)  NOT NULL,
    Capacity int  NOT NULL
);

-- Table: tblEXCURSION_TRIP
CREATE TABLE tblEXCURSION_TRIP (
    ExcursionTripID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    TripID int  NOT NULL,
    StartTime datetime  NOT NULL,
    EndTime datetime  NOT NULL,
    ExcursionID int  NOT NULL
);

-- Table: tblEXCURSION_TYPE
CREATE TABLE tblEXCURSION_TYPE (
    ExcursionTypeID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    ExcursionTypeName varchar(50)  NOT NULL,
    ExcursionTypeDescr varchar(500)  NULL
);

-- Table: tblGENDER
CREATE TABLE tblGENDER (
    GenderID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    GenderName varchar(50)  NOT NULL,
    GenderDescr varchar(500)  NOT NULL
);

-- Table: tblINCIDENT
CREATE TABLE tblINCIDENT (
    IncidentID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    IncidentTypeID int  NOT NULL,
    VenueID int  NOT NULL,
    StaffTripPosID int  NOT NULL,
    IncidentName varchar(50)  NOT NULL,
    IncidentDescr varchar(500)  NULL,
    IncidentStartTime datetime  NOT NULL,
    IncidentEndTime datetime  NULL
);

-- Table: tblINCIDENT_TYPE
CREATE TABLE tblINCIDENT_TYPE (
    IncidentTypeID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    IncidentTypeName varchar(50)  NOT NULL,
    IncidentTypeDescr varchar(500)  NULL
);

-- Table: tblPORT
CREATE TABLE tblPORT (
    PortID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    CityID int  NOT NULL,
    PortName varchar(50)  NOT NULL,
    PortDescr varchar(500)  NULL
);

-- Table: tblPOSITION
CREATE TABLE tblPOSITION (
    PositionID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    PositionTypeID int  NOT NULL,
    PositionName varchar(50)  NOT NULL,
    PositionDescr varchar(500)  NOT NULL
);

-- Table: tblPOSITION_TYPE
CREATE TABLE tblPOSITION_TYPE (
    PositionTypeID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    PositionTypeName varchar(50)  NOT NULL,
    PositionTypeDescr varchar(500)  NOT NULL
);

-- Table: tblROUTE
CREATE TABLE tblROUTE (
    RouteID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    RouteName varchar(50)  NOT NULL,
    RouteDescr varchar(500)  NULL,
    TotalDays int  NOT NULL
);

-- Table: tblROUTE_PORT
CREATE TABLE tblROUTE_PORT (
    RoutePortID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    RouteID int  NOT NULL,
    PortID int  NOT NULL,
    RoutePortTypeID int  NOT NULL,
    NumOfDays int  NULL
);

-- Table: tblROUTE_PORT_TYPE
CREATE TABLE tblROUTE_PORT_TYPE (
    RoutePortTypeID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    RoutePortTypeName varchar(50)  NOT NULL,
    RoutePortTypeDescr varchar(500)  NULL
);

-- Table: tblSTAFF
CREATE TABLE tblSTAFF (
    StaffID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    StaffTypeID int  NOT NULL,
    CruiseLineID int  NOT NULL,
    GenderID int  NOT NULL,
    StaffFname varchar(50)  NOT NULL,
    StaffLname varchar(50)  NOT NULL,
    StaffDOB datetime  NOT NULL
);

-- Table: tblSTAFF_TRIP_POSITION
CREATE TABLE tblSTAFF_TRIP_POSITION (
    StaffTripPosID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    StaffTripID int  NOT NULL,
    StaffID int  NOT NULL,
    TripID int  NOT NULL,
    PositionID int  NOT NULL
);

-- Table: tblSTAFF_TYPE
CREATE TABLE tblSTAFF_TYPE (
    StaffTypeID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    StaffTypeName varchar(50)  NOT NULL,
    StaffTypeDescr varchar(500)  NULL
);

-- Table: tblTRIP
CREATE TABLE tblTRIP (
    TripID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    CruiseshipID int  NOT NULL,
    TripName varchar(50)  NOT NULL,
    TripDescr varchar(500)  NULL,
    StartDate datetime  NOT NULL,
    EndDate datetime  NOT NULL
);

-- Table: tblTRIP_CABIN
CREATE TABLE tblTRIP_CABIN (
    TripCabinID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    CabinID int  NOT NULL,
    TripID int  NOT NULL
);

-- Table: tblVENUES
CREATE TABLE tblVENUES (
    VenueID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    VenueTypeID int  NOT NULL,
    CruiseshipID int  NOT NULL,
    VenueName varchar(50)  NOT NULL,
    VenueDescr varchar(500)  NULL
);

-- Table: tblVENUE_TYPE
CREATE TABLE tblVENUE_TYPE (
    VenueTypeID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
    VenueTypeName varchar(50)  NOT NULL,
    VenueTypeDescr varchar(500)  NULL,
    Capacity int  NOT NULL
);

-- foreign keys
-- Reference: Baggage_tblBOOKING (table: tblBAGGAGE)
ALTER TABLE tblBAGGAGE ADD CONSTRAINT Baggage_tblBOOKING
    FOREIGN KEY (BookingID)
    REFERENCES tblBOOKING (BookingID);

-- Reference: tbVENUES_tblCRUISESHIP (table: tblVENUES)
ALTER TABLE tblVENUES ADD CONSTRAINT tbVENUES_tblCRUISESHIP
    FOREIGN KEY (CruiseshipID)
    REFERENCES tblCRUISESHIP (CruiseshipID);

-- Reference: tblACTIVITY_TRIP_tblACTIVITY (table: tblACTIVITY_TRIP)
ALTER TABLE tblACTIVITY_TRIP ADD CONSTRAINT tblACTIVITY_TRIP_tblACTIVITY
    FOREIGN KEY (ActivityID)
    REFERENCES tblACTIVITY (ActivityID);

-- Reference: tblACTIVITY_TRIP_tblTRIP (table: tblACTIVITY_TRIP)
ALTER TABLE tblACTIVITY_TRIP ADD CONSTRAINT tblACTIVITY_TRIP_tblTRIP
    FOREIGN KEY (TripID)
    REFERENCES tblTRIP (TripID);

-- Reference: tblBOOKING_tblBOOKING_STATUS (table: tblBOOKING)
ALTER TABLE tblBOOKING ADD CONSTRAINT tblBOOKING_tblBOOKING_STATUS
    FOREIGN KEY (BookStatusID)
    REFERENCES tblBOOKING_STATUS (BookStatusID);

-- Reference: tblBOOKING_tblTRIP_CABIN_BOOKING (table: tblBOOKING)
ALTER TABLE tblBOOKING ADD CONSTRAINT tblBOOKING_tblTRIP_CABIN_BOOKING
    FOREIGN KEY (TripCabinID)
    REFERENCES tblTRIP_CABIN (TripCabinID);

-- Reference: tblCABIN_tblCABIN_TYPE (table: tblCABIN)
ALTER TABLE tblCABIN ADD CONSTRAINT tblCABIN_tblCABIN_TYPE
    FOREIGN KEY (CabinTypeID)
    REFERENCES tblCABIN_TYPE (CabinTypeID);

-- Reference: tblCABIN_tblCRUISESHIP (table: tblCABIN)
ALTER TABLE tblCABIN ADD CONSTRAINT tblCABIN_tblCRUISESHIP
    FOREIGN KEY (CruiseshipID)
    REFERENCES tblCRUISESHIP (CruiseshipID);

-- Reference: tblCITY_tblCOUNTRY (table: tblCITY)
ALTER TABLE tblCITY ADD CONSTRAINT tblCITY_tblCOUNTRY
    FOREIGN KEY (CountryID)
    REFERENCES tblCOUNTRY (CountryID);

-- Reference: tblCRUISESHIP_tblCRUISELINE (table: tblCRUISESHIP)
ALTER TABLE tblCRUISESHIP ADD CONSTRAINT tblCRUISESHIP_tblCRUISELINE
    FOREIGN KEY (CruiseLineID)
    REFERENCES tblCRUISELINE (CruiseLineID);

-- Reference: tblCRUISESHIP_tblCRUISESHIP_TYPE (table: tblCRUISESHIP)
ALTER TABLE tblCRUISESHIP ADD CONSTRAINT tblCRUISESHIP_tblCRUISESHIP_TYPE
    FOREIGN KEY (CruiseshipTypeID)
    REFERENCES tblCRUISESHIP_TYPE (CruiseshipTypeID);

-- Reference: tblCRUISESHIP_tblROUTE (table: tblCRUISESHIP)
ALTER TABLE tblCRUISESHIP ADD CONSTRAINT tblCRUISESHIP_tblROUTE
    FOREIGN KEY (RouteID)
    REFERENCES tblROUTE (RouteID);

-- Reference: tblCUSTOMER_BOOKING_tblBOOKING (table: tblCUST_BOOK)
ALTER TABLE tblCUST_BOOK ADD CONSTRAINT tblCUSTOMER_BOOKING_tblBOOKING
    FOREIGN KEY (BookingID)
    REFERENCES tblBOOKING (BookingID);

-- Reference: tblCUSTOMER_BOOKING_tblCUSTOMER (table: tblCUST_BOOK)
ALTER TABLE tblCUST_BOOK ADD CONSTRAINT tblCUSTOMER_BOOKING_tblCUSTOMER
    FOREIGN KEY (CustID)
    REFERENCES tblCUSTOMER (CustID);

-- Reference: tblCUSTOMER_tblGENDER (table: tblCUSTOMER)
ALTER TABLE tblCUSTOMER ADD CONSTRAINT tblCUSTOMER_tblGENDER
    FOREIGN KEY (GenderID)
    REFERENCES tblGENDER (GenderID);

-- Reference: tblCUST_BOOK_ACT_TRIP_tblACTIVITY_TRIP (table: tblCUST_BOOK_ACT_TRIP)
ALTER TABLE tblCUST_BOOK_ACT_TRIP ADD CONSTRAINT tblCUST_BOOK_ACT_TRIP_tblACTIVITY_TRIP
    FOREIGN KEY (ActivityTripID)
    REFERENCES tblACTIVITY_TRIP (ActivityTripID);

-- Reference: tblCUST_BOOK_ACT_TRIP_tblCUST_BOOK (table: tblCUST_BOOK_ACT_TRIP)
ALTER TABLE tblCUST_BOOK_ACT_TRIP ADD CONSTRAINT tblCUST_BOOK_ACT_TRIP_tblCUST_BOOK
    FOREIGN KEY (CustBookingID)
    REFERENCES tblCUST_BOOK (CustBookingID);

-- Reference: tblCUST_BOOK_EXC_TRIP_tblCUST_BOOK (table: tblCUST_BOOK_EXC_TRIP)
ALTER TABLE tblCUST_BOOK_EXC_TRIP ADD CONSTRAINT tblCUST_BOOK_EXC_TRIP_tblCUST_BOOK
    FOREIGN KEY (CustBookingID)
    REFERENCES tblCUST_BOOK (CustBookingID);

-- Reference: tblCUST_BOOK_EXC_TRIP_tblEXCURSION_TRIP (table: tblCUST_BOOK_EXC_TRIP)
ALTER TABLE tblCUST_BOOK_EXC_TRIP ADD CONSTRAINT tblCUST_BOOK_EXC_TRIP_tblEXCURSION_TRIP
    FOREIGN KEY (ExcursionTripID)
    REFERENCES tblEXCURSION_TRIP (ExcursionTripID);

-- Reference: tblENTERTAINMENT_tblENTERTAINMENT_TYPE (table: tblACTIVITY)
ALTER TABLE tblACTIVITY ADD CONSTRAINT tblENTERTAINMENT_tblENTERTAINMENT_TYPE
    FOREIGN KEY (ActivityTypeID)
    REFERENCES tblACTIVITY_TYPE (ActivityTypeID);

-- Reference: tblENTERTAINMENT_tblPLACES (table: tblACTIVITY)
ALTER TABLE tblACTIVITY ADD CONSTRAINT tblENTERTAINMENT_tblPLACES
    FOREIGN KEY (VenueID)
    REFERENCES tblVENUES (VenueID);

-- Reference: tblEXCURSION_TRIP_tblEXCURSION (table: tblEXCURSION_TRIP)
ALTER TABLE tblEXCURSION_TRIP ADD CONSTRAINT tblEXCURSION_TRIP_tblEXCURSION
    FOREIGN KEY (ExcursionID)
    REFERENCES tblEXCURSION (ExcursionID);

-- Reference: tblEXCURSION_TRIP_tblTRIP (table: tblEXCURSION_TRIP)
ALTER TABLE tblEXCURSION_TRIP ADD CONSTRAINT tblEXCURSION_TRIP_tblTRIP
    FOREIGN KEY (TripID)
    REFERENCES tblTRIP (TripID);

-- Reference: tblEXCURSION_tblEXCURSION_TYPE (table: tblEXCURSION)
ALTER TABLE tblEXCURSION ADD CONSTRAINT tblEXCURSION_tblEXCURSION_TYPE
    FOREIGN KEY (ExcursionTypeID)
    REFERENCES tblEXCURSION_TYPE (ExcursionTypeID);

-- Reference: tblEXCURSION_tblROUTE_PORT (table: tblEXCURSION)
ALTER TABLE tblEXCURSION ADD CONSTRAINT tblEXCURSION_tblROUTE_PORT
    FOREIGN KEY (RoutePortID)
    REFERENCES tblROUTE_PORT (RoutePortID);

-- Reference: tblINCIDENT_tblINCIDENT_TYPE (table: tblINCIDENT)
ALTER TABLE tblINCIDENT ADD CONSTRAINT tblINCIDENT_tblINCIDENT_TYPE
    FOREIGN KEY (IncidentTypeID)
    REFERENCES tblINCIDENT_TYPE (IncidentTypeID);

-- Reference: tblINCIDENT_tblPLACES (table: tblINCIDENT)
ALTER TABLE tblINCIDENT ADD CONSTRAINT tblINCIDENT_tblPLACES
    FOREIGN KEY (VenueID)
    REFERENCES tblVENUES (VenueID);

-- Reference: tblINCIDENT_tblSTAFF_TRIP_POSITION (table: tblINCIDENT)
ALTER TABLE tblINCIDENT ADD CONSTRAINT tblINCIDENT_tblSTAFF_TRIP_POSITION
    FOREIGN KEY (StaffTripPosID)
    REFERENCES tblSTAFF_TRIP_POSITION (StaffTripPosID);

-- Reference: tblPLACES_tblPLACE_TYPE (table: tblVENUES)
ALTER TABLE tblVENUES ADD CONSTRAINT tblPLACES_tblPLACE_TYPE
    FOREIGN KEY (VenueTypeID)
    REFERENCES tblVENUE_TYPE (VenueTypeID);

-- Reference: tblPORT_tblCITY (table: tblPORT)
ALTER TABLE tblPORT ADD CONSTRAINT tblPORT_tblCITY
    FOREIGN KEY (CityID)
    REFERENCES tblCITY (CityID);

-- Reference: tblPOSITION_tblPOSITION_TYPE (table: tblPOSITION)
ALTER TABLE tblPOSITION ADD CONSTRAINT tblPOSITION_tblPOSITION_TYPE
    FOREIGN KEY (PositionTypeID)
    REFERENCES tblPOSITION_TYPE (PositionTypeID);

-- Reference: tblROUTE_PORT_tblPORT (table: tblROUTE_PORT)
ALTER TABLE tblROUTE_PORT ADD CONSTRAINT tblROUTE_PORT_tblPORT
    FOREIGN KEY (PortID)
    REFERENCES tblPORT (PortID);

-- Reference: tblROUTE_PORT_tblROUTE (table: tblROUTE_PORT)
ALTER TABLE tblROUTE_PORT ADD CONSTRAINT tblROUTE_PORT_tblROUTE
    FOREIGN KEY (RouteID)
    REFERENCES tblROUTE (RouteID);

-- Reference: tblROUTE_PORT_tblROUTE_PORT_TYPE (table: tblROUTE_PORT)
ALTER TABLE tblROUTE_PORT ADD CONSTRAINT tblROUTE_PORT_tblROUTE_PORT_TYPE
    FOREIGN KEY (RoutePortTypeID)
    REFERENCES tblROUTE_PORT_TYPE (RoutePortTypeID);

-- Reference: tblSTAFF_TRIP_tblPOSITION (table: tblSTAFF_TRIP_POSITION)
ALTER TABLE tblSTAFF_TRIP_POSITION ADD CONSTRAINT tblSTAFF_TRIP_tblPOSITION
    FOREIGN KEY (PositionID)
    REFERENCES tblPOSITION (PositionID);

-- Reference: tblSTAFF_TRIP_tblSTAFF (table: tblSTAFF_TRIP_POSITION)
ALTER TABLE tblSTAFF_TRIP_POSITION ADD CONSTRAINT tblSTAFF_TRIP_tblSTAFF
    FOREIGN KEY (StaffID)
    REFERENCES tblSTAFF (StaffID);

-- Reference: tblSTAFF_TRIP_tblTRIP (table: tblSTAFF_TRIP_POSITION)
ALTER TABLE tblSTAFF_TRIP_POSITION ADD CONSTRAINT tblSTAFF_TRIP_tblTRIP
    FOREIGN KEY (TripID)
    REFERENCES tblTRIP (TripID);

-- Reference: tblSTAFF_tblCRUISELINE (table: tblSTAFF)
ALTER TABLE tblSTAFF ADD CONSTRAINT tblSTAFF_tblCRUISELINE
    FOREIGN KEY (CruiseLineID)
    REFERENCES tblCRUISELINE (CruiseLineID);

-- Reference: tblSTAFF_tblGENDER (table: tblSTAFF)
ALTER TABLE tblSTAFF ADD CONSTRAINT tblSTAFF_tblGENDER
    FOREIGN KEY (GenderID)
    REFERENCES tblGENDER (GenderID);

-- Reference: tblSTAFF_tblSTAFF_TYPE (table: tblSTAFF)
ALTER TABLE tblSTAFF ADD CONSTRAINT tblSTAFF_tblSTAFF_TYPE
    FOREIGN KEY (StaffTypeID)
    REFERENCES tblSTAFF_TYPE (StaffTypeID);

-- Reference: tblTRIP_CABIN_tblCABIN (table: tblTRIP_CABIN)
ALTER TABLE tblTRIP_CABIN ADD CONSTRAINT tblTRIP_CABIN_tblCABIN
    FOREIGN KEY (CabinID)
    REFERENCES tblCABIN (CabinID);

-- Reference: tblTRIP_CABIN_tblTRIP (table: tblTRIP_CABIN)
ALTER TABLE tblTRIP_CABIN ADD CONSTRAINT tblTRIP_CABIN_tblTRIP
    FOREIGN KEY (TripID)
    REFERENCES tblTRIP (TripID);

-- Reference: tblTRIP_tblCRUISESHIP (table: tblTRIP)
ALTER TABLE tblTRIP ADD CONSTRAINT tblTRIP_tblCRUISESHIP
    FOREIGN KEY (CruiseshipID)
    REFERENCES tblCRUISESHIP (CruiseshipID);



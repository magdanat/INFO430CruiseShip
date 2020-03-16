USE CRUISE

/*1)Add new row in tblINCIDENT */

CREATE PROCEDURE GetIncidentTypeID
@ITName VARCHAR(50),
@ITID INT OUTPUT

AS

SET @ITID = (SELECT IncidentTypeID from tblINCIDENT_TYPE IT
                           WHERE IncidentTypeName = @ITName)
GO

CREATE PROCEDURE GetVenueID
@VName VARCHAR(50),
@C INT,--capacity
@VID INT OUTPUT

AS

SELECT * FROM tblVENUES
SET @VID = (SELECT VenueID FROM tblVENUES V
              JOIN tblVenue_Type VT on VT.VenueTypeID = V.VenueTypeID
			  WHERE VenueName = @VName
			  AND Capacity = @C)
GO


CREATE PROCEDURE INSERT_INCIDENT
@I_Name VARCHAR(50),
@I_ST DATETIME,
@I_ET DATETIME,
@I_TName VARCHAR(50),
@V_Name VARCHAR(50)


AS

DECLARE  @IT_ID INT, @V_ID INT


EXEC getIncidentTypeID
@ITName = @I_Name,
@ITID = @IT_ID OUTPUT

IF @IT_ID IS null
    BEGIN
	    PRINT 'IT_ID IS null'
		RAISERROR ('IT_ID shouldnot be null',11,1)
		RETURN
	END

EXEC getVenueID
@VName = @V_Name,
@C = @Capacity,
@VID = @V_ID


IF @V_ID IS null,
    BEGIN
	    PRINT 'V_ID IS null'
		RAISERROR ('V_ID shouldnot be null',11,1)
		RETURN
	END

BEGIN TRAN T1
INSERT INTO tblINCIDENT(IncidentTypeID, VenueID, IncidentName, IncidentStartTime,IncidentEndTime)
VALUES (@IT_ID, @V_ID, @I_Name, @I_ST,@I_ET)

IF @@ERROR <>0
    BEGIN
	   ROLLBACK TRAN T1
	END
ELSE
       COMMIT TRAN T1

/*2)Add new row in tblSTAFF_TRIP_POSITION with new staff but existing position */

CREATE PROCEDURE GetStaffID
@S_F VARCHAR(50),
@S_L VARCHAR(50),
@S_DOB DATE
@S_ID INT OUTPUT

AS

SET @S_ID = (SELECT StaffID FROM tblSTAFF
             WHERE StaffFname = @S_F
			 AND StaffLname = @S_L
			 AND StaffDOB = @S_DOB)
GO

CREATE PROCEDURE GetPositionID
@PosName VARCHAR(50),
@POS_ID INT OUTPUT

AS

SET @POS_ID = (SELECT PositionID FROM tblPOSITION
               WHERE PositionName = @PosName)
GO

CREATE PROCEDURE GetTripID
@ShipName varchar(50),
@S_D DATE,
@E_D DATE,
@T_ID INT OUTPUT

AS

SET @T_ID =(SELECT TripID FROM tblTRIP
            WHERE CruiseshipID = (SELECT CruiseshipID FROM tblCRUISESHIP WHERE CruiseshipName = @ShipName)
			AND StartDate = @S_D
			AND EndDate = @E_D)
GO

CREATE PROCEDURE GetStaffTripPosition
@Sta_F VARCHAR(50),
@Sta_L VARCHAR(50),
@Sta_DOB DATE,
@S_Name VARCHAR(50),
@T_SD DATE,
@T_ED DATE,
@PName VARCHAR(50),
@STP_ID INT OUTPUT

AS

DECLARE @Staff_ID INT, @Position_ID INT, @Trip_ID INT,

EXEC GetStaffID
@S_F = @Sta_F,
@S_L = @Sta_L,
@S_DOB = @Sta_DOB,
@S_ID = @Staff_ID OUTPUT

IF @Staff_ID IS NULL
   BEGIN
      PRINT 'Staff_ID is null'
	  RAISERROR ('Staff_ID should not be null', 11,0)
	  RETURN
   END


EXEC GetPositionID
@PosName = @PName,
@POS_ID = @Position_ID OUTPUT

SET @Position_ID = SCOPE_IDENTITY()
IF @Position_ID IS NULL
   BEGIN
      PRINT 'Position_ID is null'
	  RAISERROR ('Position_ID should not be null', 11,0)
	  RETURN
   END

EXEC GetTripID
@ShipName = @S_Name,
@S_D = @T_SD,
@E_D = @T_ED,
@T_ID = @Trip_ID OUTPUT

IF @Trip_ID IS NULL
   BEGIN
      PRINT 'Trip_ID is null'
	  RAISERROR ('Trip_ID should not be null', 11,0)
	  RETURN
   END



CREATE PROCEDURE uspNEW_STAFF_TRIP_POSITION
@Staff_F VARCHAR(50),
@Staff_L VARCHAR(50),
@Staff_DOB DATE,
@Position_N VARCHAR(50),
@Trip_N VARCHAR (50),
@Trip_SD DATE,
@Trip_ED DATE

AS

DECLARE @STP_ID INT

SET @STP_ID = (SELECT StaffTripPositionID FROM tblSTAFF_TRIP_POSITION
               WHERE StaffID = @Staff_ID
			   AND TripID = @Trip_ID
			   AND PositionID = @Position_ID)

IF @STP_ID IS NULL
   BEGIN
   PRINT '@STP_ID is null'
   RAISERROR ('@STP_ID should not be null',11,1)
   RETURN
   END
GO

BEGIN TRAN T1

INSERT INTO tblSTAFF_TRIP_POSITION(StaffID, TripID, PositionID)
VALUES (@Staff_ID,@Trip_ID, @Position_ID)

IF @@ERROR <>0
    BEGIN
	   ROLLBACK TRAN T1
	END
ELSE
       COMMIT TRAN T1

USE CRUISE

/*1)Add new row in tblINCIDENT */

CREATE PROCEDURE GetIncidentID
@Inci_N VARCHAR(50),
@Inci_ST DATETIME
@Inci_ET DATETIME
@Inci_ID INT OUTPUT

AS

SET @Inci_ID = (SELECT IncidentID FROM tblINCIDENT
                WHERE IncidentName = @Inci_N
				AND IncidentStartTime = @Inci_ST
				AND IncidentEndTime = @Inci_ET)
GO

CREATE PROCEDURE GetIncidentTypeID
@ITName VARCHAR(50),
@IT_ID INT OUTPUT

AS

SET @IT_ID = (SELECT IncidentTypeID from tblINCIDENT_TYPE IT
                           JOIN tblINCIDENT I ON IT.IncidentTypeID = I.IncidentTypeID
						   WHERE IncidentTypeName = @ITName)
GO

CREATE PROCEDURE GetVenueID
@VName VARCHAR(50),
@C INT,--capacity
@V_ID INT OUTPUT

AS

SET @V_ID = (SELECT VenueID FROM tblVENUES V
              JOIN tblVenue_TypeID VT on VT.VenueTypeID = V.VenueTypeID
			  JOIN tblCRUISESHIP C ON C.CruiseshipID = V.CruiseshipID
			  WHERE VenueName = @VName
			  AND Capacity = @C)
GO



CREATE PROCEDURE INSERT_INCIDENT
@InciName VARCHAR(50),
@InciST DATETIME,
@InciET DATETIME,
@InciTypeName VARCHAR(50),


AS

DECLARE  @I_ID INT @IType_ID INT, @Ve_ID INT

EXEC getIncidentID
@Inci_N = @I_Name
@Inci_ST = @I_StartTime
@Inci_ET = @I_EndTime
@Inci_ID = @I_ID OUTPUT

IF @I_ID IS null,
    BEGIN
	    PRINT 'I_ID IS null'
		RAISERROR ('I_ID shouldnot be null',11,1)
		RETURN
	END

EXEC getIncidentTypeID
@ITName = @IT_N
@IT_ID = @IType_ID OUTPUT

IF @IType_ID IS null,
    BEGIN
	    PRINT 'IType_ID IS null'
		RAISERROR ('IType_ID shouldnot be null',11,1)
		RETURN
	END

EXEC getVenueID
@VName = @V_N
@C = @Capacity
@V_ID = @Ve_ID


IF @Ve_ID IS null,
    BEGIN
	    PRINT 'Ve_ID IS null'
		RAISERROR ('Ve_ID shouldnot be null',11,1)
		RETURN
	END

BEGIN TRAN T1
INSERT INTO tblINCIDENT(IncidentID,IncidentTypeID, VenueID, IncidentName, IncidentDescr, IncidentStartTime,IncidentEndTime)
VALUES (@I_ID, @IType_ID, @Ve_ID, @InciName, @InciST,@InciET)

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
@T_N VARCHAR(50),
@S_D DATE,
@E_D DATE,
@T_ID INT OUTPUT

AS

SET @T_ID =(SELECT TripID FROM tblTRIP
            WHERE TripName = @T_N
			AND StartDate = @S_D
			AND EndDate = @E_D)
GO

CREATE PROCEDURE GetStaffTripPosition
@Sta_F VARCHAR(50),
@Sta_L VARCHAR(50),
@Sta_DOB DATE,
@T_Name VARCHAR(50),
@T_SD DATE,
@T_ED DATE,
@PName VARCHAR(50),
@STP_ID INT OUTPUT

AS

DECLARE @Staff_ID INT, @Position_ID INT, @Trip_ID INT,

EXEC GetStaffID
@S_F = @Sta_F
@S_L = @Sta_L
@S_DOB = @Sta_DOB
@S_ID = @Staff_ID OUTPUT

IF @Staff_ID IS NULL
   BEGIN
      PRINT 'Staff_ID is null'
	  RAISERROR ('Staff_ID should not be null', 11,0)
	  RETURN
   END


EXEC GetPositionID
@PosName = @PName
@POS_ID = @Position_ID OUTPUT

IF @Position_ID IS NULL
   BEGIN
      PRINT 'Position_ID is null'
	  RAISERROR ('Position_ID should not be null', 11,0)
	  RETURN
   END

EXEC GetTripID
@T_N = @T_Name
@S_D = @T_SD
@E_D = @T_ED
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
@Trip_SD DATE
@Trip_ED DATE

AS

DECLARE @STP_ID INT,

SET @STP_ID = (SELECT StaffTripPositionID FROM tblSTAFF_TRIP_POSITION
               WHERE StaffID = @Staff_ID
			   AND TripID = @Trip_ID
			   AND PositionID = @Position_ID)

IF @STP_ID IS NULL,
   BEGIN
   PRINT '@STP_ID is null'
   RAISERROR ('@STP_ID should not be null',11,1)
   RETURN
   END
GO

BEGIN TRAN T1

INSERT INTO tblSTAFF_TRIP_POSITION(StaffTripPosID, StaffID, TripID, PositionID)
VALUES (@STP_ID, @Staff_ID,@Trip_ID, @Position_ID)

IF @@ERROR <>0
    BEGIN
	   ROLLBACK TRAN T1
	END
ELSE
       COMMIT TRAN T1













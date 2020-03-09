
---tblCUST_BOOK (With new Booking)
USE CRUISE

CREATE PROCEDURE getCustBookID

@CustFname VARCHAR(50),
@CustLname VARCHAR(50),
@CustDOB Date,
@BookingNum char(7),
@CustBookID INT OUTPUT
AS
    SET @CustBookID = (
        SELECT CustBookingID FROM tblCUST_BOOK CB
            JOIN tblCUSTOMER C ON CB.CustID = C.CustID
            JOIN tblBOOKING B ON CB.BookingID = B.BookingID
        WHERE C.CustFname = @CustFname
            AND C.CustLname = @CustLname
            AND C.CustDOB = @CustDOB
            AND B.BookingNumber = @BookingNum
        )
GO

CREATE PROCEDURE sp_insertCUST_BOOK
@CustomerFname VARCHAR(50),
@CustomerLname VARCHAR(50),
@CustomerDOB Date,
@BookingNumber char(7),

AS

DECLARE @CB_ID INT

EXEC getCustBookID
    @CustFname = @CustomerFname,
    @CustLname = @CustomerLname,
    @CustDOB = @CustomerDOB,
    @BookingNum = @BookingNumber,
    @CustBookID = @CB_ID OUTPUT

    IF @CB_ID IS NULL
    BEGIN
        PRINT '@CB_ID is null'
        RAISERROR ('@CB_ID cannot be NULL', 11 , 1)
        RETURN
    END

BEGIN TRANSACTION T1

        INSERT INTO tblCUST_BOOK(CustBookingID)---only one ID ?
        VALUES (@CB_ID)

        IF @@ERROR <> 0
        BEGIN
            ROLLBACK TRANSACTION T1
        END
        ELSE
            COMMIT TRANSACTION T1
GO


CREATE PROCEDURE WRAPPER_Insert_CUST_BOOK
@RUN INT
AS
  DECLARE @RowCount_CID INT, @RowCount_BID INT, @RandPK_CID INT, @RandPK_BID INT
  SET @RowCount_CID = (SELECT COUNT(*) FROM tblCUST_BOOK)
  SET @RowCount_BID = (SELECT COUNT(*) FROM tblBOOKING)

WHILE @RUN > 0
BEGIN
  SET @RandPK_CID = (SELECT RAND() * @RowCount_CID + 1)
  SET @RandPK_BID = (SELECT RAND() * @RowCount_BID + 1)
 
  DECLARE @C_Fname VARCHAR(50), 
          @C_Lname VARCHAR(50), 
		  @C_DOB Date,
		  @B_Num DATE

        SET @C_Fname = (SELECT C.CustFname FROM tblCUSTOMER C
                            JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
						     WHERE CB.CustID = @RandPK_CID)
        SET @C_Lname = (SELECT C.CustLname FROM tblCUSTOMER C
                            JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID 
							WHERE CB.CustID = @RandPK_CID)
        SET @C_DOB = (SELECT C.CustDOB FROM tblCUSTOMER C
                            JOIN tblCUST_BOOK CB ON C.CustID = CB.CustID
                             WHERE CB.CustID = @RandPK_CID)
        SET @B_Num = (Select B.BookingNumber From tblBooking B
								Join tblCust_Book CB On B.BookingID = CB.BookingID
								Where CB.BookingID = @RandPK_BID)

	 EXEC Insert_CUST_BOOK
        @CustomerFname = @C_Fname,
        @CustomerLname = @C_Lname,
        @CustomerDOB = @C_DOB,
		@BookingNum = @B_Num
        SET @RUN = @RUN - 1
    END

EXEC WRAPPER_Insert_CUST_BOOK
@RUN = 1000
GO
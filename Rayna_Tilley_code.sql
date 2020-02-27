-- Rayna Tilley
-- Cruiseship Code

-- Business Rules
-- 1. Staff can only be assigned to one trip at a time. If a staff member is currently on
--	  a trip, they cannot be scheduled to join another trip.

-- may need a while loop?
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
	RETURNS @Ret
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
	RETURNS @Ret
END
GO
ALTER TABLE tbl
ADD CONSTRAINT OneTripAtATime
CHECK(dbo.cruise_CabinCapacity() = 0)
GO

-- Stored Procedures
-- 1. Add new row in tblCUST_BOOK_EXC_TRIP


-- 2. Get CustBookingID


-- Computed Columns
-- 1. Number of incidents for each trip


-- 2. How many people are on a trip (Check CUST_BOOK status)


-- Views
-- 1. View the top 10 curiseships that have the most trips within 5 years


-- 2. View top 100 customers who have spent the most on
--`   all excursions and activities in last 5 years

-- Synthetic Transactions
-- 1. tblCUST_BOOK_ACT_TRIP


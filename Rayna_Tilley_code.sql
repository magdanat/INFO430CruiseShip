-- Rayna Tilley
-- Cruiseship Code

-- Business Rules
-- 1. Staff can only be assigned to one trip at a time. If a staff member is currently on
--	  a trip, they cannot be scheduled to join another trip.
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
-- Rayna Tilley
-- Populating Cruiseship ERD/DB

USE CRUISE

INSERT INTO tblVENUE_TYPE(VenueTypeName, VenueTypeDescr)
VALUES('Restaurant', null),
('Gift Shop', null),
('Sport Field', null),
('Conference Room', null),
('Theatre', null),
('Bar', null),
('Lounge', null),
('Deck', null),
('Casino', null)
GO

INSERT INTO tblINCIDENT_TYPE(IncidentTypeName, IncidentTypeDescr)
VALUES('Injury', null),
('Property Damage', null),
('Illness', null),
('Emergency', null),
('Environment', null)
GO
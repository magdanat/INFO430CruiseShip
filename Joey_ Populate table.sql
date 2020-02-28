USE CRUISE

SET IDENTITY_INSERT tblCABIN_TYPE ON
INSERT INTO tblCABIN_TYPE(CabinTypeID,CabinTypeName, CabinTypeDescr,Capacity,NumWindows)
VALUES (001,'Interior','Inside cabins are the smallest on the ship and are the least expensive cabins. Located in the interior of the ship, these cabins do not have windows, although you might be able to look at the view on the cabin’s television.', 2,4),
(002,'Oceanview', ' Oceanview cabins contain all of the features of inside cabins, but also include a porthole, picture window or floor-to-ceiling windows, depending on the category and deck level.',4,6),
(003,'Balcony','Balcony cabins feature a private balcony off your cabin. These cabins are the next level up in price from the oceanview cabins and are usually a little larger. ',6,10),
(004,'Mini-Suites','While “suite” in this case doesn’t mean two separate rooms, you’ll most likely have a curtain or other means to separate the living area from the sleeping area. In addition to a couch and chairs, you can expect a slightly larger balcony and a tub/shower combination rather than just a shower.',8,8),
(005,'Suites','Suites range from basic two-room suites to large, luxurious multi-roomed spaces with your own hot tub. Suites are the most expensive accommodations on the ship, but feature many amenities for the money. In additional to the extra space, suites feature extra-large balconies complete with lounge chairs.',10,10)
SET IDENTITY_INSERT tblCABIN_TYPE OFF


SELECT * FROM tblCABIN_TYPE

SET IDENTITY_INSERT tblROUTE_PORT_TYPE ON
INSERT INTO tblROUTE_PORT_TYPE(RoutePortTypeID,RoutePortTypeName,RoutePortTypeDescr)
VALUES ( 1,'Departure','leave for a destination'),(2,'Arrival','come to a destination'),(3,'stop','no move')
SET IDENTITY_INSERT tblROUTE_PORT_TYPE OFF

SELECT * FROM tblROUTE_PORT_TYPE

SET IDENTITY_INSERT tblACTIVITY_TYPE ON
INSERT INTO tblACTIVITY_TYPE(ActivityTypeID,ActivityTypeName,ActivityTypeDescr)
VALUES (1, 'Entertainment','Funtime'),(2,'Food & Dining','a place serves moderately priced food in a casual atmosphere'),
(3,'Enriching Activity','A place that designed to provide opportunities for character development, personal growth and team building.') ,
(4,'Kids/Teens/Family','Activities related to kids, teenagers and family recreations'),
(5,'Wellness','good places to exercises'),
(6,'Celebration','decent places to celebrate different kinds of moments in life.'),
(7,'Shopping','goods bought from stores, especially food and household goods.')

SELECT * FROM tblACTIVITY_TYPE



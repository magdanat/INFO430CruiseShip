/*
Write first as single, stand-alone queries. Follow this up by writing as a single query with subqueries. Finally, write as CTE.

Write the SQL to determine the colleges that offered at least 350 classes during the 1960's in buildings on Steven's Way

that also...

offered no more than 175 classes on West Campus during the 2000's

that also...

have had at least 45 500-level classes after 2007 on the Quad.
*/
Use University
Go


SELECT C.CollegeID, C.CollegeName, NumClasses2000sWestCampus, NumGradClassesAfter2007Quad, COUNT(*) AS NumClasses1960sStevensWay
	FROM tblCOLLEGE C
	JOIN tblDEPARTMENT D ON C.CollegeID = D.CollegeID
	JOIN tblCOURSE CR ON D.DeptID = CR.DeptID
	JOIN tblCLASS CS ON CR.CourseID = CS.CourseID
	JOIN tblCLASSROOM CM ON CS.ClassroomID = CM.ClassroomID
	JOIN tblBUILDING B ON CM.BuildingID = B.BuildingID
	JOIN tblLOCATION L ON B.LocationID = L.LocationID

	JOIN
	(SELECT C.CollegeID, CollegeName, COUNT(*) AS NumClasses2000sWestCampus
		FROM tblCOLLEGE C
			JOIN tblDEPARTMENT D ON C.CollegeID = D.CollegeID
			JOIN tblCOURSE CR ON D.DeptID = CR.DeptID
			JOIN tblCLASS CS ON CR.CourseID = CS.CourseID
			JOIN tblCLASSROOM CM ON CS.ClassroomID = CM.ClassroomID
			JOIN tblBUILDING B ON CM.BuildingID = B.BuildingID
			JOIN tblLOCATION L ON B.LocationID = L.LocationID
		WHERE CS.[YEAR] BETWEEN '2000' AND '2009'
			AND L.LocationName = 'West Campus'
		GROUP BY C.CollegeID, CollegeName
		HAVING COUNT(*) <= 750
		) AS subq2 ON C.CollegeID = subq2.CollegeID

		JOIN
			(
			SELECT C.CollegeID, CollegeName, COUNT(*) AS NumGradClassesAfter2007Quad
				FROM tblCOLLEGE C
				JOIN tblDEPARTMENT D ON C.CollegeID = D.CollegeID
				JOIN tblCOURSE CR ON D.DeptID = CR.DeptID
				JOIN tblCLASS CS ON CR.CourseID = CS.CourseID
				JOIN tblCLASSROOM CM ON CS.ClassroomID = CM.ClassroomID
				JOIN tblBUILDING B ON CM.BuildingID = B.BuildingID
				JOIN tblLOCATION L ON B.LocationID = L.LocationID
				WHERE CS.[YEAR] > '2007'
					AND CR.CourseName LIKE '%5__'
					AND L.LocationName LIKE '%Quad%'
				GROUP BY C.CollegeID, CollegeName
				HAVING COUNT(*) >= 45
				) AS Subq1 ON C.CollegeID = Subq1.CollegeID

				WHERE CS.[YEAR] BETWEEN '1960' AND '1969'
					AND L.LocationName = 'Stevens Way'
				GROUP BY C.CollegeID, C.CollegeName, NumClasses2000sWestCampus, NumGradClassesAfter2007Quad
				HAVING COUNT(*) >= 350
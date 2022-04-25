-- Student Name(s):	Tyler Nelson, Robbie Raftis		

USE giganet_db;

/*	Query 1 � Plan Search (2 marks)
	Write a query that selects all details of any internet plans that cost less than $70, have a quota of at least 500GB, and an access type that is not �Wireless�.
	The access type name should be included in the results.  Order the results by cost.  Using the Plan View in this query is recommended.
*/

-- Write Query 1 here
SELECT *
FROM Plan_View
WHERE MonthlyCost < 70 AND Quota >= 500 AND AccessTypeName != 'Wireless'
ORDER BY MonthlyCost;


/*	Query 2 � Popular Plan Details (2 marks)
	Write a query that selects details of the three most popular internet plans (based upon the number of customers signed up to the plan), 
	and concatenates the plan/access type details into a single column in this format (using the Plan View in this query is recommended):

	�[plan name] ([number of customers] customers) is a [quota]GB, [download speed]Mbps down, [upload speed]Mbps up [access type name] plan costing $[cost].�
*/ 

-- Write Query 2 here
SELECT TOP (3) CONCAT(PlanViewTB.PlanName, ' (', COUNT(CustomerTB.PlanID), ' Customer(s)) is a ', PlanViewTB.Quota, 'GB, ', PlanViewTB.MaxDownSpeed, 'Mbps down, ', PlanViewTB.MaxUpSpeed, 'Mbps up ', PlanViewTB.AccessTypeName, ' plan costing $', PlanViewTB.MonthlyCost) AS 'Popular Plan Details'
FROM Plan_View AS PlanViewTB INNER JOIN Customer AS CustomerTB
ON PlanViewTB.PlanID = CustomerTB.PlanID
GROUP BY PlanViewTB.PlanName, CustomerTB.PlanID, PlanViewTB.Quota, PlanViewTB.MaxDownSpeed, PlanViewTB.MaxUpSpeed, PlanViewTB.AccessTypeName, PlanViewTB.MonthlyCost
ORDER BY CustomerTB.PlanID DESC;


/*	Query 3 � Improperly Resolved Jobs  (2 marks)
	Write a query that selects the job ID, status name, resolve date and full name of the resolving staff member of any jobs that have been improperly resolved.
	This includes situations where either:
	�	The resolving staff ID or resolved date are NULL, and the job status is 4 (Resolved).
	�	The resolving staff ID or resolved date are not NULL, and the job status not 4.

	Using the Job View in this query is recommended

	Hint:  This will involve IS NULL and IS NOT NULL comparisons, and careful use of AND, OR and parentheses.
*/

-- Write Query 3 here
SELECT JobID, StatusName, ResolutionDateTime, ResolverName
FROM Job_View
WHERE ((ResolvingStaffID IS NULL OR ResolutionDateTime IS NULL) AND (StatusID = 4)) OR
      ((ResolvingStaffID IS NOT NULL OR ResolutionDateTime IS NOT NULL) AND (StatusID != 4));




/*	Query 4 � Speed Issues (3 marks)
	Write a query that selects the job ID, summary and lodge date of any support jobs that have the word �speed� or �slow� in the summary.  
	Include the download speed and upload speed (concatenated with a �:� between them), shaped speed and access type name of the customer�s plan in the results.  
	Order the results by the lodge date in descending order.  Using the Plan View in this query is recommended.
*/

-- Write Query 4 here 
SELECT SupportJobTB.JobID, SupportJobTB.Summary, SupportJobTB.JobCreationDateTime, CONCAT(PlanViewTB.MaxDownSpeed, ':' ,PlanViewTB.MaxUpSpeed) AS 'PlanSpeed' , PlanViewTB.ShapedDownSpeed, PlanViewTB.AccessTypeName
FROM SupportJob AS SupportJobTB JOIN Customer AS CustomerTB
ON SupportJobTB.Username = CustomerTB.Username JOIN Plan_View AS PlanViewTB
ON CustomerTB.PlanID = PlanViewTB.PlanID
WHERE Summary LIKE '%speed%' OR Summary LIKE '%slow%'
ORDER BY SupportJobTB.JobCreationDateTime DESC;



/*	Query 5 � Access Type Statistics (3 marks)
	Write a query that selects the following details for each different access type offered by GigaNet:
	�	The name of the access type
	�	The number of plans of that access type
	�	The number of customers signed up for plans of that access type
	�	The total revenue from customers on that access type (i.e. the sum of their plan costs)
	�	The average gigabytes per dollar (i.e. quota divided by cost) of plans of that access type, rounded to two decimal places

	Order the results by number of customers in descending order, and be sure to give each column a suitable alias.  Using the Plan View in this query is recommended.

	Hint:  This will involve grouping and aggregate functions, including counting specific DISTINCT values.
*/

-- Write Query 5 here
SELECT PlanViewTB.AccessTypeName, COUNT(DISTINCT PlanViewTB.PlanID) AS 'NumofPlans', COUNT(DISTINCT CustomerTB.Username) AS 'NumOfCustomers', SUM(PlanViewTB.MonthlyCost) AS TotalRevenue, ROUND(AVG(PlanViewTB.Quota / PlanViewTB.MonthlyCost),2) AS 'AverageGigsPerDollar'
FROM Plan_View as PlanViewTB JOIN Customer as CustomerTB 
ON PlanViewTB.PlanID = CustomerTB.PlanID
GROUP BY AccessTypeName
ORDER BY NumOfCustomers DESC;


/*	Query 6 � Longer than Average Notes (3 marks)
	Write a query that selects the note ID, note date, note text and note length (number of characters in note text), as well as the full name of the staff member who wrote the note, 
	of any notes that are longer than the average length of all notes.  Order the results by the note length in descending order.
*/

-- Write Query 6 here 
SELECT JobNoteTB.NoteID, JobNoteTB.JobDateTime AS 'NoteDate', JobNoteTB.Content, LEN(JobNoteTB.Content) AS 'ContentLength', CONCAT(StaffTB.FirstName, ' ', StaffTB.LastName) AS 'StaffName'
FROM JobNote AS JobNoteTB JOIN Staff AS StaffTB 
ON JobNoteTB.StaffID = StaffTB.StaffID
WHERE LEN(JobNoteTB.Content) > (SELECT AVG(LEN(Content))
								FROM JobNote)
ORDER BY ContentLength DESC;


/*	Query 7 � Staff Peculiarities (4 marks)
	Write a query that selects the full name of staff members (first and last name concatenated with a space between them), their hire date and the name of their level, 
	as well as the full name and hire date of their mentor, for any staff members who are being mentored by someone hired later than themselves, 
	or who have a level that expects more years of experience at GigaNet than they have.

	Hint:  This will involve a self outer join, and the expected experience column of the level table.
*/

-- Write Query 7 here
SELECT CONCAT(StaffTB.FirstName,' ',StaffTB.LastName) AS 'StaffName', StaffTB.HireDate, LevelTypeTB.LevelName, LevelTypeTB.Experience AS 'ExpectedExperience', CONCAT(StaffTB2.FirstName,' ', StaffTB2.LastName) AS 'MentorName', StaffTB2.HireDate
FROM Staff as StaffTB JOIN LevelType as LevelTypeTB
ON LevelTypeTB.LevelID = StaffTB.LevelID RIGHT OUTER JOIN Staff as StaffTB2
ON StaffTB.MentorID = StaffTB2.StaffId
WHERE (StaffTB.Hiredate) < (StaffTB2.HireDate) OR LevelTypeTB.Experience > DATEDIFF(yy, StaffTB.Hiredate, GETDATE());


/*	Query 8 � Difficult Jobs (4 marks)
	Write a query that selects the following details of jobs:
	�	The job ID, summary and lodge date
	�	Full names of the staff members who lodged the job and resolved the job
	�	Duration of the job (time between lodge date and resolve date) in hours
	�	The number of notes that have been written about the job

	The results should only include jobs where the duration of the job is at least one hour, the staff member who lodged the job is not the same as the staff member who resolved it, 
	and there are at least two notes written about the job.  Order the results by lodge date in descending order.  Using the Job View in this query is recommended.

	Hint:  This query is likely to involve using GROUP BY, HAVING, COUNT and DATEDIFF.
*/

-- Write Query 8 here
SELECT JobViewTB.JobID, JobViewTB.Summary, JobViewTB.JobCreationDateTime, JobViewTB.LodgerName, JobViewTB.ResolverName, DATEDIFF(hh, JobViewTB.JobCreationDateTime, JobViewTB.ResolutionDateTime) AS 'Duration', COUNT(JobNoteTB.JobID) AS 'NumberOfNotes'
FROM Job_View AS JobViewTB JOIN JobNote AS JobNoteTB
ON JobViewTB.JobID = JobNoteTB.JobID
GROUP BY JobViewTB.JobID, JobViewTB.Summary, JobViewTB.JobCreationDateTime, JobViewTB.LodgerID, JobViewTB.LodgerName, JobViewTB.ResolvingStaffID, JobViewTB.ResolverName, JobViewTB.ResolutionDateTime, JobNoteTB.JobID
HAVING DATEDIFF(hh, JobViewTB.JobCreationDateTime, JobViewTB.ResolutionDateTime) > 1 AND JobViewTB.LodgerID != JobViewTB.ResolvingStaffID AND COUNT(JobNoteTB.JobID) > 2
ORDER BY JobViewTB.JobCreationDateTime DESC;


/*	Query 9 � Staff Statistics (4 marks)
	Write a query that selects the staff ID and full name and level name of all staff members, the number of jobs that they have lodged, the number of jobs that they have resolved, 
	and the number of notes they have written.  Ensure that all staff members are included in the results.  Order the results by level name in ascending order then jobs resolved in descending order.

	Hint:  This will involve outer joins, grouping and counting specific DISTINCT values.
*/

-- Write Query 9 here
SELECT StaffTB.StaffID, CONCAT(StaffTB.FirstName,' ', StaffTB.LastName) AS 'StaffName', LevelTypeTB.LevelName, COUNT(DISTINCT SupportJobTB.JobID ) AS 'JobsLodged', COUNT(DISTINCT SupportJobTB2.JobID) AS 'JobsResolved', COUNT(DISTINCT JobeNoteTB.NoteID) AS 'NotesWritten'
FROM Staff as StaffTB 
JOIN SupportJob as SupportJobTB ON SupportJobTB.SupportingStaffID = StaffTB.StaffID
LEFT OUTER JOIN SupportJob as SupportJobTB2 ON SupportJobTB2.ResolvingStaffID = StaffTB.StaffID
JOIN JobNote as JobeNoteTB ON JobeNoteTB.StaffID = StaffTB.StaffID
JOIN LevelType as LevelTypeTB ON LevelTypeTB.LevelID = StaffTB.LevelID
GROUP BY StaffTB.StaffID, StaffTB.FirstName, StaffTB.LastName, LevelTypeTB.LevelName
ORDER BY LevelTypeTB.LevelName ASC, JobsResolved DESC;

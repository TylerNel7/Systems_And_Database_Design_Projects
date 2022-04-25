-- Student Name(s):	Tyler Nelson, Robbie Raftis		

USE giganet_db;
GO


/*	Plan View (1 mark)
	Create a view that selects all details of all of the internet plans offered by GigaNet, 
	as well as the name and maximum possible speed of the access type of each plan.
*/

-- Write your Plan View here
CREATE VIEW Plan_View AS
	SELECT a.*, b.AccessTypeName, b.MaxSpeed
	FROM Plans AS a INNER JOIN AccessType AS b
	ON a.TypeID = b.TypeID



GO
/*	Job View (3 marks)
	Create a view that selects the following details of all support jobs (including those that are unresolved):
	�	The job ID and job summary
	�	The username of the customer that the job relates to, and the customer�s first and last name concatenated into a full name (e.g. �John Smith�)
	�	The date/time that the job was lodged, the staff ID of the staff member who lodged the job, and the lodging staff member�s first and last name concatenated into a full name
	�	The date/time that the job was resolved, the staff ID of the staff member who resolved the job, and the resolving staff member�s first and last name concatenated into a full name
	�	The status ID and status name of the job

	Hint:  This requires multiple JOINs, one of which must be an OUTER JOIN.
*/

-- Write your Job View here
CREATE VIEW Job_View AS 
	SELECT a.JobID, a.Summary, b.Username, CONCAT(b.firstName, ' ', b.lastName) AS CustomerName, a.JobCreationDateTime, a.SupportingStaffID AS LodgerID, CONCAT(c.firstname, ' ', c.lastname) AS LodgerName, a.ResolutionDateTime, a.ResolvingStaffID, CONCAT(e.firstname, ' ', e.lastname) AS ResolverName, d.StatusID, d.StatusName 
    FROM SupportJob AS a JOIN Customer AS b 
    ON a.Username = b.Username JOIN Staff AS c 
    ON c.StaffID = a.SupportingStaffID JOIN JobStatus as d
    ON d.StatusID = a.StatusID LEFT OUTER JOIN Staff as e
    ON e.StaffID = a.ResolvingStaffID;


	
GO
/*	If you wish to create additional views to use in the queries which follow, include them in this file. */

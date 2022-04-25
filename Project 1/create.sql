-- Student Name(s):	Tyler Nelson, Robbie Raftis	

/*	Database Creation & Population Script (7 marks)
	Produce a script to create the database you designed in Task 1 (incorporating any changes you have made since then).
	Be sure to give your columns the same data types, properties and constraints specified in your data dictionary, and be sure to name tables and columns consistently.
	Include any suitable default values and any necessary/appropriate CHECK or UNIQUE constraints.

	Make sure this script can be run multiple times without resulting in any errors (hint: drop the database if it exists before trying to create it).
	You can use/adapt the code at the start of the creation scripts of the sample databases available in the unit materials to implement this.

	See the assignment brief for further information. 
*/


-- Write your creation script here

-- Check if the database 'giganet_db' already exists, if so then drop it 
IF DB_ID('giganet_db') IS NOT NULL
BEGIN
	PRINT 'Database already exists - removing.';

	USE master;
	ALTER DATABASE giganet_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

	DROP DATABASE giganet_db;

END
GO

--Create a new database called "giganet_db"
PRINT 'Creating database "giganet_db" '
CREATE DATABASE giganet_db;
GO

--Set "giganet_db" as the current active database
USE giganet_db;
GO

--Create Table "AccessType"
CREATE TABLE AccessType
(	TypeID TINYINT NOT NULL IDENTITY CONSTRAINT AccessType_pk PRIMARY KEY,
	AccessTypeName VARCHAR(20) NOT NULL CONSTRAINT AccessType_uk UNIQUE,
	MaxSpeed SMALLINT NOT NULL
);

--Create Table "Plans"
CREATE TABLE Plans
(	PlanID TINYINT NOT NULL IDENTITY CONSTRAINT PlanID_pk PRIMARY KEY,
	TypeID TINYINT NOT NULL CONSTRAINT TypeID_fk FOREIGN KEY REFERENCES AccessType(TypeID),
	PlanName VARCHAR(20) NOT NULL CONSTRAINT PlanName_uk UNIQUE,
	MonthlyCost SMALLMONEY NOT NULL,
	Quota SMALLINT NOT NULL,
	MaxDownSpeed SMALLINT NOT NULL,
	MaxUpSpeed SMALLINT NOT NULL,
	ShapedDownSpeed TINYINT NOT NULL, 
	
	CONSTRAINT ShapedDownSpeed_cs CHECK (ShapedDownSpeed <= MaxDownSpeed)
)

--Create Table "Customer"
CREATE TABLE Customer
(	Username VARCHAR(20) NOT NULL CONSTRAINT Username_pk PRIMARY KEY,
	PlanID TINYINT NOT NULL CONSTRAINT PlanID_fk FOREIGN KEY REFERENCES Plans(PlanID),
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	ClientAddress TEXT NOT NULL,
	PhoneNumber VARCHAR(20) NOT NULL
);

--Create Table "JobStatus"
CREATE TABLE JobStatus
(   StatusID TINYINT NOT NULL IDENTITY CONSTRAINT StatusID_pk PRIMARY KEY,
    StatusName VARCHAR(20) NOT NULL CONSTRAINT StatusName_uk UNIQUE,
);

--Create Table "LevelType"
CREATE TABLE LevelType
(   LevelID TINYINT NOT NULL IDENTITY CONSTRAINT LevelID_pk PRIMARY KEY,
    LevelName VARCHAR(30) NOT NULL CONSTRAINT LevelName_uk UNIQUE,
    Experience TINYINT NOT NULL,
    PayRate SMALLMONEY NOT NULL,
);

--Create Table "Staff"
CREATE TABLE Staff
(	StaffID SMALLINT NOT NULL IDENTITY CONSTRAINT StaffID_pk PRIMARY KEY,
	LevelID TINYINT NOT NULL CONSTRAINT LevelID_fk FOREIGN KEY REFERENCES LevelType(LevelID),
	MentorID SMALLINT NULL CONSTRAINT MentorID_fk FOREIGN KEY REFERENCES Staff(StaffID),
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	PhoneNumber VARCHAR(20) NOT NULL,
	HireDate DATE DEFAULT GETDATE() NOT NULL CHECK (HireDate <= GETDATE()),

	CONSTRAINT MentorID_cs CHECK (MentorID != StaffID)
)


--Create Table "SupportJob"
CREATE TABLE SupportJob 
(   JobID INT NOT NULL IDENTITY CONSTRAINT JobID_pk PRIMARY KEY,
    Username VARCHAR(20) NOT NULL CONSTRAINT Username_fk REFERENCES Customer(Username),
    SupportingStaffID SMALLINT NOT NULL CONSTRAINT SupportingStaffID_fk REFERENCES Staff(StaffID),
    StatusID TINYINT NOT NULL CONSTRAINT StatusID_fk REFERENCES JobStatus(StatusID),
    ResolvingStaffID SMALLINT NULL CONSTRAINT ResolvingStaffID_fk REFERENCES Staff(StaffID),
    ResolutionDateTime DATETIME NULL,
    JobCreationDateTime DATETIME DEFAULT GETDATE() NOT NULL,
    Summary VARCHAR(100) NOT NULL,

	CONSTRAINT ResolutionDateTime_cs CHECK (ResolutionDateTime > JobCreationDateTime)
);

--Create Table "JobNote"
CREATE TABLE JobNote
(   NoteID INT NOT NULL IDENTITY CONSTRAINT NoteID_pk PRIMARY KEY,
    StaffID SMALLINT NOT NULL CONSTRAINT StaffID_fk REFERENCES Staff(StaffID),
    JobID INT NOT NULL CONSTRAINT JobID_fk REFERENCES SupportJob(JobID),
    JobDateTime DATETIME DEFAULT GETDATE() NOT NULL,
    Content VARCHAR(1000) NOT NULL,
);




/*	Database Population Statements
	Following the SQL statements to create your database and its tables, you must include statements to populate the database with sufficient test data.
	You are only required to populate the database with enough data to make sure that all views and queries return meaningful results.
	
	You can start working on your views and queries and write INSERT statements as needed for testing as you go.
	The final create.sql should be able to create your database and populate it with enough data to make sure that all views and queries return meaningful results.

	Since writing sample data is time-consuming and quite tedious, I have provided data for some of the tables below.
	Adapt the INSERT statements as needed, and write your own INSERT statements for the remaining tables at the end of the file.
*/



/*	The following statement inserts the details of 3 access types into a table named "access_type".
    It specifies values for columns named "type_name" and "max_speed" (in Mbps).
	Access type ID numbers are not specified since it is assumed that an auto-incrementing integer is being used.
	If required, change the table and column names to match those in your database.
*/

INSERT INTO AccessType (AccessTypeName, MaxSpeed)
VALUES	('ADSL', 24),			-- access type 1
		('Fibre', 1000),		-- access type 2
		('Wireless', 150);		-- access type 3

/*	The following statement inserts the details of 5 internet plans into a table named "internet_plan".
    It specifies values for columns named "plan_pame", "cost" (per month), "quota" (in GB), "download_speed" (in Mbps), "upload_speed" (in Mbps), "shaped_speed" (in Mbps) and "type_id".
	Plan ID numbers are not specified since it is assumed that an auto-incrementing integer is being used.
	If required, change the table and column names to match those in your database.
*/

INSERT INTO Plans (PlanName, MonthlyCost, Quota, MaxDownSpeed, MaxUpSpeed, ShapedDownSpeed, TypeID)
VALUES	('Budget Broadband', 29.95, 250, 24, 5, 24, 1),		-- internet plan 1 (ADSL)
		('NBN Lite', 49.95, 500, 50, 5, 25, 2),				-- internet plan 2 (Fibre)
		('NBN Max', 69.95, 1500, 100, 20, 50, 2),			-- internet plan 3 (Fibre)
		('Freedom Lite', 59.95, 500, 50, 5, 25, 3),			-- internet plan 4 (Wireless)
		('Freedom Ultra', 109.95, 1000, 150, 20, 50, 3);	-- internet plan 5 (Wireless)


/*	The following statement inserts the details of 3 staff levels into a table named "level".
    It specifies values for columns named "level_name", "expected_xp" and "pay".
	Level ID numbers are not specified since it is assumed that an auto-incrementing integer is being used.
	If required, change the table and column names to match those in your database.
*/

INSERT INTO LevelType (LevelName, Experience, PayRate)
VALUES	('Level 1 (Junior Support)', 0, 23.50),		-- level 1
		('Level 2 (Senior Support)', 1, 27.50),		-- level 2
		('Level 3 (Expert Support)', 3, 34.50);		-- level 3
	

/*	The following statement inserts the details of 4 job statuses into a table named "status".
    It specifies values for a column named "status_name".
	A status ID number is not specified since it is assumed that an auto-incrementing integer is being used.
	If required, change the table and column names to match those in your database.

	The following is an explanation of the meaning of each status:
	 * Unresolved - The problem has not been resolved.
	 * Pending (Customer) - The problem has not been resolved and is waiting upon the customer to do something (e.g. try another modem).
	 * Pending (Customer) - The problem has not been resolved and is waiting upon an external party to do something (e.g. Telstra/NBN Co. checking a connection).
	 * Resolved - The problem has been resolved.
*/

INSERT INTO JobStatus (StatusName)
VALUES	('Unresolved'),				-- status 1
		('Pending (Customer)'),		-- status 2
		('Pending (External)'),		-- status 3
		('Resolved');				-- status 4


-- Write your INSERT statements for the remaining tables here

-- Insert data of customer information 
INSERT INTO Customer (Username, PlanID, FirstName, LastName, ClientAddress, PhoneNumber)
VALUES ('Joshhuahuahua', 1, 'Josh', 'Hollander', '14 Hayfeild Way', 0409237138),
	   ('Ionel', 3, 'Nelio', 'Fernandes', '23 Ripley Drive', 0482952395),
	   ('Viltra', 3, 'Tyler', 'Nelson', '17 James Street', 0498627937),
	   ('oakboat', 5, 'Matthew', 'Alphonso', '62 Martens Place', 0488739945),
	   ('Nano', 5, 'Jake', 'Fletcher', '15 Silver Place', 0443998037),
	   ('Robmate', 5, 'Robbie', 'Raftis', '73 Fonsten Drive', 0456783532);

--Insert Data of staff information (StaffID is omitted as it is a auto inrementing integer)
INSERT INTO Staff (LevelID, MentorID, FirstName, LastName, PhoneNumber, HireDate)
VALUES (1, 3, 'Dion', 'Hudson', 0472836123, '1969-01-01'),
	   (2, 3, 'Radobod', 'Dipika', 0462823952, '2014-08-25'),
	   (3, NULL, 'Floro', 'Ishvi', 0463834812, '2001-11-07');

--Insert data for SupportJob table (JobID is omitted as it is a auto inrementing integer)
INSERT INTO SupportJob (Username, SupportingStaffID, StatusID, ResolvingStaffID, ResolutionDateTime, JobCreationDateTime, Summary)
VALUES ('Ionel', 2, 2, NULL, NULL, '2020-10-01 13:37:39', 'Messed up another Linux Distro and broke the network'),
	   ('oakboat', 3, 4, 3, '2020-10-08 11:58:06', '2020-10-07 09:48:46', 'Nel was in electrical and the netwrok dropped out'),
	   ('Robmate', 1, 1, NULL, NULL, '2020-10-04 10:28:56', 'The internet is slow'),
	   ('Viltra', 1, 4, 3, '2020-10-12 15:58:56', '2020-10-09 10:28:56', 'The network slowed down by a landslide once new "upgrades" were made to the fibre to the premise'),
	   ('Ionel', 1, 4, NULL, NULL, '2020-10-09 10:28:56', 'The network slowed down by a landslide once new "upgrades" were made to the fibre to the premise');
	    
--Insert data for JobNote table (NoteId is omitted as it is a auto inrementing integer)
INSERT INTO JobNote (StaffID, JobID, JobDateTime, Content)
VALUES (2, 1, '2020-10-01 13:37:39', 'Client has courrpted the NIC on the area node in attempt to express the domiance of linux, technicain needed to fix issue'),
	   (3, 2, '2020-10-07 09:48:46', 'Client was friendly and the issue was swifty addressed. However we should make sur electrical is locked to prevent future issues'),
	   (1, 3, '2020-10-04 10:28:56', 'Client showing signs of hostility though given the situation with telstras interferance that is understandable. Sending out a technicain to inspect the area node to address issue'),
	   (1, 4, '2020-10-04 10:28:56', 'Client has raised an issue thath is beyound that of which I am trained to help, passing to more equiped staff member'),
	   (3, 4, '2020-10-04 10:28:56', 'Job has lifted to myself for more epxerienced handling, investigating issue in more detail and contacting local technicain'),
	   (3, 4, '2020-10-04 10:28:56', 'Local technicain has be notfied and is making changes to fix client issue');



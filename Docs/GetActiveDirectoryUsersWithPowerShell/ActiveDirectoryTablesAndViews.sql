--#################################################################################################
-- Three core tables to hold, Users,Groups and Group Members
--#################################################################################################
IF OBJECT_ID('[dbo].[GetActiveDirectoryUsers]') IS NOT NULL 
DROP TABLE [dbo].[GetActiveDirectoryUsers] 
GO
CREATE TABLE [dbo].[GetActiveDirectoryUsers] ( 
[ID]                    INT              IDENTITY(1,1)   NOT NULL,
[CanonicalName]         VARCHAR(128)                     NOT NULL,
[DomainName] AS LEFT([CanonicalName],CHARINDEX('/',[CanonicalName])-1),
[sAMAccountName]        VARCHAR(128)                     NOT NULL,
[OperationalUnit]       VARCHAR(128)                         NULL,
[FirstName]             VARCHAR(128)                         NULL,
[LastName]              VARCHAR(128)                         NULL,
[DisplayName]           VARCHAR(128)                         NULL,
[email]                 VARCHAR(128)                         NULL,
[EmailAddress]          VARCHAR(128)                         NULL,
[ImpliedAcount]         AS (case when charindex('@',[EmailAddress])>(0) AND charindex('.',[EmailAddress])>charindex('@',[EmailAddress]) then (substring([EmailAddress],charindex('@',[EmailAddress])+(1),(charindex('.',[EmailAddress])-charindex('@',[EmailAddress]))-(1))+'\')+substring([EmailAddress],(1),charindex('@',[EmailAddress])-(1)) else '' end) PERSISTED,
[StreetAddress]         VARCHAR(128)                         NULL,
[City]                  VARCHAR(128)                         NULL,
[State]                 VARCHAR(128)                         NULL,
[PostalCode]            VARCHAR(128)                         NULL,
[HomePhone]             VARCHAR(128)                         NULL,
[MobilePhone]           VARCHAR(128)                         NULL,
[OfficePhone]           VARCHAR(128)                         NULL,
[Fax]                   VARCHAR(128)                         NULL,
[Company]               VARCHAR(128)                         NULL,
[Organization]          VARCHAR(128)                         NULL,
[Department]            VARCHAR(128)                         NULL,
[Title]                 VARCHAR(128)                         NULL,
[Description]           VARCHAR(128)                         NULL,
[Office]                VARCHAR(128)                         NULL,
[extensionAttribute1]   VARCHAR(128)                         NULL,
[extensionAttribute2]   VARCHAR(128)                         NULL,
[extensionAttribute3]   VARCHAR(128)                         NULL,
[extensionAttribute4]   VARCHAR(128)                         NULL,
[extensionAttribute5]   VARCHAR(128)                         NULL,
[AccountExpires]        VARCHAR(128)                         NULL,
[AccountIsEnabled]      VARCHAR(128)                         NULL,
[PasswordLastSet]       VARCHAR(128)                         NULL,
[PasswordAge]           AS (case when isdate([PasswordLastSet])=(1) then datediff(day,[PasswordLastSet],getdate()) else (0) end),
[PasswordExpires]       VARCHAR(128)                         NULL,
[PasswordNeverExpires]  VARCHAR(128)                         NULL,
[PasswordIsExpired]     VARCHAR(128)                         NULL,
[LastLogonTimestamp]    VARCHAR(128)                         NULL,
[CreatedDate]           DATETIME                             NULL,
[DWCreatedDate]         DATETIME                             NULL  CONSTRAINT [DF__GetActiveDirectoryUsers__DWCreatedDate] DEFAULT (getdate()),
[DWUpdatedDate]         DATETIME                             NULL,
CONSTRAINT   [PK__GetActiveDirectoryUsers_sAMAccountName]  PRIMARY KEY CLUSTERED    ([CanonicalName],[sAMAccountName] asc))


IF OBJECT_ID('[dbo].[GetActiveDirectoryGroups]') IS NOT NULL 
DROP TABLE [dbo].[GetActiveDirectoryGroups] 
GO
CREATE TABLE [dbo].[GetActiveDirectoryGroups] ( 
[ID]                 INT              IDENTITY(1,1)   NOT NULL,
[CanonicalName]      VARCHAR(128)                     NOT NULL,
[DomainName] AS LEFT([CanonicalName],CHARINDEX('/',[CanonicalName])-1),
[SamAccountName]     VARCHAR(128)                     NOT NULL,
[DisplayName]        VARCHAR(128)                         NULL,
[Description]        VARCHAR(128)                         NULL,
[DistinguishedName]  VARCHAR(128)                         NULL,
[GroupCategory]      VARCHAR(128)                         NULL,
[GroupScope]         VARCHAR(128)                         NULL,
[CreatedDate]        DATETIME                             NULL,
[DWCreatedDate]      DATETIME                             NULL  CONSTRAINT [DF__GetActiveDirectoryGroups__DWCreatedDate] DEFAULT (getdate()),
[DWUpdatedDate]      DATETIME                             NULL,
CONSTRAINT   [PK__GetActiveDirectoryGroups_SamAccountName]  PRIMARY KEY CLUSTERED    ([CanonicalName],[SamAccountName] asc))



IF OBJECT_ID('[dbo].[GetActiveDirectoryGroupMembers]') IS NOT NULL 
DROP TABLE [dbo].[GetActiveDirectoryGroupMembers] 
GO
CREATE TABLE [dbo].[GetActiveDirectoryGroupMembers] ( 
[ID]                   INT              IDENTITY(1,1)   NOT NULL,
[GroupCanonicalName]   VARCHAR(128)                     NOT NULL,
[GroupSamAccountName]  VARCHAR(128)                     NOT NULL,
[DomainName] AS LEFT([GroupCanonicalName],CHARINDEX('/',[GroupCanonicalName])-1),
[SamAccountName]       VARCHAR(128)                     NOT NULL,
[ObjectClass]          VARCHAR(128)                     NOT NULL,
[DWCreatedDate]        DATETIME                             NULL  CONSTRAINT [DF__GetActiveDirectoryGroupMembers__DWCreatedDate] DEFAULT (getdate()),
[DWUpdatedDate]        DATETIME                             NULL,
[DWIsDeleted]          BIT                                  NULL  CONSTRAINT [DF__GetActiveDirectoryGroupMembers__DWIsDeleted] DEFAULT ((0)),
[DWDeletedDate]        DATETIME                             NULL,
CONSTRAINT   [UQ_GetActiveDirectoryGroupMembers_GroupUserObject]  UNIQUE      CLUSTERED    ([GroupCanonicalName] asc,[GroupSamAccountName] asc,[SamAccountName] asc, [ObjectClass] asc))

--#################################################################################################
-- Some Handy Views to make the data a wee bit more accessible.
--#################################################################################################

IF OBJECT_ID('[dbo].[vwActiveDirectoryUsers]') IS NOT NULL 
DROP  VIEW      [dbo].[vwActiveDirectoryUsers] 
GO
--#################################################################################################
-- vwActiveDirectoryUsers, subset of data, underlying table populated by a powershell script and Scheduled job three times a week
--#################################################################################################
--SELECT * FROM vwActiveDirectoryUsers
CREATE View vwActiveDirectoryUsers
AS
SELECT  CASE
           WHEN AD.AccountIsEnabled = 'False' 
           THEN 1
           WHEN AD.PasswordisExpired = 'True'
            AND AD.PasswordNeverExpires = 'False'
           THEN 1
           ELSE 0
         END AS [IsDisabledOrLockedOut],
         CASE
           WHEN ( AD.PasswordisExpired = 'False'
                  AND AD.AccountIsEnabled = 'True' )
                AND IsDate(AD.LastLogonTimestamp) = 1
                AND CONVERT(DATETIME, AD.LastLogonTimestamp) >= Dateadd(dd, -30, Getdate()) THEN 1
           ELSE 0
         END AS [ActiveLast30Days],

AD.ID AS ID,
LEFT(AD.CanonicalName,CHARINDEX('/',CanonicalName)-1) As DomainName,
AD.FirstName,
AD.LastName,
AD.DisplayName AS Name,
AD.EmailAddress AS email,
AD.sAMAccountName,
AD.ImpliedAcount,
AD.AccountExpires,
AD.PasswordLastSet,
AD.PasswordAge,
AD.PasswordExpires,
AD.PasswordNeverExpires,
AD.PasswordIsExpired,
'' AS PasswordStatus,
AD.AccountIsEnabled,
AD.LastLogonTimestamp,
AD.DWCreatedDate,
AD.DWUpdatedDate
 FROM GetActiveDirectoryUsers AD
GO

IF OBJECT_ID('[dbo].[vwActiveDirectoryGroupMembers]') IS NOT NULL 
DROP  VIEW      [dbo].[vwActiveDirectoryGroupMembers] 
GO
--#################################################################################################
-- vwADGroupMembers, underlying table populated  by a powershell script and Scheduled job once a month
--#################################################################################################
CREATE VIEW vwActiveDirectoryGroupMembers
AS
select
LEFT(g.CanonicalName,CHARINDEX('/',g.CanonicalName)-1) As GroupDomainName,
g.SamAccountName As GroupSamAccountName,
g.DisplayName AS GroupDisplayName,
u.*
FROM GetActiveDirectoryGroupMembers gm
INNER JOIN GetActiveDirectoryGroups g on gm.GroupSamAccountName = g.SamAccountName 
AND gm.DomainName = g.DomainName
INNER JOIN  GetActiveDirectoryUsers u on gm.SamAccountName = u.sAMAccountName
AND  gm.DomainName = u.DomainName
GO
IF OBJECT_ID('[dbo].[vwGetActiveDirectoryUsers]') IS NOT NULL 
DROP  VIEW      [dbo].[vwGetActiveDirectoryUsers] 
GO
--#################################################################################################
-- vwGetActiveDirectoryUsers, full column list,underlying table populated by a powershell script and Scheduled job three times a week
--#################################################################################################
CREATE VIEW vwGetActiveDirectoryUsers
AS
  SELECT CASE
           WHEN ( AD.PasswordisExpired = 'True'
                  AND AD.AccountIsEnabled = 'True' )
                 OR AD.AccountIsEnabled = 'False' THEN 1
           ELSE 0
         END AS [IsDisabledOrLockedOut],
         CASE
           WHEN ( AD.PasswordisExpired = 'False'
                  AND AD.AccountIsEnabled = 'True' )
                AND IsDate(AD.LastLogonTimestamp) = 1
                AND CONVERT(DATETIME, AD.LastLogonTimestamp) >= Dateadd(dd, -30, Getdate()) THEN 1
           ELSE 0
         END AS [ActiveLast30Days],
         AD.[ID],
         AD.[CanonicalName],
         AD.[DomainName],
         AD.[sAMAccountName],
         AD.[OperationalUnit],
         AD.[FirstName],
         AD.[LastName],
         AD.[DisplayName],
         AD.[email],
         AD.[EmailAddress],
         AD.[ImpliedAcount],
         AD.[StreetAddress],
         AD.[City],
         AD.[State],
         AD.[PostalCode],
         AD.[HomePhone],
         AD.[MobilePhone],
         AD.[OfficePhone],
         AD.[Fax],
         AD.[Company],
         AD.[Organization],
         AD.[Department],
         AD.[Title],
         AD.[Description],
         AD.[Office],
         AD.[extensionAttribute1],
         AD.[extensionAttribute2],
         AD.[extensionAttribute3],
         AD.[extensionAttribute4],
         AD.[extensionAttribute5],
         AD.[AccountExpires],
         AD.[AccountIsEnabled],
         AD.[PasswordLastSet],
         AD.[PasswordAge],
         AD.[PasswordExpires],
         AD.[PasswordNeverExpires],
         AD.[PasswordIsExpired],
         AD.[LastLogonTimestamp],
         AD.[CreatedDate],
         AD.[DWCreatedDate],
         AD.[DWUpdatedDate]
  FROM   GetActiveDirectoryUsers AD 

GO
IF OBJECT_ID('[dbo].[vwActiveDirectorySummary]') IS NOT NULL 
DROP  VIEW      [dbo].[vwActiveDirectorySummary] 
GO
--#################################################################################################
-- vwActiveDirectorySummary, rollup of data, underlying table populated by a powershell script and Scheduled job three times a week
--#################################################################################################
CREATE VIEW vwActiveDirectorySummary
AS
SELECT 
ad.DomainName,
COUNT(*) AS TotalADUsers,
 SUM(CASE
           WHEN ( AD.PasswordisExpired = 'True'
                  AND AD.AccountIsEnabled = 'True' )
                 OR AD.AccountIsEnabled = 'False' THEN 1
           ELSE 0
         END) AS [IsDisabledOrLockedOut],
SUM(CASE WHEN AD.PasswordisExpired = 'True' AND AD.AccountIsEnabled = 'False' THEN 1 ELSE 0 END) As [LockedOut],
SUM(CASE WHEN AD.AccountIsEnabled = 'True' THEN 1 ELSE 0 END) As [IsDisabled],
SUM(CASE WHEN (AD.PasswordisExpired = 'False' AND AD.AccountIsEnabled = 'False') THEN 1 ELSE 0 END) As [NotDisabledOrLockedOut],
SUM(CASE WHEN (AD.PasswordisExpired = 'False' AND AD.AccountIsEnabled = 'False') AND IsDate(AD.LastLogonTimestamp) = 0 THEN 1 ELSE 0 END) As [NeverLoggedIn],
SUM(CASE WHEN (AD.PasswordisExpired = 'False' AND AD.AccountIsEnabled = 'False') AND IsDate(AD.LastLogonTimestamp) = 1 AND CONVERT(datetime,AD.LastLogonTimestamp) >= dateadd(dd,-30,getdate()) THEN 1 ELSE 0 END) As [ActiveLast30Days],
SUM(CASE WHEN (AD.PasswordisExpired = 'False' AND AD.AccountIsEnabled = 'False') AND IsDate(AD.LastLogonTimestamp) = 1 AND CONVERT(datetime,AD.LastLogonTimestamp) <= dateadd(dd,-30,getdate()) AND AD.PasswordisExpired = 'False'AND AD.AccountIsEnabled = 'False' THEN 1 ELSE 0 END) As [NotActiveInMoreThan30Days],
'' AS Filler
FROM [dbo].[GetActiveDirectoryUsers] AD
GROUP BY ad.DomainName
GO

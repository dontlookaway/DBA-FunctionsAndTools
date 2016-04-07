SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--#################################################################################################
-- vwADGroupMembers, underlying table populated  by a powershell script and Scheduled job once a month
--#################################################################################################
Create View [dbo].[vwActiveDirectoryGroupMembers]
As
    Select  Left([g].[CanonicalName] , CharIndex('/' , [g].[CanonicalName]) - 1) As [GroupDomainName]
          , [g].[SamAccountName] As [GroupSamAccountName]
          , [g].[DisplayName] As [GroupDisplayName]
          , [u].*
    From    [GetActiveDirectoryGroupMembers] [gm]
            Inner Join [GetActiveDirectoryGroups] [g] On [gm].[GroupSamAccountName] = [g].[SamAccountName]
                                                     And [gm].[DomainName] = [g].[DomainName]
            Inner Join [GetActiveDirectoryUsers] [u] On [gm].[SamAccountName] = [u].[sAMAccountName]
                                                    And [gm].[DomainName] = [u].[DomainName];
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--#################################################################################################
-- vwActiveDirectoryUsers, subset of data, underlying table populated by a powershell script and Scheduled job three times a week
--#################################################################################################
--SELECT * FROM vwActiveDirectoryUsers
Create View [dbo].[vwActiveDirectoryUsers]
As
    Select  Case When [AD].[AccountIsEnabled] = 'False' Then 1
                 When [AD].[PasswordIsExpired] = 'True'
                      And [AD].[PasswordNeverExpires] = 'False' Then 1
                 Else 0
            End As [IsDisabledOrLockedOut]
          , Case When ( [AD].[PasswordIsExpired] = 'False'
                        And [AD].[AccountIsEnabled] = 'True'
                      )
                      And IsDate([AD].[LastLogonTimestamp]) = 1
                      And Convert(DateTime , [AD].[LastLogonTimestamp]) >= DateAdd(dd ,
                                                              -30 , GetDate())
                 Then 1
                 Else 0
            End As [ActiveLast30Days]
          , [AD].[ID] As [ID]
          , Left([AD].[CanonicalName] , CharIndex('/' , [AD].[CanonicalName]) - 1) As [DomainName]
          , [AD].[FirstName]
          , [AD].[LastName]
          , [AD].[DisplayName] As [Name]
          , [AD].[EmailAddress] As [email]
          , [AD].[sAMAccountName]
          , [AD].[ImpliedAcount]
          , [AD].[AccountExpires]
          , [AD].[PasswordLastSet]
          , [AD].[PasswordAge]
          , [AD].[PasswordExpires]
          , [AD].[PasswordNeverExpires]
          , [AD].[PasswordIsExpired]
          , '' As [PasswordStatus]
          , [AD].[AccountIsEnabled]
          , [AD].[LastLogonTimestamp]
          , [AD].[DWCreatedDate]
          , [AD].[DWUpdatedDate]
    From    [GetActiveDirectoryUsers] [AD];
GO

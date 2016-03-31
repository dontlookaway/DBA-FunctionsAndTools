SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--#################################################################################################
-- vwGetActiveDirectoryUsers, full column list,underlying table populated by a powershell script and Scheduled job three times a week
--#################################################################################################
Create View [dbo].[vwGetActiveDirectoryUsers]
As
    Select  Case When ( [AD].[PasswordIsExpired] = 'True'
                        And [AD].[AccountIsEnabled] = 'True'
                      )
                      Or [AD].[AccountIsEnabled] = 'False' Then 1
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
          , [AD].[ID]
          , [AD].[CanonicalName]
          , [AD].[DomainName]
          , [AD].[sAMAccountName]
          , [AD].[OperationalUnit]
          , [AD].[FirstName]
          , [AD].[LastName]
          , [AD].[DisplayName]
          , [AD].[email]
          , [AD].[EmailAddress]
          , [AD].[ImpliedAcount]
          , [AD].[StreetAddress]
          , [AD].[City]
          , [AD].[State]
          , [AD].[PostalCode]
          , [AD].[HomePhone]
          , [AD].[MobilePhone]
          , [AD].[OfficePhone]
          , [AD].[Fax]
          , [AD].[Company]
          , [AD].[Organization]
          , [AD].[Department]
          , [AD].[Title]
          , [AD].[Description]
          , [AD].[Office]
          , [AD].[extensionAttribute1]
          , [AD].[extensionAttribute2]
          , [AD].[extensionAttribute3]
          , [AD].[extensionAttribute4]
          , [AD].[extensionAttribute5]
          , [AD].[AccountExpires]
          , [AD].[AccountIsEnabled]
          , [AD].[PasswordLastSet]
          , [AD].[PasswordAge]
          , [AD].[PasswordExpires]
          , [AD].[PasswordNeverExpires]
          , [AD].[PasswordIsExpired]
          , [AD].[LastLogonTimestamp]
          , [AD].[CreatedDate]
          , [AD].[DWCreatedDate]
          , [AD].[DWUpdatedDate]
    From    [GetActiveDirectoryUsers] [AD]; 

GO

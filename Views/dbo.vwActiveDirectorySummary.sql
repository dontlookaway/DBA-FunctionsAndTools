SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--#################################################################################################
-- vwActiveDirectorySummary, rollup of data, underlying table populated by a powershell script and Scheduled job three times a week
--#################################################################################################
Create View [dbo].[vwActiveDirectorySummary]
As
    Select  [AD].[DomainName]
          , Count(*) As [TotalADUsers]
          , Sum(Case When ( [AD].[PasswordIsExpired] = 'True'
                            And [AD].[AccountIsEnabled] = 'True'
                          )
                          Or [AD].[AccountIsEnabled] = 'False' Then 1
                     Else 0
                End) As [IsDisabledOrLockedOut]
          , Sum(Case When [AD].[PasswordIsExpired] = 'True'
                          And [AD].[AccountIsEnabled] = 'False' Then 1
                     Else 0
                End) As [LockedOut]
          , Sum(Case When [AD].[AccountIsEnabled] = 'True' Then 1
                     Else 0
                End) As [IsDisabled]
          , Sum(Case When ( [AD].[PasswordIsExpired] = 'False'
                            And [AD].[AccountIsEnabled] = 'False'
                          ) Then 1
                     Else 0
                End) As [NotDisabledOrLockedOut]
          , Sum(Case When ( [AD].[PasswordIsExpired] = 'False'
                            And [AD].[AccountIsEnabled] = 'False'
                          )
                          And IsDate([AD].[LastLogonTimestamp]) = 0 Then 1
                     Else 0
                End) As [NeverLoggedIn]
          , Sum(Case When ( [AD].[PasswordIsExpired] = 'False'
                            And [AD].[AccountIsEnabled] = 'False'
                          )
                          And IsDate([AD].[LastLogonTimestamp]) = 1
                          And Convert(DateTime , [AD].[LastLogonTimestamp]) >= DateAdd(dd ,
                                                              -30 , GetDate())
                     Then 1
                     Else 0
                End) As [ActiveLast30Days]
          , Sum(Case When ( [AD].[PasswordIsExpired] = 'False'
                            And [AD].[AccountIsEnabled] = 'False'
                          )
                          And IsDate([AD].[LastLogonTimestamp]) = 1
                          And Convert(DateTime , [AD].[LastLogonTimestamp]) <= DateAdd(dd ,
                                                              -30 , GetDate())
                          And [AD].[PasswordIsExpired] = 'False'
                          And [AD].[AccountIsEnabled] = 'False' Then 1
                     Else 0
                End) As [NotActiveInMoreThan30Days]
          , '' As [Filler]
    From    [dbo].[GetActiveDirectoryUsers] [AD]
    Group By [AD].[DomainName];
GO

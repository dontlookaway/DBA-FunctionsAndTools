CREATE TABLE [dbo].[GetActiveDirectoryGroupMembers1]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[GroupCanonicalName] [varchar] (128) COLLATE Latin1_General_BIN NOT NULL,
[GroupSamAccountName] [varchar] (128) COLLATE Latin1_General_BIN NOT NULL,
[DomainName] AS (left([GroupCanonicalName],charindex('/',[GroupCanonicalName])-(1))),
[SamAccountName] [varchar] (128) COLLATE Latin1_General_BIN NOT NULL,
[ObjectClass] [varchar] (128) COLLATE Latin1_General_BIN NOT NULL,
[DWCreatedDate] [datetime] NULL CONSTRAINT [DF__GetActiveDirectoryGroupMembers__DWCreatedDate] DEFAULT (getdate()),
[DWUpdatedDate] [datetime] NULL,
[DWIsDeleted] [bit] NULL CONSTRAINT [DF__GetActiveDirectoryGroupMembers__DWIsDeleted] DEFAULT ((0)),
[DWDeletedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GetActiveDirectoryGroupMembers1] ADD CONSTRAINT [UQ_GetActiveDirectoryGroupMembers_GroupUserObject] UNIQUE CLUSTERED  ([GroupCanonicalName], [GroupSamAccountName], [SamAccountName], [ObjectClass]) ON [PRIMARY]
GO

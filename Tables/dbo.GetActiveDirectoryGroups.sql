CREATE TABLE [dbo].[GetActiveDirectoryGroups]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[CanonicalName] [varchar] (128) COLLATE Latin1_General_BIN NOT NULL,
[DomainName] AS (left([CanonicalName],charindex('/',[CanonicalName])-(1))),
[SamAccountName] [varchar] (128) COLLATE Latin1_General_BIN NOT NULL,
[DisplayName] [varchar] (128) COLLATE Latin1_General_BIN NULL,
[Description] [varchar] (128) COLLATE Latin1_General_BIN NULL,
[DistinguishedName] [varchar] (128) COLLATE Latin1_General_BIN NULL,
[GroupCategory] [varchar] (128) COLLATE Latin1_General_BIN NULL,
[GroupScope] [varchar] (128) COLLATE Latin1_General_BIN NULL,
[CreatedDate] [datetime] NULL,
[DWCreatedDate] [datetime] NULL CONSTRAINT [DF__GetActiveDirectoryGroups__DWCreatedDate] DEFAULT (getdate()),
[DWUpdatedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GetActiveDirectoryGroups] ADD CONSTRAINT [PK__GetActiveDirectoryGroups_SamAccountName] PRIMARY KEY CLUSTERED  ([CanonicalName], [SamAccountName]) ON [PRIMARY]
GO

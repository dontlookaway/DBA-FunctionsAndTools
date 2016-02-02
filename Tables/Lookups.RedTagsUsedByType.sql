CREATE TABLE [Lookups].[RedTagsUsedByType]
(
[UsedByType] [char] (1) COLLATE Latin1_General_BIN NOT NULL,
[UsedByDescription] [varchar] (150) COLLATE Latin1_General_BIN NULL
) ON [PRIMARY]
GO
ALTER TABLE [Lookups].[RedTagsUsedByType] ADD CONSTRAINT [PK__RedTagsU__F1E9B4D5919A4F38] PRIMARY KEY CLUSTERED  ([UsedByType]) ON [PRIMARY]
GO

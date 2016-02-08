CREATE TABLE [Lookups].[HolidayDays]
(
[Country] [varchar] (150) COLLATE Latin1_General_BIN NULL,
[HolidayDesc] [varchar] (200) COLLATE Latin1_General_BIN NULL,
[HolidayDate] [date] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [HolidayDays_Date] ON [Lookups].[HolidayDays] ([HolidayDate], [Country]) ON [PRIMARY]
GO

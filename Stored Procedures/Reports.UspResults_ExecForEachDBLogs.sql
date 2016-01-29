SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [Reports].[UspResults_ExecForEachDBLogs]
as
--get total number of logs for % calc
Declare @LogTotal Numeric(5,2)

Select @LogTotal=Count(Distinct [EFEDL].[LogID])
From [History].[ExecForEachDBLogs] As [EFEDL]

--Return results
Select  [LogDate] = Cast([EFEDL].[LogTime] As Date)
      , [DayOfTheWeek] = DateName(Weekday , [EFEDL].[LogTime])
      , [CountOfLogs] = Count(Distinct [EFEDL].[LogID])
	  , [CountOfLogsPercent] = (Count(Distinct [EFEDL].[LogID])/@LogTotal)*100
From    [History].[ExecForEachDBLogs] As [EFEDL]
Group By Cast([EFEDL].[LogTime] As Date)
      , DateName(Weekday , [EFEDL].[LogTime])
Order By [LogDate] Asc;

GO

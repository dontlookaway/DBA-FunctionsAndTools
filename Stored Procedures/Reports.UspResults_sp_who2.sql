
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Reports].[UspResults_sp_who2]
As
	Begin 
		Declare @Results Table
			(
				[SPID] Int
			, [Status] Varchar(Max)
			, [LOGIN] Varchar(Max)
			, [HostName] Varchar(Max)
			, [BlkBy] Varchar(Max)
			, [DBName] Varchar(Max)
			, [Command] Varchar(Max)
			, [CPUTime] Int
			, [DiskIO] Int
			, [LastBatch] Varchar(Max)
			, [ProgramName] Varchar(Max)
			, [SPID_1] Int
			, [REQUESTID] Int
			);

		Insert  Into @Results
				( [SPID]
				, [Status]
				, [LOGIN]
				, [HostName]
				, [BlkBy]
				, [DBName]
				, [Command]
				, [CPUTime]
				, [DiskIO]
				, [LastBatch]
				, [ProgramName]
				, [SPID_1]
				, [REQUESTID]
				)
				Exec [sys].[sp_who2];

		--Only show SPID once, show blocked processes first, followed by CPU time and DISK IO hoggers
		Select  [SPID]
				, [Status]
				, [LOGIN]
				, [HostName]
				, [BlkBy]
				, [DBName]
				, [Command]
				, [CPUTime]
				, [DiskIO]
				, [LastBatch]
				, [ProgramName]
				, [REQUESTID]
		From    @Results
		Order By [BlkBy] Asc
				, [CPUTime] Desc
				, [DiskIO] Desc
				, [SPID] Asc;
	End;
GO

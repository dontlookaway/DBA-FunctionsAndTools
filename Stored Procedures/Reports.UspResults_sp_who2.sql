SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [Reports].[UspResults_sp_who2]
 /*
Stored Procedure created by Chris Johnson
21st January 2016

The purpose of this stored procedure is to provide the results of sp_who2 in a better format, returning distinct fields and ordered by useful info
*/
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

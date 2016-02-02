SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Process].[UspInsert_RedTagLogs]
    (
      @StoredProcDb Varchar(255)
    , @StoredProcSchema Varchar(255)
    , @StoredProcName Varchar(255)
    , @UsedByType Char(1)
    , @UsedByName Varchar(500)
    , @UsedByDb Varchar(255)
    )
As /*
Created by Chris Johnson 2nd February 2016

Stored proc to insert logs
*/
    Begin
        Insert  [History].[RedTagLogs]
                ( [StoredProcDb]
                , [StoredProcSchema]
                , [StoredProcName]
                , [UsedByType]
                , [UsedByName]
                , [UsedByDb]
                )
                Select @StoredProcDb
				 , @StoredProcSchema
                      , @StoredProcName
                      , @UsedByType
                      , @UsedByName
                      , @UsedByDb;
    End;
GO

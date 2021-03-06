
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Reports].[UspResults_RedTagDetails]
/*
Stored procedure created by Chris Johnson 2nd to show all procs marked to be included in Red Tag review

*/
As --Get list of procs with Red Tag Type included in parameter
    Create Table [#Procs]
        (
          [SchemaName] Varchar(255)
        , [ProcedureName] Varchar(255)
        , [ParameterDetails] Varchar(Max)
        , [DatabaseName] Varchar(500)
        , [ExecScript] Varchar(Max)
        , [CreateScript] Varchar(Max)
        );

    Insert  [#Procs]
            ( [SchemaName]
            , [ProcedureName]
            , [ParameterDetails]
            , [DatabaseName]
            , [ExecScript]
            , [CreateScript]
            )
            Exec [Reports].[UspResults_SearchForProcedures] @DbSearch = '' ,
                @ProcedureSearch = '' , @SchemaSearch = '' ,
                @ParameterSearch = 'RedTagType';


--Provide results from Red Tag
    Select  [P].[DatabaseName]
          , [P].[SchemaName]
          , [P].[ProcedureName]
          , [P].[ParameterDetails]
          , [RTUBT].[UsedByDescription]
          , [CountOfRuns] = Count([RTL].[TagID])
          , [LatestRun] = Max([RTL].[TagDatetime])
          , [DaysSinceLastRun] = Case When Max([RTL].[TagDatetime]) Is Null
                                      Then 'Never run'
                                      Else Cast(DateDiff(Day ,
                                                         Max([RTL].[TagDatetime]) ,
                                                         GetDate()) As Varchar(10))
                                 End
          , [Rankings] = dense_rank() Over (Order By Case
                                                              When DateDiff(Day ,
                                                              Max([RTL].[TagDatetime]) ,
                                                              GetDate()) < 7
                                                              Then 1000000
                                                              + Count([RTL].[TagID])
                                                              When DateDiff(Day ,
                                                              Max([RTL].[TagDatetime]) ,
                                                              GetDate()) < 30
                                                              Then 900000
                                                              + Count([RTL].[TagID])
                                                              Else Count([RTL].[TagID])
                                                              End Desc )
    From    [#Procs] As [P]
            Left Join [History].[RedTagLogs] As [RTL] On [P].[DatabaseName] = [RTL].[StoredProcDb]
                                                         And [P].[ProcedureName] = [RTL].[StoredProcName]
                                                         And [P].[SchemaName] = [RTL].[StoredProcSchema]
            Left Join [Lookups].[RedTagsUsedByType] As [RTUBT] On [RTUBT].[UsedByType] = [RTL].[UsedByType]
    Group By [P].[SchemaName]
          , [P].[ProcedureName]
          , [P].[ParameterDetails]
          , [P].[DatabaseName]
          , [RTUBT].[UsedByDescription]
    Order By [Rankings] Asc;
    Drop Table [#Procs];
GO

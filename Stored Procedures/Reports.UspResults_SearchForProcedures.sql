SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Reports].[UspResults_SearchForProcedures]
    (
      @DbSearch Varchar(300)
    , @ProcedureSearch Varchar(150)
    , @SchemaSearch Varchar(150)
	, @ParameterSearch Varchar(150)
    )
As /*
Stored Procedure created by Chris Johnson
2nd February 2016

The purpose of this stored procedure is to search for stored procs by name, schema, parameters or database
*/
--Cater for nulls and append % that 
    Set @ParameterSearch = '%' + Coalesce(@ParameterSearch , '') + '%';
    Set @ProcedureSearch = '%' + Coalesce(@ProcedureSearch , '') + '%';
    Set @SchemaSearch = '%' + Coalesce(@SchemaSearch , '') + '%';
	Set @DbSearch = '%' + Coalesce(@DbSearch , '') + '%';

    Declare @SQLScript Varchar(max);

    Create Table [#ResultSets]
        (
          [SchemaName] Varchar(300)
        , [ProcedureName] Varchar(300)
        , [ParameterDetails] Varchar(Max)
        , [DatabaseName] Varchar(300)
        , [ExecScript] Varchar(Max) --script to get distinct values of returned column
        , [CreateScript] Varchar(Max) --script to get top 10 with all fields from table
        );


    Set @SQLScript = 'Use [?]; 
	If Lower(Db_Name()) Like lower('''+@DbSearch+''')
	begin
	Insert  [#ResultSets]
        ( [SchemaName]
        , [ProcedureName]
        , [ParameterDetails]
        , [DatabaseName]
        , [ExecScript]
        , [CreateScript]
        )
        Select  [SchemaName] = [S].[name]
              , [ProcedureName] = [P].[name]
              , [ParameterDetails] = Stuff(( Select Distinct
                                                    '', ''
                                                    + QuoteName([P2].[name])
                                             From   [sys].[parameters] As [P2]
                                             Where  [P2].[object_id] = [P].[object_id]
                                           For
                                             Xml Path('''')
                                           ) , 1 , 1 , '''')
              , [DatabaseName] = Db_Name()
              , [ExecScript] = ''exec '' + QuoteName([S].[name]) + ''.''
                + QuoteName([P].[name])
                + Coalesce(Stuff(( Select Distinct
                                            '', '' + QuoteName([P2].[name])
                                            + '' = ''
                                   From     [sys].[parameters] As [P2]
                                   Where    [P2].[object_id] = [P].[object_id]
                                 For
                                   Xml Path('''')
                                 ) , 1 , 1 , '''') , '''')
              , [CreateScript] = Object_Definition([P].[object_id])
        From    [sys].[procedures] As [P]
                Left Join [sys].[schemas] As [S] On [S].[schema_id] = [P].[schema_id]
        Where   Lower([S].[name]) Like Lower('''+@SchemaSearch+''')
                And Lower([P].[name]) Like Lower('''+@ProcedureSearch+''')
                And Lower(Stuff(( Select Distinct
                                            '', '' + QuoteName([P2].[name])
                                  From      [sys].[parameters] As [P2]
                                  Where     [P2].[object_id] = [P].[object_id]
                                For
                                  Xml Path('''')
                                ) , 1 , 1 , '''')) Like Lower('''+@ParameterSearch+''');
end';
 
  
    Exec [Process].[ExecForEachDB] @cmd = @SQLScript;
  

    Select  [RS].[SchemaName]
          , [RS].[ProcedureName]
          , [RS].[ParameterDetails]
          , [RS].[DatabaseName]
          , [RS].[ExecScript]
          , [RS].[CreateScript]
    From    [#ResultSets] As [RS];
GO

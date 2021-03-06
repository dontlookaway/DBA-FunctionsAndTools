
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Reports].[UspResults_SearchForTables]
    (
      @ColumnSearch Varchar(150)
    , @TableSearch Varchar(150)
    , @SchemaSearch Varchar(150)
    , @DBSearch Varchar(150)
    )
As /*
Stored Procedure created by Chris Johnson
21st January 2016

The purpose of this stored procedure is to search for columns in tables returning scripts
*/
--Cater for nulls and append % that 
    Set @ColumnSearch = '%' + Coalesce(@ColumnSearch , '') + '%';
    Set @TableSearch = '%' + Coalesce(@TableSearch , '') + '%';
    Set @SchemaSearch = '%' + Coalesce(@SchemaSearch , '') + '%';
    Set @DBSearch = '%' + Coalesce(@DBSearch , '') + '%';

    Declare @SQLScript Varchar(2000);

    Create Table [#ResultSets]
        (
          [SchemaName] Varchar(300)
        , [TableName] Varchar(300)
        , [ColumnName] Varchar(150)
        , [DatabaseName] Varchar(300)
        , [AllColumns] Varchar(Max) --list of all columns in table
        , [DistinctScript] Varchar(Max) --script to get distinct values of returned column
        , [Top10Script] Varchar(Max) --script to get top 10 with all fields from table
        );

    Set @SQLScript = 'Use [?]; 
	If  Lower(Db_Name()) Like Lower(''' +@DBSearch+ ''')
	Begin
		Insert  [#ResultSets] ( [SchemaName], [TableName], [ColumnName], [DatabaseName], [AllColumns], [DistinctScript], [Top10Script])
		Select  [SchemaName] = QuoteName([S].[name])
				, [TableName] = QuoteName([T].[name])
				, [ColumnName] = QuoteName([C].[name])
				, [DatabaseName] = QuoteName(db_name())
				, [AllColumns] = Stuff(( Select Distinct
												'', ''
												+ QuoteName([C2].[name])
										From     [sys].[columns] [C2]
										Where    [C2].[object_id] = [C].[object_id]
										For
										Xml Path('''')
										) , 1 , 1 , '''')
				, [DistinctScript] = ''Select distinct ''
				+ QuoteName([C].[name]) + '' from '' + QuoteName([S].[name])
				+ ''.'' + QuoteName([T].[name])
				, [Top10Script] = ''Select Top 10 ''
				+ Stuff(( Select Distinct
									'', '' + QuoteName([C2].[name])
							From      [sys].[columns] [C2]
							Where     [C2].[object_id] = [C].[object_id]
						For
							Xml Path('''')
						) , 1 , 1 , '''') + '' from '' + [S].[name] + ''.''
				+ [T].[name]
		From    [sys].[columns] [C]
				Inner Join [sys].[tables] [T] On [T].[object_id] = [C].[object_id]
				Inner Join [sys].[schemas] [S] On [S].[schema_id] = [T].[schema_id]
		Where   Lower([C].[name]) Like Lower(''' +@ColumnSearch+ ''')
				And Lower([T].[name]) Like Lower(''' +@TableSearch+ ''')
				And Lower([S].[name]) Like Lower(''' +@SchemaSearch+ '''); 
	end';
 
  
    Exec [Process].[ExecForEachDB] @cmd = @SQLScript;
  

    Select  [RS].[DatabaseName]
          , [RS].[SchemaName]
          , [RS].[TableName]
          , [RS].[ColumnName]
          , [RS].[AllColumns]
          , [RS].[DistinctScript]
          , [RS].[Top10Script]
    From    [#ResultSets] As [RS];
GO

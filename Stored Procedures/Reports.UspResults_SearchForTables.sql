SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [Reports].[UspResults_SearchForTables]
    (
      @ColumnSearch Varchar(150)
    , @TableSearch Varchar(150)
    , @SchemaSearch Varchar(150)
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

    Create Table [#ResultSets]
        (
          [SchemaName] Varchar(300)
        , [TableName] Varchar(300)
        , [ColumnName] Varchar(150)
        , [AllColumns] Varchar(Max) --list of all columns in table
        , [DistinctScript] Varchar(Max) --script to get distinct values of returned column
        , [Top10Script] Varchar(Max) --script to get top 10 with all fields from table
        );

    Insert  [#ResultSets]
            ( [SchemaName]
            , [TableName]
            , [ColumnName]
            , [AllColumns]
            , [DistinctScript]
            , [Top10Script]
	        )
            Select  [SchemaName] = QuoteName([S].[name]) --The QuoteName function returns the value ready for SQL e.g. [Field !324342]
                  , [TableName] = QuoteName([T].[name])
                  , [ColumnName] = QuoteName([C].[name])
                  , [AllColumns] = Stuff(( Select Distinct
                                                    ', '
                                                    + QuoteName([C2].[name])
                                           From     [sys].[columns] [C2]
                                           Where    [C2].[object_id] = [C].[object_id]
                                         For
                                           Xml Path('')
                                         ) , 1 , 1 , '')
                  , [DistinctScript] = 'Select distinct '
                    + QuoteName([C].[name]) + ' from ' + QuoteName([S].[name])
                    + '.' + QuoteName([T].[name])
                  , [Top10Script] = 'Select Top 10 '
                    + Stuff(( Select Distinct
                                        ', ' + QuoteName([C2].[name])
                              From      [sys].[columns] [C2]
                              Where     [C2].[object_id] = [C].[object_id]
                            For
                              Xml Path('')
                            ) , 1 , 1 , '') + ' from ' + [S].[name] + '.'
                    + [T].[name]
            From    [sys].[columns] [C]
                    Inner Join [sys].[tables] [T] On [T].[object_id] = [C].[object_id]
                    Inner Join [sys].[schemas] [S] On [S].[schema_id] = [T].[schema_id]
            Where   Lower([C].[name]) Like Lower(@ColumnSearch)
                    And Lower([T].[name]) Like Lower(@TableSearch)
                    And Lower([S].[name]) Like Lower(@SchemaSearch); --cast as lower to cater for case sensitive db's
 
  
    Select  [RS].[SchemaName]
          , [RS].[TableName]
          , [RS].[ColumnName]
          , [RS].[AllColumns]
          , [RS].[DistinctScript]
          , [RS].[Top10Script]
    From    [#ResultSets] As [RS];
GO

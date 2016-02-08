SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Reports].[UspResults_SearchForMissingIndexes] ( @DbSearch Varchar(300) )
As /*
Stored Procedure created by Chris Johnson
3rd February 2016

The purpose of this stored procedure is to search for missing indexes
Based off work here - http://blog.sqlauthority.com/2011/01/03/sql-server-2008-missing-index-script-download/
*/
--Cater for nulls and append % 
    Set @DbSearch = '%' + Coalesce(@DbSearch , '') + '%';

    Declare @SQLScript Varchar(Max);

    Create Table [#ResultSets]
        (
          [DatabaseName] Varchar(300)
        , [AvgEstimatedImpact] Float
        , [LastUserSeek] DateTime2
        , [UserScans] BigInt
        , [UserSeeks] BigInt
        , [AvgUserImpact] Float
        , [TableName] Varchar(500)
        , [Create_Statement] Varchar(Max)
        );






    Set @SQLScript = '		Insert [#ResultSets]
		        ( [DatabaseName]
		        , [AvgEstimatedImpact]
		        , [LastUserSeek]
		        , [UserScans]
		        , [UserSeeks]
		        , [AvgUserImpact]
		        , [TableName]
		        , [Create_Statement]
		        )
				Select  [DatabaseName] = [d].[name]
      , [AvgEstimatedImpact] = [dm_migs].[avg_user_impact]
							* ( [dm_migs].[user_seeks] + [dm_migs].[user_scans] )
      , [LastUserSeek]		= [dm_migs].[last_user_seek]
      , [UserScans]			= [dm_migs].[user_scans]
      , [UserSeeks]			= [dm_migs].[user_seeks]
      , [AvgUserImpact]		= [dm_migs].[avg_user_impact]
      , [TableName]			= Object_Name([dm_mid].[object_id] ,
                                  [dm_mid].[database_id])
      , [Create_Statement] = ''CREATE INDEX '' + Replace(QuoteName(''IX_''
                                                              + Object_Name([dm_mid].[object_id] ,
                                                              [dm_mid].[database_id])
                                                              + ''_''
                                                              + Replace(Replace(Replace(Replace(Coalesce([dm_mid].[equality_columns]
                                                              + '', '' , '''')
                                                              + Coalesce([dm_mid].[inequality_columns] ,
                                                              '''') , ''], ['' ,
                                                              ''_'') , ''['' , '''') ,
                                                              '']'' , '''') , '','' ,
                                                              '''')) , '' '' , '''')
        + '' ON '' + [dm_mid].[statement] + '' (''
        + Replace(Replace(Coalesce([dm_mid].[equality_columns] + ''_'' , '''')
                          + Coalesce([dm_mid].[inequality_columns] , '''') + '')'' ,
                          '']_['' , ''],['') , ''_'' , '''') + Coalesce('' INCLUDE (''
                                                              + [dm_mid].[included_columns]
                                                              + '')'' , '''')
From    [sys].[dm_db_missing_index_groups] [dm_mig]
        Inner Join [sys].[dm_db_missing_index_group_stats] [dm_migs] On [dm_migs].[group_handle] = [dm_mig].[index_group_handle]
        Inner Join [sys].[dm_db_missing_index_details] [dm_mid] On [dm_mig].[index_handle] = [dm_mid].[index_handle]
        Inner Join [sys].[databases] [d] On [d].[database_id] = [dm_mid].[database_id]

        Where   Lower([d].[name]) Like Lower(''' + @DbSearch + ''');';
 
  Print @SQLScript
    Exec (@SQLScript)
  

    Select  [RS].[DatabaseName]
          , [RS].[AvgEstimatedImpact]
          , [RS].[LastUserSeek]
          , [RS].[UserScans]
          , [RS].[UserSeeks]
          , [RS].[AvgUserImpact]
          , [RS].[TableName]
          , [RS].[Create_Statement]
    From    [#ResultSets] As [RS]
	Where [RS].[TableName] Is Not Null
	Order By [RS].[AvgEstimatedImpact] Desc;
GO

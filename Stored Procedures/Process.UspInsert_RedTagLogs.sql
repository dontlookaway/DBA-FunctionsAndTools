
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
		--create schemas if needed
        If Exists ( Select  1
                    From    [sys].[schemas] As [S]
                    Where   [S].[name] = 'Reports' )
            Begin
                Declare @Schema1 Varchar(500)= 'Create Schema Reports';
                Exec (@Schema1);
            End;
        If Exists ( Select  1
                    From    [sys].[schemas] As [S]
                    Where   [S].[name] = 'History' )
            Begin
                Declare @Schema2 Varchar(500)= 'Create Schema History';
                Exec (@Schema2);
            End;
        If Exists ( Select  1
                    From    [sys].[schemas] As [S]
                    Where   [S].[name] = 'Lookups' )
            Begin
                Declare @Schema3 Varchar(500)= 'Create Schema Lookups';
                Exec (@Schema2);
            End;
		--create tables to capture logs
        If Not Exists ( Select  1
                        From    [sys].[tables] As [T]
                                Left Join [sys].[schemas] As [S] On [S].[schema_id] = [T].[schema_id]
                        Where   [T].[name] = 'RedTagsUsedByType'
                                And [S].[name] = 'Lookups' )
            Begin
                Create Table [Lookups].[RedTagsUsedByType]
                    (
                      [UsedByType] [Char](1) Not Null
                    , [UsedByDescription] [Varchar](150) Null
                    , Primary Key Clustered ( [UsedByType] Asc )
                        With ( Pad_Index = Off , Statistics_Norecompute = Off ,
                               Ignore_Dup_Key = Off , Allow_Row_Locks = On ,
                               Allow_Page_Locks = On ) On [PRIMARY]
                    )
                On  [PRIMARY];
            End;
        If Not Exists ( Select  1
                        From    [sys].[tables] As [T]
                                Left Join [sys].[schemas] As [S] On [S].[schema_id] = [T].[schema_id]
                        Where   [T].[name] = 'RedTagLogs'
                                And [S].[name] = 'History' )
            Begin
                Create Table [History].[RedTagLogs]
                    (
                      [TagID] [Int] Identity(1 , 1)
                                    Not Null
                    , [TagDatetime] [DateTime2](7) Null
                                                   Default ( GetDate() )
                    , [StoredProcDb] [Varchar](255) Null
                    , [StoredProcSchema] [Varchar](255) Null
                    , [StoredProcName] [Varchar](255) Null
                    , [UsedByType] [Char](1)
                        Null
                        Foreign Key References [Lookups].[RedTagsUsedByType] ( [UsedByType] )
                    , [UsedByName] [Varchar](500) Null
                    , [UsedByDb] [Varchar](255) Null
                    )
                On  [PRIMARY];
            End;
        
		--Insert logs
        If Exists ( Select  1
                    From    [sys].[tables] As [T]
                            Left Join [sys].[schemas] As [S] On [S].[schema_id] = [T].[schema_id]
                    Where   [T].[name] = 'RedTagLogs'
                            And [S].[name] = 'History' )
            Begin		
                Begin Try
                    Insert  [History].[RedTagLogs]
                            ( [StoredProcDb]
                            , [StoredProcSchema]
                            , [StoredProcName]
                            , [UsedByType]
                            , [UsedByName]
                            , [UsedByDb]
                            )
                            Select  @StoredProcDb
                                  , @StoredProcSchema
                                  , @StoredProcName
                                  , @UsedByType
                                  , @UsedByName
                                  , @UsedByDb;
                End Try
                Begin Catch
                    Raiserror('Red Tag error - failed to insert log',16,4);
                End Catch;
            End;
        --Raise Error if table doesn't exist
        If Not Exists ( Select  1
                        From    [sys].[tables] As [T]
                                Left Join [sys].[schemas] As [S] On [S].[schema_id] = [T].[schema_id]
                        Where   [T].[name] = 'RedTagLogs'
                                And [S].[name] = 'History' )
            Begin
                Raiserror ('Red tag logs failure - tables do not exist',16,4);
            End;
    End;
GO

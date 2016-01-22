
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Process].[ExecForEachDB] ( @cmd NVarchar(Max) )
As /*
Stored Procedure created by Chris Johnson
20th January 2016

The purpose of this stored procedure is to replace the undocumented procedure sp_MSforeachdb as this may be removed in future versions
of SQL Server. The stored procedure iterates through all user databases and executes the code passed to it.

Based off of http://sqlblog.com/blogs/aaron_bertrand/archive/2010/02/08/bad-habits-to-kick-relying-on-undocumented-behavior.aspx  
*/
    Begin
        Set NoCount On;
	
	--Declare variables
        Declare @SqlScript NVarchar(Max)= ''
          , @Database NVarchar(257)=''
          , @ErrorMessage NVarchar(Max)='';

	--Try to create Logging table (if permissions to create exist)
        If Not Exists ( Select  1
                        From    [sys].[tables] [T]
                                Left Join [sys].[schemas] As [S] On [S].[schema_id] = [T].[schema_id]
                        Where   [S].[name] = 'History'
                                And [T].[name] = 'ExecForEachDBLogs' )
            Begin
                Begin Try
                    Create Table [History].[ExecForEachDBLogs]
                        (
                          [LogID] BigInt Identity(1 , 1)
                        , [LogTime] DateTime2 Default GetDate()
                        , [Cmd] NVarchar(2000)
                        );
                End Try
                Begin Catch
                    Print 'unable to create logging table';
                End Catch;
            End;

	--Add Logging details
        If Object_Id('[History].[ExecForEachDBLogs]') Is Not Null
            Begin
                Begin Try
                    Insert  [History].[ExecForEachDBLogs]
                            ( [Cmd] )
                    Values  ( @cmd );
                End Try
                Begin Catch
                    Print 'unable to capture logging details';
                End Catch;
            End;

	--Try to create error Logging table (if permissions to create exist)
        If Not Exists ( Select  1
                        From    [sys].[tables] [T]
                                Left Join [sys].[schemas] As [S] On [S].[schema_id] = [T].[schema_id]
                        Where   [S].[name] = 'History'
                                And [T].[name] = 'ExecForEachDBErrorLogs' )
            Begin
                Begin Try
                    Create Table [History].[ExecForEachDBErrorLogs]
                        (
                          [LogID] BigInt Identity(1 , 1)
                        , [LogTime] DateTime2 Default GetDate()
                        , [Error] NVarchar(2000)
                        );
                End Try
                Begin Catch
                    Print 'unable to create error logging table';
                End Catch;
            End;


	--Test validity, all scripts should contain a "?" to be used in place of a db name
        If @cmd Not Like '%?%'
            Begin
                Set @ErrorMessage = Cast('' As NVarchar(max))
				Set @ErrorMessage = @ErrorMessage+'ExecForEachDB failed, script does not contain the string "?" '
                    + @cmd;

                --If is included as permissions may not be available to create this table
                If Object_Id('[History].[ExecForEachDBLogs]') Is Not Null
                    Begin
                        Insert  [History].[ExecForEachDBErrorLogs]
                                ( [Error] )
                        Values  ( @ErrorMessage );
                    End;
                
                If Object_Id('[History].[ExecForEachDBLogs]') Is Null
                    Begin
                        Raiserror ('** Warning - Errors are not being logged **',1,1); --if Errors are not being logged raise a low level error
                    End;
                Raiserror (@ErrorMessage,13,1);
            End;
    
        If @cmd Like '%?%' 
            Begin
	--Use Cursor to hold list of databases to execute against
                Declare [DbNames] Cursor Local Forward_Only Static Read_Only
                For
                    Select  QuoteName([name])
                    From    [sys].[databases]
                    Where   [state] = 0 --online databases
                            And [is_read_only] = 0 --only databases that can be executed against
                            And [database_id] > 4 --only user databases
							And has_dbaccess([name]) = 1 --only dbs current user has access to
                    Order By [name];

                Open [DbNames];
    
                Fetch Next From [DbNames] Into @Database; --Get first database to execute against

                While @@fetch_status = 0 --when fetch is successful
                    Begin
                        Set @SqlScript = Cast('' As NVarchar(Max));
                        Set @SqlScript = @SqlScript
                            + Replace(Replace(Replace(@cmd , '?' , @Database) ,
                                              '[[' , '[') , ']]' , ']');--[[ & ]] caused by script including [?]
                        Begin Try 
                            Exec(@SqlScript);
                        End Try
                        Begin Catch --if error happens against any db, raise a high level error advising the database and print the script
                            Set @ErrorMessage = Cast('' As NVarchar(max))
							Set @ErrorMessage = @ErrorMessage + 'Script failed against database '
                                + @Database;
                            Raiserror (@ErrorMessage,13,1);
                            Print @SqlScript;
                        End Catch;

                        Fetch Next From [DbNames] Into @Database;--Get next database to execute against
                    End;

                Close [DbNames];
                Deallocate [DbNames];
            End;
    End;
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [Process].[ExecForEachDB] 
( @cmd NVarchar(2000) )--limited to 2000 characters as script errors occur trying to execute scripts with more characters
As /*
Stored Procedure created by Chris Johnson
20th January 2016

The purpose of this stored procedure is to replace the undocumented procedure sp_MSforeachdb as this may be removed in future versions
of SQL Server. The stored procedure iterates through all user databases and executes the code passed to it.

Based off of http://sqlblog.com/blogs/aaron_bertrand/archive/2010/02/08/bad-habits-to-kick-relying-on-undocumented-behavior.aspx  
*/
    Begin
        Set NoCount On;
	
	--Try to create Logging table
        If Not Exists ( Select  *
                        From    [sys].[tables] [T]
                                Left Join [sys].[schemas] As [S] On [S].[schema_id] = [T].[schema_id]
                        Where   [S].[name] = 'dbo'
                                And [T].[name] = 'ExecForEachDBLogs' )
            Begin
                Begin Try
                    Create Table [dbo].[ExecForEachDBLogs]
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
        If Exists ( Select  *
                    From    [sys].[tables] [T]
                            Left Join [sys].[schemas] As [S] On [S].[schema_id] = [T].[schema_id]
                    Where   [S].[name] = 'dbo'
                            And [T].[name] = 'ExecForEachDBLogs' )
            Begin
                Begin Try
                    Insert  [dbo].[ExecForEachDBLogs]
                            ( [Cmd] )
                    Values  ( @cmd );
                End Try
                Begin Catch
                    Print 'unable to capture logging details';
                End Catch;
            End;

	--Declare variables, SqlScript is for 
        Declare @SqlScript NVarchar(Max)
          , @Database NVarchar(257)
          , @ErrorMessage NVarchar(500);

	--Test validity, all scripts should contain a "?" to be used in place of a db name
        If @cmd Not Like '%?%'
            Begin
                Set @ErrorMessage = 'ExecForEachDB failed, script does not contain the string "?" '
                    + @cmd;
                Raiserror (@ErrorMessage,13,1);
            End;
    
        If @cmd Like '%?%'
            Begin
	--Use Cursor to hold list of databases to execute against
                Declare [DbNames] Cursor Local Forward_Only Static Read_Only
                For
                    Select  QuoteName([name])
                    From    [sys].[databases]
                    Where   [state] = 0 --only online databases
                            And [is_read_only] = 0 --only databases that can be executed against
                            And [database_id] > 4 --only user databases
                    Order By [name];

                Open [DbNames];
    
                Fetch Next From [DbNames] Into @Database; --Get next database to execute against

                While @@fetch_status = 0 --when fetch is successful
                    Begin
                        Set @SqlScript = Replace(Replace(Replace(@cmd , '?' ,
                                                              @Database) ,
                                                         '[[' , '[') , ']]' ,
                                                 ']');--Adds the database name
						--Print @SqlScript;
                        Begin Try --try to execute script
                            Exec(@SqlScript);
                        End Try
                        Begin Catch --if error happens against any db, raise a high level error advising the database and print the script
                            Set @ErrorMessage = 'Script failed against database '
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


SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [Process].[UspUpdate_SPDefinitions]
(@SqlToReplace NVarchar(max)
,@Replacement NVarchar(max))
As
/*
Stored procedure created by Chris Johnson
22nd January 2016

Procedure to find and replace strings within proc definitions for manual run by DBA
*/
Begin
Declare @StoredProc Varchar(500)='', @SqlToSearch NVarchar(Max)='',@SqlScript NVarchar(Max)='', @ErrorMessage NVarchar(max)
Select @SqlToSearch = Cast('%' As NVarchar(max))+@SqlToReplace+Cast('%' As NVarchar(max));

--log of changes
CREATE TABLE #SpChanges
(ProcName NVarchar(max)
,OriginalDef NVarchar(max) 
,NewDef NVarchar(max)
)

Insert [#SpChanges]
        ( [ProcName]
        , [OriginalDef]
        , [NewDef]
        )
Values  ( N'WARNING'  -- ProcName - nvarchar(max)
        , N'DO NOT RUN THESE DEFINITIONS WITHOUT CHECKING'  -- OriginalDef - nvarchar(max)
        , N'DO NOT RUN THESE DEFINITIONS WITHOUT CHECKING'  -- NewDef - nvarchar(max)
        )

Declare StoredProcs Cursor Local Forward_Only Static Read_Only
                For
                    Select  [P].[object_id]
                    From    [sys].[procedures] As [P]
					Left Join sys.[schemas] As [S] On [S].[schema_id] = [P].[schema_id]
                    Where   Object_Definition([P].[object_id]) Like @SqlToSearch
                    ;

                Open StoredProcs;
    
                Fetch Next From StoredProcs Into @StoredProc; --Get first SP to execute against

                While @@fetch_status = 0 --when fetch is successful
                    Begin
                        Set @SqlScript = Cast('' As NVarchar(Max));
                        Set @SqlScript = Object_Name(@StoredProc)
                        Begin Try 
                            Insert [#SpChanges]
                                    ( [ProcName]
                                    , [OriginalDef]
                                    , [NewDef]
                                    )
							Select Object_Name(@StoredProc)
									,Object_Definition(@StoredProc)
									,Replace(Replace(Object_Definition(@StoredProc),@SqlToReplace,@Replacement),'CREATE ','ALTER ')
                        End Try
                        Begin Catch --if error happens against any db, raise a high level error advising the database and print the script
                            Set @ErrorMessage = Cast('' As NVarchar(max))
							Set @ErrorMessage = @ErrorMessage + 'Script failed against proc'
                                + Object_Name(@StoredProc);
                            Raiserror (@ErrorMessage,13,1);
                            Print @SqlScript;
                        End Catch;

                        Fetch Next From StoredProcs Into @StoredProc;--Get next database to execute against
                    End;

                Close StoredProcs;
                Deallocate StoredProcs;

--Return Procs that can be altered
Select [SC].[ProcName]
     , [SC].[OriginalDef]
     , [SC].[NewDef] FROM [#SpChanges] As [SC]


END
GO

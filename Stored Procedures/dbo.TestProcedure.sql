SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[TestProcedure]
(@TextToRun Varchar(max)
,@RedTagType Char(1)
,@RedTagUse Varchar(500))
/*
Procedure used to test and display procs developed
*/
As
Begin
	Declare @RedTagDB Varchar(255)=Db_Name()
	Exec [Process].[UspInsert_RedTagLogs] @StoredProcSchema = 'dbo' , -- varchar(255)
	    @StoredProcName = 'TestProcedure' , -- varchar(255)
	    @UsedByType = @RedTagType ,
	    @UsedByName = @RedTagUse , 
	    @UsedByDb = @RedTagDB -- varchar(255)
	
    Exec [Process].[ExecForEachDB] @cmd = @TextToRun
End
GO

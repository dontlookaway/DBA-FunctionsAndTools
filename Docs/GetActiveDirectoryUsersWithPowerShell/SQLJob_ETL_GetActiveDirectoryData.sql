  --###############################################################################################
  --job Grabs Active Directory Users,Groups and Group members MWF
  --###############################################################################################
  DECLARE @JobName              sysname;
  DECLARE @JobDescription       nvarchar(512)
  DECLARE @JobCommand           nvarchar(MAX);

  SET @JobName=N'ETL: GetActiveDirectoryUsers';
  SET @JobDescription=@JobName;

      --optiona code Drop the job so it can be rebuilt.
    IF EXISTS(SELECT * FROM msdb.dbo.sysjobs WHERE name=@JobName)
      EXEC sp_delete_job @job_name = @JobName;
    IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE [name] = @JobName)
    BEGIN
        EXECUTE msdb.dbo.sp_add_job         @job_name = @JobName, @enabled=1, @notify_level_eventlog=2, @notify_level_email=1, @notify_level_netsend=0, @notify_level_page=0, @delete_level=0, @description=@JobDescription, @owner_login_name=N'sa';
        EXECUTE msdb.dbo.sp_add_jobserver   @job_name = @JobName, @server_name = @@SERVERNAME;

        --add the job steps
        -----------------------------------------------------------------------------------------------------------------------------------------------------
        EXECUTE msdb.dbo.sp_add_jobstep @job_name = @JobName, @step_name=N'Powershell L:\SSIS\PowerShellActiveDirectory\GetActiveDirectoryUsers.ps1', 
            @cmdexec_success_code=0,
            @on_success_action=3,@on_success_step_id=0, --no error, go to next step
            @on_fail_action=2, @on_fail_step_id=0, @retry_attempts=0, @retry_interval=0, --on error, fail
            @os_run_priority=0, @subsystem=N'CmdExec', 
            @command=N'Powershell.exe L:\SSIS\PowerShellActiveDirectory\GetActiveDirectoryUsers.ps1', 
            @flags=0, 
            @proxy_name=N'TaskRunner';
       EXECUTE msdb.dbo.sp_add_jobstep @job_name = @JobName, @step_name=N'Powershell L:\SSIS\PowerShellActiveDirectory\GetActiveDirectoryGroups.ps1', 
            @cmdexec_success_code=0,@on_success_action=3,@on_success_step_id=0,--no error, go to next step
             @on_fail_action=2, @on_fail_step_id=0, @retry_attempts=0, @retry_interval=0, --on error, fail
            @os_run_priority=0, @subsystem=N'CmdExec', 
            @command=N'Powershell.exe L:\SSIS\PowerShellActiveDirectory\GetActiveDirectoryGroups.ps1', 
            @flags=0, 
            @proxy_name=N'TaskRunner';
        --add a tail job step
        --#############################################
        EXECUTE msdb.dbo.sp_add_jobstep     @job_name = @JobName, @step_name=N'Report Success Or Failure', @cmdexec_success_code=0, @on_success_action=1, @on_success_step_id=0, @on_fail_action=2, @on_fail_step_id=0, @retry_attempts=0, @retry_interval=0, @os_run_priority=0, @subsystem=N'TSQL', @command='SELECT @@SERVERNAME', @database_name=N'master', @flags=0;
        EXECUTE msdb.dbo.sp_update_job      @job_name = @JobName, @start_step_id = 1;
        --add the job schedule
        -----------------------------------------------------------------------------------------------------------------------------------------------------
        EXECUTE msdb.dbo.sp_add_jobschedule @job_name = @JobName, @name=N'MWF', 
          @enabled=1,@freq_type=8,@freq_interval=43,@freq_subday_type=1, @freq_subday_interval=0, @freq_relative_interval=0, 
          @freq_recurrence_factor=1,@active_start_date=20150923, @active_end_date=99991231, 
          @active_start_time=102000, --10:20am
          @active_end_time=235959;

        --EXECUTE msdb.dbo.sp_update_job      @job_name = @JobName, @notify_level_email=2, @notify_level_netsend=2, @notify_level_page=2;
    END --IF
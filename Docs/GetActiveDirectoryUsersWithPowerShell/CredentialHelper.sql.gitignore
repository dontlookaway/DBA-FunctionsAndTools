USE msdb;
GO
--Dependency: this credential must exist:
DECLARE @CredentialNickName varchar(128) = 'TaskRunner'
  IF NOT EXISTS(SELECT * FROM sys.credentials WHERE name = @CredentialNickName)
    BEGIN
      DECLARE @cmd VARCHAR(max);
      SELECT @cmd = 'CREATE CREDENTIAL ' + @CredentialNickName + ' WITH IDENTITY = ''MyDomain\SomeAccount'', SECRET = ''NotTh3RealPassword!'';';
      EXEC(@cmd)
    END
--#################################################################################################
-- Create The proxy for our new Credential
--#################################################################################################

  IF NOT EXISTS(SELECT * FROM msdb.dbo.sysproxies WHERE name = @CredentialNickName)
    BEGIN
      EXECUTE msdb.dbo.sp_add_proxy @proxy_name=@CredentialNickName, @credential_name=@CredentialNickName,@enabled=1
    END
--#################################################################################################
--powershell subsystem: add permissions if not existing
--#################################################################################################
  DECLARE @isql VARCHAR(2000),
          @subsystemid VARCHAR(64)
  DECLARE c1 CURSOR FOR 
      SELECT 
        subz.subsystem_id  
      FROM msdb.dbo.syssubsystems subz
        LEFT OUTER JOIN (SELECT 
                          mapz.subsystem_id
                         FROM msdb.dbo.sysproxysubsystem mapz 
                           INNER JOIN msdb.dbo.sysproxies proxz 
                             ON mapz.proxy_id = proxz.proxy_id
                         WHERE proxz.name = @CredentialNickName
                        ) X
          ON subz.subsystem_id=X.subsystem_id
      WHERE X.subsystem_id IS NULL
        AND subz.subsystem_dll <> '[Internal]' --no proxy for internal methods!
        AND subz.subsystem IN('PowerShell','CmdExec') --limiting just to PowerShell
  OPEN c1
  FETCH NEXT FROM c1 INTO @subsystemid
  WHILE @@FETCH_STATUS <> -1 AND @subsystemid IS NOT NULL
    BEGIN
      SELECT @isql = 'EXECUTE msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N''' + @CredentialNickName + ''', @subsystem_id= ' + @subsystemid + ';'
      PRINT @isql
      EXEC(@isql)
      FETCH NEXT FROM c1 INTO @subsystemid
    END
  CLOSE c1
  DEALLOCATE c1
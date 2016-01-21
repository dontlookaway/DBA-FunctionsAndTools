IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'Limited')
CREATE LOGIN [Limited] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [Limited] FOR LOGIN [Limited]
GO
EXEC sp_addextendedproperty N'MS_Description', N'User created with read permissions only for testing SP''s as normal user', 'USER', N'Limited', NULL, NULL, NULL, NULL
GO

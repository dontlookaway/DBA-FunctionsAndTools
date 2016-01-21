IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'Limited')
CREATE LOGIN [Limited] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [Limited] FOR LOGIN [Limited]
GO

CREATE SCHEMA [Process]
AUTHORIZATION [dbo]
GO

GRANT EXECUTE ON SCHEMA:: [Process] TO [Limited]
GO

EXEC sp_addextendedproperty N'MS_Description', N'Holds items that can be actioned or run regularly but do not return results', 'SCHEMA', N'Process', NULL, NULL, NULL, NULL
GO

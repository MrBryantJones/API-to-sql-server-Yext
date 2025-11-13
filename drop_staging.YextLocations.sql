USE [Marketing]
GO

/****** Object:  Table [staging].[YextLocations]    Script Date: 11/12/2025 5:00:55 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[staging].[YextLocations]') AND type in (N'U'))
DROP TABLE [staging].[YextLocations]
GO



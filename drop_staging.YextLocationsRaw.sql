USE [Marketing]
GO

/****** Object:  Table [staging].[YextLocationsRaw]    Script Date: 11/12/2025 5:01:53 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[staging].[YextLocationsRaw]') AND type in (N'U'))
DROP TABLE [staging].[YextLocationsRaw]
GO



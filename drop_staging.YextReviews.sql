USE [Marketing]
GO

/****** Object:  Table [staging].[YextReviews]    Script Date: 11/12/2025 5:03:26 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[staging].[YextReviews]') AND type in (N'U'))
DROP TABLE [staging].[YextReviews]
GO



USE [Marketing]
GO

/****** Object:  Table [staging].[YextLocationsRaw]    Script Date: 10/24/2025 4:04:39 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[staging].[YextLocationsRaw]') AND type in (N'U'))
DROP TABLE [staging].[YextLocationsRaw]
GO

/****** Object:  Table [staging].[YextLocationsRaw]    Script Date: 10/24/2025 4:04:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [staging].[YextLocationsRaw](
	[Id] [nvarchar](100) NOT NULL,
	[RawJson] [nvarchar](max) NOT NULL,
	[IngestedAt] [datetime2](3) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO



USE [Marketing]
GO

/****** Object:  Table [staging].[YextLocations]    Script Date: 10/24/2025 4:04:35 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[staging].[YextLocations]') AND type in (N'U'))
DROP TABLE [staging].[YextLocations]
GO

/****** Object:  Table [staging].[YextLocations]    Script Date: 10/24/2025 4:04:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [staging].[YextLocations](
	[Id] [nvarchar](50) NULL,
	[Name] [nvarchar](255) NULL,
	[AddressLine1] [nvarchar](255) NULL,
	[City] [nvarchar](100) NULL,
	[Region] [nvarchar](50) NULL,
	[PostalCode] [nvarchar](20) NULL,
	[CountryCode] [nvarchar](10) NULL,
	[MainPhone] [nvarchar](50) NULL,
	[WebsiteUrl] [nvarchar](500) NULL,
	[Description] [nvarchar](max) NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[LastUpdated] [datetime] NULL,
	[SystemLoadDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO



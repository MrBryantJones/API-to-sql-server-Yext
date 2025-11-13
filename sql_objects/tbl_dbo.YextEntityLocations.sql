USE [Marketing]
GO

ALTER TABLE [dbo].[YextEntityLocations] DROP CONSTRAINT [DF__YextEntit__Inges__656C112C]
GO

/****** Object:  Table [dbo].[YextEntityLocations]    Script Date: 10/24/2025 4:04:05 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[YextEntityLocations]') AND type in (N'U'))
DROP TABLE [dbo].[YextEntityLocations]
GO

/****** Object:  Table [dbo].[YextEntityLocations]    Script Date: 10/24/2025 4:04:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[YextEntityLocations](
	[Id] [nvarchar](100) NOT NULL,
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
	[LastUpdated] [datetime2](3) NULL,
	[IngestedAt] [datetime2](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[YextEntityLocations] ADD  DEFAULT (sysutcdatetime()) FOR [IngestedAt]
GO



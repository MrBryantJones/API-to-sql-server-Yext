USE [Marketing]
GO

ALTER TABLE [dbo].[YextListings] DROP CONSTRAINT [DF__YextListi__Inges__72C60C4A]
GO

/****** Object:  Table [dbo].[YextListings]    Script Date: 10/24/2025 4:04:12 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[YextListings]') AND type in (N'U'))
DROP TABLE [dbo].[YextListings]
GO

/****** Object:  Table [dbo].[YextListings]    Script Date: 10/24/2025 4:04:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[YextListings](
	[LocationId] [nvarchar](100) NOT NULL,
	[PublisherId] [nvarchar](100) NOT NULL,
	[ListingId] [nvarchar](200) NULL,
	[Status] [nvarchar](100) NULL,
	[Url] [nvarchar](1000) NULL,
	[UpdatedAt] [datetime2](3) NULL,
	[RawJson] [nvarchar](max) NOT NULL,
	[IngestedAt] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_YextListings] PRIMARY KEY CLUSTERED 
(
	[LocationId] ASC,
	[PublisherId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[YextListings] ADD  DEFAULT (sysutcdatetime()) FOR [IngestedAt]
GO



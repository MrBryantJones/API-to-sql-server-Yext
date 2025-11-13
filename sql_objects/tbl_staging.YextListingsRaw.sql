USE [Marketing]
GO

ALTER TABLE [staging].[YextListingsRaw] DROP CONSTRAINT [DF__YextListi__Inges__6FE99F9F]
GO

/****** Object:  Table [staging].[YextListingsRaw]    Script Date: 10/24/2025 4:04:30 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[staging].[YextListingsRaw]') AND type in (N'U'))
DROP TABLE [staging].[YextListingsRaw]
GO

/****** Object:  Table [staging].[YextListingsRaw]    Script Date: 10/24/2025 4:04:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [staging].[YextListingsRaw](
	[RawId] [bigint] IDENTITY(1,1) NOT NULL,
	[LocationId] [nvarchar](100) NULL,
	[PublisherId] [nvarchar](100) NULL,
	[ListingId] [nvarchar](200) NULL,
	[Status] [nvarchar](100) NULL,
	[Url] [nvarchar](1000) NULL,
	[UpdatedAt] [datetime2](3) NULL,
	[RawJson] [nvarchar](max) NOT NULL,
	[IngestedAt] [datetime2](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RawId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [staging].[YextListingsRaw] ADD  DEFAULT (sysutcdatetime()) FOR [IngestedAt]
GO



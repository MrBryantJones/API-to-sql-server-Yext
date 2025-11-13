USE [Marketing]
GO

ALTER TABLE [dbo].[YextReviews] DROP CONSTRAINT [DF__YextRevie__Inges__6C190EBB]
GO

/****** Object:  Table [dbo].[YextReviews]    Script Date: 10/24/2025 4:04:17 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[YextReviews]') AND type in (N'U'))
DROP TABLE [dbo].[YextReviews]
GO

/****** Object:  Table [dbo].[YextReviews]    Script Date: 10/24/2025 4:04:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[YextReviews](
	[ReviewId] [nvarchar](100) NOT NULL,
	[EntityId] [nvarchar](100) NULL,
	[Rating] [int] NULL,
	[ReviewDate] [datetime2](3) NULL,
	[ReviewerName] [nvarchar](200) NULL,
	[Source] [nvarchar](100) NULL,
	[RawJson] [nvarchar](max) NOT NULL,
	[IngestedAt] [datetime2](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ReviewId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[YextReviews] ADD  DEFAULT (sysutcdatetime()) FOR [IngestedAt]
GO



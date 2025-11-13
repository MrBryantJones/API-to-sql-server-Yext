USE [Marketing]
GO

ALTER TABLE [staging].[YextReviewsRaw] DROP CONSTRAINT [DF__YextRevie__Inges__693CA210]
GO

/****** Object:  Table [staging].[YextReviewsRaw]    Script Date: 10/24/2025 4:04:52 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[staging].[YextReviewsRaw]') AND type in (N'U'))
DROP TABLE [staging].[YextReviewsRaw]
GO

/****** Object:  Table [staging].[YextReviewsRaw]    Script Date: 10/24/2025 4:04:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [staging].[YextReviewsRaw](
	[ReviewId] [nvarchar](100) NOT NULL,
	[RawJson] [nvarchar](max) NOT NULL,
	[IngestedAt] [datetime2](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ReviewId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [staging].[YextReviewsRaw] ADD  DEFAULT (sysutcdatetime()) FOR [IngestedAt]
GO



USE [Marketing]
GO

/****** Object:  Table [staging].[YextReviews]    Script Date: 10/24/2025 4:04:46 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[staging].[YextReviews]') AND type in (N'U'))
DROP TABLE [staging].[YextReviews]
GO

/****** Object:  Table [staging].[YextReviews]    Script Date: 10/24/2025 4:04:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [staging].[YextReviews](
	[Id] [nvarchar](50) NOT NULL,
	[EntityId] [nvarchar](50) NULL,
	[Source] [nvarchar](100) NULL,
	[Rating] [int] NULL,
	[Title] [nvarchar](255) NULL,
	[Content] [nvarchar](max) NULL,
	[ReviewerName] [nvarchar](255) NULL,
	[ReviewerEmail] [nvarchar](255) NULL,
	[ReviewDate] [datetime] NULL,
	[ResponseContent] [nvarchar](max) NULL,
	[ResponseDate] [datetime] NULL,
	[LastUpdated] [datetime] NULL,
	[SystemLoadDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO



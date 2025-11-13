USE [Marketing]
GO

ALTER TABLE [staging].[YextEntityLocationsRaw] DROP CONSTRAINT [DF__YextEntit__Inges__628FA481]
GO

/****** Object:  Table [staging].[YextEntityLocationsRaw]    Script Date: 10/24/2025 4:04:22 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[staging].[YextEntityLocationsRaw]') AND type in (N'U'))
DROP TABLE [staging].[YextEntityLocationsRaw]
GO

/****** Object:  Table [staging].[YextEntityLocationsRaw]    Script Date: 10/24/2025 4:04:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [staging].[YextEntityLocationsRaw](
	[Id] [nvarchar](100) NOT NULL,
	[RawJson] [nvarchar](max) NOT NULL,
	[IngestedAt] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_YextEntityLocationsRaw] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [staging].[YextEntityLocationsRaw] ADD  DEFAULT (sysutcdatetime()) FOR [IngestedAt]
GO



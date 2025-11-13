USE [Marketing]
GO

/****** Object:  View [powerBI].[vw_YextPublishers]    Script Date: 10/24/2025 4:36:12 PM ******/
DROP VIEW [powerBI].[vw_YextPublishers]
GO

/****** Object:  View [powerBI].[vw_YextPublishers]    Script Date: 10/24/2025 4:36:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [powerBI].[vw_YextPublishers]
AS
SELECT DISTINCT
    li.PublisherId
FROM dbo.YextListings AS li
WHERE li.PublisherId IS NOT NULL;

GO



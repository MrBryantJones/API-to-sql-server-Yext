USE [Marketing]
GO

/****** Object:  View [powerBI].[vw_YextReviews]    Script Date: 10/24/2025 4:36:12 PM ******/
DROP VIEW [powerBI].[vw_YextReviews]
GO

/****** Object:  View [powerBI].[vw_YextReviews]    Script Date: 10/24/2025 4:36:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [powerBI].[vw_YextReviews]
AS
SELECT
    r.ReviewId,
    r.EntityId       AS LocationId,   -- relationship to Locations.Id
    r.Rating,
    r.ReviewDate,
    r.ReviewerName,
    r.Source    --,                         -- e.g., GOOGLEMYBUSINESS
    --r.RawJson,                        -- keep for drill-through if desired
    --r.IngestedAt
FROM dbo.YextReviews AS r;

GO



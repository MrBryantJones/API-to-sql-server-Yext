USE [Marketing]
GO

/****** Object:  View [bi].[v_YextReviewKPI]    Script Date: 10/24/2025 4:36:07 PM ******/
DROP VIEW [bi].[v_YextReviewKPI]
GO

/****** Object:  View [bi].[v_YextReviewKPI]    Script Date: 10/24/2025 4:36:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [bi].[v_YextReviewKPI]
AS
SELECT
    r.EntityId          AS LocationId,
    COUNT(*)            AS ReviewCount,
    AVG(CASE WHEN r.Rating IS NOT NULL THEN 1.0 * r.Rating END) AS AvgRating,
    MAX(r.ReviewDate)   AS LastReviewDate
FROM dbo.YextReviews AS r
GROUP BY r.EntityId;

GO



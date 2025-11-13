USE [Marketing]
GO

/****** Object:  View [powerBI].[vw_YextListingKPI]    Script Date: 10/24/2025 4:36:12 PM ******/
DROP VIEW [powerBI].[vw_YextListingKPI]
GO

/****** Object:  View [powerBI].[vw_YextListingKPI]    Script Date: 10/24/2025 4:35:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [powerBI].[vw_YextListingKPI]
AS
SELECT
    li.LocationId,
    COUNT(*) AS ListingsTotal,
    SUM(CASE WHEN li.Status = 'LIVE' THEN 1 ELSE 0 END)               AS ListingsLive,
    SUM(CASE WHEN li.Status = 'UNAVAILABLE' THEN 1 ELSE 0 END)        AS ListingsUnavailable,
    SUM(CASE WHEN li.Status = 'WAITING_ON_PUBLISHER' THEN 1 ELSE 0 END) AS ListingsWaitingOnPublisher
	--,
    --MAX(li.UpdatedAt) AS ListingsLastUpdated
FROM dbo.YextListings AS li
GROUP BY li.LocationId;

GO



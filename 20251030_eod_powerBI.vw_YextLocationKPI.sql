USE [Marketing]
GO

/****** Object:  View [powerBI].[vw_YextLocationKPI]    Script Date: 10/24/2025 4:36:12 PM ******/
DROP VIEW [powerBI].[vw_YextLocationKPI]
GO

/****** Object:  View [powerBI].[vw_YextLocationKPI]    Script Date: 10/24/2025 4:35:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [powerBI].[vw_YextLocationKPI]
AS
SELECT
    loc.Id                      AS LocationId,
    loc.Name,
    loc.City,
    loc.Region,
    loc.PostalCode,
    loc.CountryCode,
    loc.MainPhone,
    --loc.WebsiteUrl,
    loc.LastUpdated             AS LocationLastUpdated,

    -- Reviews KPI
    rk.ReviewCount,
    rk.AvgRating,
    rk.LastReviewDate,

    -- Listings KPI
    lk.ListingsTotal,
    lk.ListingsLive,
    lk.ListingsUnavailable,
    lk.ListingsWaitingOnPublisher
	--,
 --   lk.ListingsLastUpdated
FROM dbo.YextEntityLocations AS loc
LEFT JOIN powerBI.vw_YextReviewKPI   AS rk ON rk.LocationId = loc.Id
LEFT JOIN powerBI.vw_YextListingKPI  AS lk ON lk.LocationId = loc.Id;

GO

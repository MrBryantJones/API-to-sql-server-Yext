USE [Marketing]
GO

/****** Object:  View [bi].[v_YextLocationKPI]    Script Date: 10/24/2025 4:35:50 PM ******/
DROP VIEW [bi].[v_YextLocationKPI]
GO

/****** Object:  View [bi].[v_YextLocationKPI]    Script Date: 10/24/2025 4:35:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [bi].[v_YextLocationKPI]
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
LEFT JOIN bi.v_YextReviewKPI   AS rk ON rk.LocationId = loc.Id
LEFT JOIN bi.v_YextListingKPI  AS lk ON lk.LocationId = loc.Id;

GO



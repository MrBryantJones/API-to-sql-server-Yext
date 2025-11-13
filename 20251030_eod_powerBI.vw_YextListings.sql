USE [Marketing]
GO

/****** Object:  View [powerBI].[vw_YextListings]    Script Date: 10/24/2025 4:36:12 PM ******/
DROP VIEW [powerBI].[vw_YextListings]
GO

/****** Object:  View [powerBI].[vw_YextListings]    Script Date: 10/24/2025 4:35:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [powerBI].[vw_YextListings]
AS
SELECT
    li.LocationId,                    -- relationship to Locations.Id
    li.PublisherId,
    li.ListingId,
    li.Status,                        -- e.g., LIVE / UNAVAILABLE / WAITING_ON_PUBLISHER
    li.Url      --,                           -- from listingUrl in JSON
    --li.UpdatedAt,
    --li.RawJson,
    --li.IngestedAt
FROM dbo.YextListings AS li;

GO



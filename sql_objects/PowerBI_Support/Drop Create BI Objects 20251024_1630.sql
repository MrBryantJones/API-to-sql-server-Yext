
/**********************************************************
	SQL: BI Views for Power BI
**********************************************************/


USE [Marketing];
GO

------------------------------------------------------------
-- 0) Create schema for BI
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bi')
EXEC('CREATE SCHEMA bi');
GO

------------------------------------------------------------
-- 1) Base “fact-like” views
--    Thin, readable, directly consumable in Power BI
------------------------------------------------------------

-- Locations (Entities) – curated
IF OBJECT_ID('bi.v_YextLocations','V') IS NOT NULL
    DROP VIEW bi.v_YextLocations;
GO
CREATE VIEW bi.v_YextLocations
AS
SELECT
    l.Id                         AS LocationId,
    l.Name,
    l.AddressLine1,
    l.City,
    l.Region,
    l.PostalCode,
    l.CountryCode,
    l.MainPhone,
    l.WebsiteUrl,
    l.Description,
    l.Latitude,
    l.Longitude,
    l.LastUpdated,
    l.IngestedAt
FROM dbo.YextEntityLocations AS l;
GO

-- Reviews – curated
IF OBJECT_ID('bi.v_YextReviews','V') IS NOT NULL
    DROP VIEW bi.v_YextReviews;
GO
CREATE VIEW bi.v_YextReviews
AS
SELECT
    r.ReviewId,
    r.EntityId       AS LocationId,   -- relationship to Locations.Id
    r.Rating,
    r.ReviewDate,
    r.ReviewerName,
    r.Source,                         -- e.g., GOOGLEMYBUSINESS
    r.RawJson,                        -- keep for drill-through if desired
    r.IngestedAt
FROM dbo.YextReviews AS r;
GO

-- Listings – curated
IF OBJECT_ID('bi.v_YextListings','V') IS NOT NULL
    DROP VIEW bi.v_YextListings;
GO
CREATE VIEW bi.v_YextListings
AS
SELECT
    li.LocationId,                    -- relationship to Locations.Id
    li.PublisherId,
    li.ListingId,
    li.Status,                        -- e.g., LIVE / UNAVAILABLE / WAITING_ON_PUBLISHER
    li.Url,                           -- from listingUrl in JSON
    li.UpdatedAt,
    li.RawJson,
    li.IngestedAt
FROM dbo.YextListings AS li;
GO

------------------------------------------------------------
-- 2) KPI / rollup views
--    Per-location aggregates for quick visuals
------------------------------------------------------------

-- Reviews rollup per location
IF OBJECT_ID('bi.v_YextReviewKPI','V') IS NOT NULL
    DROP VIEW bi.v_YextReviewKPI;
GO
CREATE VIEW bi.v_YextReviewKPI
AS
SELECT
    r.EntityId          AS LocationId,
    COUNT(*)            AS ReviewCount,
    AVG(CASE WHEN r.Rating IS NOT NULL THEN 1.0 * r.Rating END) AS AvgRating,
    MAX(r.ReviewDate)   AS LastReviewDate
FROM dbo.YextReviews AS r
GROUP BY r.EntityId;
GO

-- Listings status rollup per location
IF OBJECT_ID('bi.v_YextListingKPI','V') IS NOT NULL
    DROP VIEW bi.v_YextListingKPI;
GO
CREATE VIEW bi.v_YextListingKPI
AS
SELECT
    li.LocationId,
    COUNT(*) AS ListingsTotal,
    SUM(CASE WHEN li.Status = 'LIVE' THEN 1 ELSE 0 END)               AS ListingsLive,
    SUM(CASE WHEN li.Status = 'UNAVAILABLE' THEN 1 ELSE 0 END)        AS ListingsUnavailable,
    SUM(CASE WHEN li.Status = 'WAITING_ON_PUBLISHER' THEN 1 ELSE 0 END) AS ListingsWaitingOnPublisher,
    MAX(li.UpdatedAt) AS ListingsLastUpdated
FROM dbo.YextListings AS li
GROUP BY li.LocationId;
GO

-- Combined per-location KPI view (Locations + Reviews + Listings)
IF OBJECT_ID('bi.v_YextLocationKPI','V') IS NOT NULL
    DROP VIEW bi.v_YextLocationKPI;
GO
CREATE VIEW bi.v_YextLocationKPI
AS
SELECT
    loc.Id                      AS LocationId,
    loc.Name,
    loc.City,
    loc.Region,
    loc.PostalCode,
    loc.CountryCode,
    loc.MainPhone,
    loc.WebsiteUrl,
    loc.LastUpdated             AS LocationLastUpdated,

    -- Reviews KPI
    rk.ReviewCount,
    rk.AvgRating,
    rk.LastReviewDate,

    -- Listings KPI
    lk.ListingsTotal,
    lk.ListingsLive,
    lk.ListingsUnavailable,
    lk.ListingsWaitingOnPublisher,
    lk.ListingsLastUpdated
FROM dbo.YextEntityLocations AS loc
LEFT JOIN bi.v_YextReviewKPI   AS rk ON rk.LocationId = loc.Id
LEFT JOIN bi.v_YextListingKPI  AS lk ON lk.LocationId = loc.Id;
GO

------------------------------------------------------------
-- 3) Small supporting dims (optional)
------------------------------------------------------------

-- Publisher dim (from Listings)
IF OBJECT_ID('bi.v_YextPublishers','V') IS NOT NULL
    DROP VIEW bi.v_YextPublishers;
GO
CREATE VIEW bi.v_YextPublishers
AS
SELECT DISTINCT
    li.PublisherId
FROM dbo.YextListings AS li
WHERE li.PublisherId IS NOT NULL;
GO
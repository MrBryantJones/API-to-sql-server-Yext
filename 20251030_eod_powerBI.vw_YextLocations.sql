USE [Marketing]
GO

/****** Object:  View [powerBI].[vw_YextLocations]    Script Date: 10/24/2025 4:36:12 PM ******/
DROP VIEW [powerBI].[vw_YextLocations]
GO

/****** Object:  View [powerBI].[vw_YextLocations]    Script Date: 10/24/2025 4:35:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [powerBI].[vw_YextLocations]
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
    --l.WebsiteUrl,
    l.Description,
    l.Latitude,
    l.Longitude,
    l.LastUpdated   --,
    --l.IngestedAt
FROM dbo.YextEntityLocations AS l;

GO



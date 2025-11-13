USE [Marketing]
GO

/****** Object:  View [bi].[v_YextLocations]    Script Date: 10/24/2025 4:35:54 PM ******/
DROP VIEW [bi].[v_YextLocations]
GO

/****** Object:  View [bi].[v_YextLocations]    Script Date: 10/24/2025 4:35:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [bi].[v_YextLocations]
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
    l.LastUpdated,
    l.IngestedAt
FROM dbo.YextEntityLocations AS l;

GO



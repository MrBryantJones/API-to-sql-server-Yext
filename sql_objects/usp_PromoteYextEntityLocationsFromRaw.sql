USE [Marketing]
GO

/****** Object:  StoredProcedure [dbo].[usp_PromoteYextEntityLocationsFromRaw]    Script Date: 10/24/2025 4:05:18 PM ******/
DROP PROCEDURE [dbo].[usp_PromoteYextEntityLocationsFromRaw]
GO

/****** Object:  StoredProcedure [dbo].[usp_PromoteYextEntityLocationsFromRaw]    Script Date: 10/24/2025 4:05:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_PromoteYextEntityLocationsFromRaw]
AS
BEGIN
  SET NOCOUNT ON;

  ;WITH src AS (
    SELECT
      r.Id,
      JSON_VALUE(r.RawJson,'$.name')                                  AS Name,
      JSON_VALUE(r.RawJson,'$.address.line1')                         AS AddressLine1,
      JSON_VALUE(r.RawJson,'$.address.city')                          AS City,
      JSON_VALUE(r.RawJson,'$.address.region')                        AS Region,
      JSON_VALUE(r.RawJson,'$.address.postalCode')                    AS PostalCode,
      JSON_VALUE(r.RawJson,'$.address.countryCode')                   AS CountryCode,
      JSON_VALUE(r.RawJson,'$.mainPhone')                             AS MainPhone,

      -- Website can be object: websiteUrl: { url, displayUrl }
      COALESCE(
        JSON_VALUE(r.RawJson,'$.websiteUrl.url'),
        JSON_VALUE(r.RawJson,'$.websiteUrl.displayUrl'),
        JSON_VALUE(r.RawJson,'$.websiteUrl')  -- rare scalar fallback
      )                                                               AS WebsiteUrl,

      JSON_VALUE(r.RawJson,'$.description')                           AS Description,

      -- Coordinates (prefer geocodedCoordinate; fall back to yextDisplayCoordinate)
      COALESCE(
        TRY_CONVERT(FLOAT, JSON_VALUE(r.RawJson,'$.geocodedCoordinate.latitude')),
        TRY_CONVERT(FLOAT, JSON_VALUE(r.RawJson,'$.yextDisplayCoordinate.latitude')),
        TRY_CONVERT(FLOAT, JSON_VALUE(r.RawJson,'$.displayCoordinate.latitude'))
      )                                                               AS Latitude,
      COALESCE(
        TRY_CONVERT(FLOAT, JSON_VALUE(r.RawJson,'$.geocodedCoordinate.longitude')),
        TRY_CONVERT(FLOAT, JSON_VALUE(r.RawJson,'$.yextDisplayCoordinate.longitude')),
        TRY_CONVERT(FLOAT, JSON_VALUE(r.RawJson,'$.displayCoordinate.longitude'))
      )                                                               AS Longitude,

      -- LastUpdated: broaden to meta timestamps if updatedAt missing
      COALESCE(
        TRY_CONVERT(DATETIME2(3), JSON_VALUE(r.RawJson,'$.updatedAt')),
        TRY_CONVERT(DATETIME2(3), JSON_VALUE(r.RawJson,'$.meta.timestamp')),
        TRY_CONVERT(DATETIME2(3), JSON_VALUE(r.RawJson,'$.meta.createdTimestamp'))
      )                                                               AS LastUpdated,

      r.IngestedAt
    FROM staging.YextEntityLocationsRaw r
  )
  MERGE dbo.YextEntityLocations AS tgt
  USING src
    ON tgt.Id = src.Id
  WHEN MATCHED THEN
    UPDATE SET
      tgt.Name         = src.Name,
      tgt.AddressLine1 = src.AddressLine1,
      tgt.City         = src.City,
      tgt.Region       = src.Region,
      tgt.PostalCode   = src.PostalCode,
      tgt.CountryCode  = src.CountryCode,
      tgt.MainPhone    = src.MainPhone,
      tgt.WebsiteUrl   = src.WebsiteUrl,
      tgt.Description  = src.Description,
      tgt.Latitude     = src.Latitude,
      tgt.Longitude    = src.Longitude,
      tgt.LastUpdated  = src.LastUpdated,
      tgt.IngestedAt   = SYSUTCDATETIME()
  WHEN NOT MATCHED BY TARGET THEN
    INSERT (Id, Name, AddressLine1, City, Region, PostalCode, CountryCode, MainPhone, WebsiteUrl, Description, Latitude, Longitude, LastUpdated, IngestedAt)
    VALUES (src.Id, src.Name, src.AddressLine1, src.City, src.Region, src.PostalCode, src.CountryCode, src.MainPhone, src.WebsiteUrl, src.Description, src.Latitude, src.Longitude, src.LastUpdated, SYSUTCDATETIME());
END
GO



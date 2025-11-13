USE [Marketing]
GO

/****** Object:  StoredProcedure [dbo].[usp_PromoteYextLocationsFromRaw]    Script Date: 11/12/2025 5:08:19 PM ******/
DROP PROCEDURE [dbo].[usp_PromoteYextLocationsFromRaw]
GO

/****** Object:  StoredProcedure [dbo].[usp_PromoteYextLocationsFromRaw]    Script Date: 11/12/2025 5:08:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_PromoteYextLocationsFromRaw]
AS
BEGIN
  SET NOCOUNT ON;

  ;WITH Parsed AS (
    SELECT
      r.Id,
      JSON_VALUE(r.RawJson, '$.name')                              AS Name,
      JSON_VALUE(r.RawJson, '$.address.line1')                     AS AddressLine1,
      JSON_VALUE(r.RawJson, '$.address.city')                      AS City,
      JSON_VALUE(r.RawJson, '$.address.region')                    AS Region,
      JSON_VALUE(r.RawJson, '$.address.postalCode')                AS PostalCode,
      JSON_VALUE(r.RawJson, '$.address.countryCode')               AS CountryCode,
      JSON_VALUE(r.RawJson, '$.mainPhone')                         AS MainPhone,
      JSON_VALUE(r.RawJson, '$.websiteUrl')                        AS WebsiteUrl,
      JSON_VALUE(r.RawJson, '$.description')                       AS Description,
      TRY_CONVERT(FLOAT,    JSON_VALUE(r.RawJson, '$.geocodedCoordinate.latitude'))  AS Latitude1,
      TRY_CONVERT(FLOAT,    JSON_VALUE(r.RawJson, '$.geocodedCoordinate.longitude')) AS Longitude1,
      TRY_CONVERT(FLOAT,    JSON_VALUE(r.RawJson, '$.displayCoordinate.latitude'))   AS Latitude2,
      TRY_CONVERT(FLOAT,    JSON_VALUE(r.RawJson, '$.displayCoordinate.longitude'))  AS Longitude2,
      TRY_CONVERT(DATETIME, JSON_VALUE(r.RawJson, '$.updatedAt'))  AS LastUpdatedJson,
      r.IngestedAt
    FROM staging.YextLocationsRaw r
  ),
  Coalesced AS (
    SELECT
      Id, Name, AddressLine1, City, Region, PostalCode, CountryCode,
      MainPhone, WebsiteUrl, Description,
      COALESCE(Latitude1, Latitude2)   AS Latitude,
      COALESCE(Longitude1, Longitude2) AS Longitude,
      LastUpdatedJson                  AS LastUpdated,
      IngestedAt
    FROM Parsed
  )
  MERGE dbo.Locations AS tgt
  USING (SELECT * FROM Coalesced) AS src
  ON (tgt.Id = src.Id)
  WHEN MATCHED THEN UPDATE SET
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
    INSERT (Id, Name, AddressLine1, City, Region, PostalCode, CountryCode,
            MainPhone, WebsiteUrl, Description, Latitude, Longitude, LastUpdated, IngestedAt)
    VALUES (src.Id, src.Name, src.AddressLine1, src.City, src.Region, src.PostalCode, src.CountryCode,
            src.MainPhone, src.WebsiteUrl, src.Description, src.Latitude, src.Longitude, src.LastUpdated, SYSUTCDATETIME());
END
GO



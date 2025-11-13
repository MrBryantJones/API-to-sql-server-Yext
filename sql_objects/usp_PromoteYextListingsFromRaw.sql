USE [Marketing]
GO

/****** Object:  StoredProcedure [dbo].[usp_PromoteYextListingsFromRaw]    Script Date: 10/24/2025 4:05:22 PM ******/
DROP PROCEDURE [dbo].[usp_PromoteYextListingsFromRaw]
GO

/****** Object:  StoredProcedure [dbo].[usp_PromoteYextListingsFromRaw]    Script Date: 10/24/2025 4:05:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_PromoteYextListingsFromRaw]
AS
BEGIN
  SET NOCOUNT ON;

  ;WITH src AS (
    SELECT
      TRY_CAST(JSON_VALUE(r.RawJson, '$.locationId') AS NVARCHAR(100)) AS LocationId,
      TRY_CAST(JSON_VALUE(r.RawJson, '$.publisherId') AS NVARCHAR(100)) AS PublisherId,
      TRY_CAST(COALESCE(JSON_VALUE(r.RawJson, '$.id'),
                        JSON_VALUE(r.RawJson, '$.listingId')) AS NVARCHAR(200)) AS ListingId,
      TRY_CAST(JSON_VALUE(r.RawJson, '$.status')      AS NVARCHAR(100))  AS Status,

      -- Prefer listingUrl; fallback to url if ever present
      COALESCE(
        JSON_VALUE(r.RawJson, '$.listingUrl'),
        JSON_VALUE(r.RawJson, '$.url')
      ) AS Url,

      -- UpdatedAt (rarely present, but keep parsing if it is)
      TRY_CONVERT(DATETIME2(3), JSON_VALUE(r.RawJson, '$.updatedAt')) AS UpdatedAt,

      r.RawJson,
      r.IngestedAt
    FROM staging.YextListingsRaw r
  )
  MERGE dbo.YextListings AS tgt
  USING src
    ON  tgt.LocationId  = src.LocationId
    AND tgt.PublisherId = src.PublisherId
  WHEN MATCHED THEN
    UPDATE SET
      tgt.ListingId  = src.ListingId,
      tgt.Status     = src.Status,
      tgt.Url        = src.Url,
      tgt.UpdatedAt  = src.UpdatedAt,
      tgt.RawJson    = src.RawJson,
      tgt.IngestedAt = SYSUTCDATETIME()
  WHEN NOT MATCHED BY TARGET THEN
    INSERT (LocationId, PublisherId, ListingId, Status, Url, UpdatedAt, RawJson, IngestedAt)
    VALUES (src.LocationId, src.PublisherId, src.ListingId, src.Status, src.Url, src.UpdatedAt, src.RawJson, SYSUTCDATETIME());
END
GO



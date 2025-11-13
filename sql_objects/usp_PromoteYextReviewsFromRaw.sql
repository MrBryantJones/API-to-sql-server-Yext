USE [Marketing]
GO

/****** Object:  StoredProcedure [dbo].[usp_PromoteYextReviewsFromRaw]    Script Date: 10/24/2025 4:05:32 PM ******/
DROP PROCEDURE [dbo].[usp_PromoteYextReviewsFromRaw]
GO

/****** Object:  StoredProcedure [dbo].[usp_PromoteYextReviewsFromRaw]    Script Date: 10/24/2025 4:05:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_PromoteYextReviewsFromRaw]
AS
BEGIN
  SET NOCOUNT ON;

  ;WITH src AS (
    SELECT
      r.ReviewId,

      -- Entity Id variants
      COALESCE(JSON_VALUE(r.RawJson,'$.entityId'),
               JSON_VALUE(r.RawJson,'$.locationId'))                                   AS EntityId,

      -- Rating (5.0, 4, etc.)
      TRY_CONVERT(DECIMAL(9,2), COALESCE(JSON_VALUE(r.RawJson,'$.rating'),
                                         JSON_VALUE(r.RawJson,'$.starRating')))       AS RatingDec,

      -- ISO-style dates first
      COALESCE(
        TRY_CONVERT(DATETIME2(3), JSON_VALUE(r.RawJson,'$.reviewDate')),
        TRY_CONVERT(DATETIME2(3), JSON_VALUE(r.RawJson,'$.createdAt')),
        TRY_CONVERT(DATETIME2(3), JSON_VALUE(r.RawJson,'$.updatedAt')),
        TRY_CONVERT(DATETIME2(3), JSON_VALUE(r.RawJson,'$.lastUpdated')),
        TRY_CONVERT(DATETIME2(3), JSON_VALUE(r.RawJson,'$.date'))
      )                                                                               AS IsoDate,

      -- Epoch-ms fields (publisherDate, lastYextUpdateTime)
      TRY_CONVERT(BIGINT, JSON_VALUE(r.RawJson,'$.publisherDate'))      AS PubMs,
      TRY_CONVERT(BIGINT, JSON_VALUE(r.RawJson,'$.lastYextUpdateTime')) AS LastYextMs,

      -- Author name variants
      COALESCE(JSON_VALUE(r.RawJson,'$.authorName'),
               JSON_VALUE(r.RawJson,'$.reviewer.name'),
               JSON_VALUE(r.RawJson,'$.author.name'))                                  AS ReviewerName,

      -- Source variants: prefer human-friendly if present; fall back to publisherId
      COALESCE(JSON_VALUE(r.RawJson,'$.source'),
               JSON_VALUE(r.RawJson,'$.publisher'),
               JSON_VALUE(r.RawJson,'$.publisherId'))                                  AS Source,

      r.RawJson,
      r.IngestedAt
    FROM staging.YextReviewsRaw r
  ),
  shaped AS (
    SELECT
      ReviewId,
      EntityId,

      CASE WHEN RatingDec IS NULL THEN NULL ELSE TRY_CONVERT(INT, ROUND(RatingDec, 0)) END AS Rating,

      -- Final ReviewDate: ISO chain, else epoch-ms to datetime2
      COALESCE(
        IsoDate,
        CASE WHEN PubMs IS NOT NULL
             THEN DATEADD(MILLISECOND, PubMs % 1000,
                    DATEADD(SECOND, (PubMs / 1000), '1970-01-01'))
        END,
        CASE WHEN LastYextMs IS NOT NULL
             THEN DATEADD(MILLISECOND, LastYextMs % 1000,
                    DATEADD(SECOND, (LastYextMs / 1000), '1970-01-01'))
        END
      ) AS ReviewDate,

      ReviewerName,
      Source,
      RawJson,
      IngestedAt
    FROM src
  )
  MERGE dbo.YextReviews AS tgt
  USING shaped AS s
    ON tgt.ReviewId = s.ReviewId
  WHEN MATCHED THEN
    UPDATE SET
      tgt.EntityId     = s.EntityId,
      tgt.Rating       = s.Rating,
      tgt.ReviewDate   = s.ReviewDate,
      tgt.ReviewerName = s.ReviewerName,
      tgt.Source       = s.Source,
      tgt.RawJson      = s.RawJson,
      tgt.IngestedAt   = SYSUTCDATETIME()
  WHEN NOT MATCHED BY TARGET THEN
    INSERT (ReviewId, EntityId, Rating, ReviewDate, ReviewerName, Source, RawJson, IngestedAt)
    VALUES (s.ReviewId, s.EntityId, s.Rating, s.ReviewDate, s.ReviewerName, s.Source, s.RawJson, SYSUTCDATETIME());
END
GO



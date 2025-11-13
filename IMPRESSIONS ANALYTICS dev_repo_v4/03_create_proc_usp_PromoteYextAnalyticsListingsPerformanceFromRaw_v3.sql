/*
File: 03_create_proc_usp_PromoteYextAnalyticsListingsPerformanceFromRaw.sql
Generated: 2025-11-12 22:18:59 UTC

Purpose:
  Promotion stored procedure moving data from staging.YextAnalyticsListingsPerformanceRaw
  into dbo.YextAnalyticsListingsPerformance using idempotent upsert semantics.

Behavior:
  - De-duplicates staging rows by natural key, keeping the latest PulledAtUtc per key.
  - Updates target when Value changed; Inserts when new; No deletes by default.
  - Optional: clears old staging rows after success (commented section at bottom).
*/

IF OBJECT_ID(N'dbo.usp_PromoteYextAnalyticsListingsPerformanceFromRaw', N'P') IS NOT NULL
  DROP PROCEDURE dbo.usp_PromoteYextAnalyticsListingsPerformanceFromRaw;
GO

CREATE PROCEDURE dbo.usp_PromoteYextAnalyticsListingsPerformanceFromRaw
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    ;WITH Dedup AS (
      SELECT
        r.[Date],
        r.EntityId,
        r.EntityIdNK,
        r.MetricCode,
        r.Value,
        r.PulledAtUtc,
        ROW_NUMBER() OVER (PARTITION BY r.[Date], r.EntityIdNK, r.MetricCode
                           ORDER BY r.PulledAtUtc DESC) AS rn
      FROM staging.YextAnalyticsListingsPerformanceRaw r
    )
    MERGE dbo.YextAnalyticsListingsPerformance AS T
    USING (
      SELECT [Date], EntityId, EntityIdNK, MetricCode, Value
      FROM Dedup
      WHERE rn = 1
    ) AS S
    ON (
      T.[Date]     = S.[Date] AND
      T.EntityIdNK = S.EntityIdNK AND
      T.MetricCode = S.MetricCode
    )
    WHEN MATCHED AND T.Value <> S.Value THEN
      UPDATE SET
        T.Value = S.Value,
        T.LastUpdated = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
      INSERT ([Date], EntityId, MetricCode, Value)
      VALUES (S.[Date], S.EntityId, S.MetricCode, S.Value)
    -- WHEN NOT MATCHED BY SOURCE THEN
    --   -- No delete by default; manage retention outside of the promote step.
    ;

    -- Optional: Clear staging after successful promote (tune to your ops preference)
    -- DELETE r
    -- FROM staging.YextAnalyticsListingsPerformanceRaw r
    -- WHERE r.PulledAtUtc < DATEADD(day, -7, SYSUTCDATETIME());

  END TRY
  BEGIN CATCH
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrNo  INT = ERROR_NUMBER();
    DECLARE @ErrSev INT = ERROR_SEVERITY();
    DECLARE @ErrSta INT = ERROR_STATE();
    DECLARE @ErrLin INT = ERROR_LINE();

    -- Optional: write to your standard error log table if present
    -- INSERT INTO dbo.ErrorLog(ErrorTimeUtc, ProcName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage)
    -- VALUES (SYSUTCDATETIME(), 'dbo.usp_PromoteYextAnalyticsListingsPerformanceFromRaw', @ErrNo, @ErrSev, @ErrSta, @ErrLin, @ErrMsg);

    RAISERROR('PromoteYextAnalyticsListingsPerformanceFromRaw failed: %s', 16, 1, @ErrMsg);
    RETURN;
  END CATCH
END
GO

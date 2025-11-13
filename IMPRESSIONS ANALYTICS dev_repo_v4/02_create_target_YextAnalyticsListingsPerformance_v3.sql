/*
File: 02_create_target_YextAnalyticsListingsPerformance.sql
Generated: 2025-11-12 22:18:59 UTC

Purpose:
  Target (fact) table for Yext Analytics "Listings Performance".
  Aligned with your convention: schema 'dbo', clean name without 'Raw'.

Notes:
  - Unique natural key constraint enforced via UNIQUE nonclustered index.
  - Clustered Columnstore Index for analytics performance in Power BI.
*/

IF OBJECT_ID(N'dbo.YextAnalyticsListingsPerformance', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.YextAnalyticsListingsPerformance
  (
    [Date]       DATE         NOT NULL,
    EntityId     NVARCHAR(64) NULL,
    EntityIdNK   AS ISNULL(EntityId, N'') PERSISTED,
    MetricCode   NVARCHAR(64) NOT NULL,
    Value        BIGINT       NOT NULL,
    LastUpdated  DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME()
  );
END
GO

-- Enforce natural-key uniqueness
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_YA_ListPerf_NK' AND object_id = OBJECT_ID('dbo.YextAnalyticsListingsPerformance'))
BEGIN
  CREATE UNIQUE NONCLUSTERED INDEX UX_YA_ListPerf_NK
    ON dbo.YextAnalyticsListingsPerformance ([Date], EntityIdNK, MetricCode);
END
GO

-- Columnstore for analytics performance
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'CCI_YA_ListPerf' AND object_id = OBJECT_ID('dbo.YextAnalyticsListingsPerformance'))
BEGIN
  CREATE CLUSTERED COLUMNSTORE INDEX CCI_YA_ListPerf
    ON dbo.YextAnalyticsListingsPerformance;
END
GO

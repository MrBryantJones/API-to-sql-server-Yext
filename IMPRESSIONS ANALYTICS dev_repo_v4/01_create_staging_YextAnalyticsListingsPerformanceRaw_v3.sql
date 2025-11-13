/*
File: 01_create_staging_YextAnalyticsListingsPerformanceRaw.sql
Generated: 2025-11-12 22:18:59 UTC

Purpose:
  Staging (Raw) table for Yext Analytics "Listings Performance" (Impressions, Clicks, Profile Views).
  Aligned with your convention: schema 'staging', suffix 'Raw'.

Notes:
  - Heap for fast bulk loads.
  - Persisted computed EntityIdNK normalizes NULLs for joins/indexes.
  - Add optional context columns if needed later (AccountId, CountryCode).
*/

IF SCHEMA_ID(N'staging') IS NULL EXEC('CREATE SCHEMA staging');
GO

IF OBJECT_ID(N'staging.YextAnalyticsListingsPerformanceRaw', N'U') IS NULL
BEGIN
  CREATE TABLE staging.YextAnalyticsListingsPerformanceRaw
  (
    RunId        UNIQUEIDENTIFIER NOT NULL,
    PulledAtUtc  DATETIME2(3)     NOT NULL DEFAULT SYSUTCDATETIME(),
    PeriodStart  DATE             NOT NULL,
    PeriodEnd    DATE             NOT NULL,

    [Date]       DATE             NOT NULL,
    EntityId     NVARCHAR(64)     NULL,
    EntityIdNK   AS ISNULL(EntityId, N'') PERSISTED,
    MetricCode   NVARCHAR(64)     NOT NULL,
    Value        BIGINT           NOT NULL,

    -- Optional context placeholders (expand as needed)
    AccountId    NVARCHAR(64)     NULL,
    CountryCode  NVARCHAR(8)      NULL,

    -- Optional: batch tracking across modules
    LoadBatchId  UNIQUEIDENTIFIER NULL
  );
END
GO

-- Helpful nonclustered index on natural key for faster MERGE matching
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_YA_ListPerfRaw_NK' AND object_id = OBJECT_ID('staging.YextAnalyticsListingsPerformanceRaw'))
BEGIN
  CREATE NONCLUSTERED INDEX IX_YA_ListPerfRaw_NK
    ON staging.YextAnalyticsListingsPerformanceRaw ([Date], EntityIdNK, MetricCode);
END
GO

USE [Marketing]
GO

/****** Object:  StoredProcedure [dbo].[usp_InsertYextLocation]    Script Date: 10/24/2025 4:05:06 PM ******/
DROP PROCEDURE [dbo].[usp_InsertYextLocation]
GO

/****** Object:  StoredProcedure [dbo].[usp_InsertYextLocation]    Script Date: 10/24/2025 4:05:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/***
Stored Procedure: usp_InsertYextLocation
***/

CREATE PROCEDURE [dbo].[usp_InsertYextLocation]
    @Id NVARCHAR(50),
    @Name NVARCHAR(255),
    @AddressLine1 NVARCHAR(255),
    @City NVARCHAR(100),
    @Region NVARCHAR(50),
    @PostalCode NVARCHAR(20),
    @CountryCode NVARCHAR(10),
    @MainPhone NVARCHAR(50),
    @WebsiteUrl NVARCHAR(500),
    @Description NVARCHAR(MAX),
    @Latitude FLOAT,
    @Longitude FLOAT,
    @LastUpdated DATETIME,
    @SystemLoadDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [staging].[YextLocations] (
        Id, Name, AddressLine1, City, Region, PostalCode, CountryCode,
        MainPhone, WebsiteUrl, Description, Latitude, Longitude,
        LastUpdated, SystemLoadDate
    )
	--SELECT
 --       @Id, @Name, @AddressLine1, @City, @Region, @PostalCode, @CountryCode,
 --       @MainPhone, @WebsiteUrl, @Description, @Latitude, @Longitude,
 --       @LastUpdated, @SystemLoadDate

    VALUES (
        @Id, @Name, @AddressLine1, @City, @Region, @PostalCode, @CountryCode,
        @MainPhone, @WebsiteUrl, @Description, @Latitude, @Longitude,
        @LastUpdated, @SystemLoadDate
    );
END



;

GO



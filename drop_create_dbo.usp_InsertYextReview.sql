USE [Marketing]
GO

/****** Object:  StoredProcedure [dbo].[usp_InsertYextReview]    Script Date: 11/12/2025 5:08:27 PM ******/
DROP PROCEDURE [dbo].[usp_InsertYextReview]
GO

/****** Object:  StoredProcedure [dbo].[usp_InsertYextReview]    Script Date: 11/12/2025 5:08:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_InsertYextReview]
    @Id NVARCHAR(50),
    @EntityId NVARCHAR(50),
    @Source NVARCHAR(100),
    @Rating INT,
    @Title NVARCHAR(255),
    @Content NVARCHAR(MAX),
    @ReviewerName NVARCHAR(255),
    @ReviewerEmail NVARCHAR(255),
    @ReviewDate DATETIME,
    @ResponseContent NVARCHAR(MAX),
    @ResponseDate DATETIME,
    @LastUpdated DATETIME,
    @SystemLoadDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [staging].[YextReviews] (
        Id, EntityId, Source, Rating, Title, Content,
        ReviewerName, ReviewerEmail, ReviewDate,
        ResponseContent, ResponseDate, LastUpdated, SystemLoadDate
    )
    VALUES (
        @Id, @EntityId, @Source, @Rating, @Title, @Content,
        @ReviewerName, @ReviewerEmail, @ReviewDate,
        @ResponseContent, @ResponseDate, @LastUpdated, @SystemLoadDate
    );
END;

GO



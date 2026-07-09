-- Create ISO Request
CREATE PROCEDURE sp_CreateISORequest
    @RequesterId UNIQUEIDENTIFIER,
    @CategoryId INT,
    @Title NVARCHAR(200),
    @Description NVARCHAR(MAX),
    @TargetPrice DECIMAL(18, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NewRequestId UNIQUEIDENTIFIER = NEWID();

    INSERT INTO ISO_Requests (Id, RequesterId, CategoryId, Title, Description, TargetPrice)
    VALUES (@NewRequestId, @RequesterId, @CategoryId, @Title, @Description, @TargetPrice);

    SELECT @NewRequestId AS RequestId;
END
GO

-- Get active ISO Requests
CREATE PROCEDURE sp_GetISORequests
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        r.Id,
        r.RequesterId,
        u.DisplayName AS RequesterName,
        u.ProfileImageUrl AS RequesterProfileImage,
        r.CategoryId,
        c.Name AS CategoryName,
        r.Title,
        r.Description,
        r.TargetPrice,
        r.Status,
        r.CreatedAt
    FROM ISO_Requests r
    INNER JOIN Users u ON r.RequesterId = u.Id
    INNER JOIN Categories c ON r.CategoryId = c.Id
    WHERE r.Status = 'Active'
    ORDER BY r.CreatedAt DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- Create ISO Offer
CREATE PROCEDURE sp_CreateISOOffer
    @RequestId UNIQUEIDENTIFIER,
    @SellerId UNIQUEIDENTIFIER,
    @OfferPrice DECIMAL(18, 2),
    @Condition NVARCHAR(20),
    @Message NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @NewOfferId UNIQUEIDENTIFIER = NEWID();

    INSERT INTO ISO_Offers (Id, RequestId, SellerId, OfferPrice, Condition, Message)
    VALUES (@NewOfferId, @RequestId, @SellerId, @OfferPrice, @Condition, @Message);

    SELECT @NewOfferId AS OfferId;
END
GO

-- Get ISO Request Detail
CREATE PROCEDURE sp_GetISORequestDetail
    @RequestId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        r.Id,
        r.RequesterId,
        u.DisplayName AS RequesterName,
        u.ProfileImageUrl AS RequesterProfileImage,
        r.CategoryId,
        c.Name AS CategoryName,
        r.Title,
        r.Description,
        r.TargetPrice,
        r.Status,
        r.CreatedAt
    FROM ISO_Requests r
    INNER JOIN Users u ON r.RequesterId = u.Id
    INNER JOIN Categories c ON r.CategoryId = c.Id
    WHERE r.Id = @RequestId;
END
GO

-- Get Offers for ISO Request
CREATE PROCEDURE sp_GetOffersForRequest
    @RequestId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        o.Id,
        o.RequestId,
        o.SellerId,
        u.DisplayName AS SellerName,
        u.ProfileImageUrl AS SellerProfileImage,
        o.OfferPrice,
        o.Condition,
        o.Message,
        o.Status,
        o.CreatedAt
    FROM ISO_Offers o
    INNER JOIN Users u ON o.SellerId = u.Id
    WHERE o.RequestId = @RequestId
    ORDER BY o.CreatedAt ASC;
END
GO

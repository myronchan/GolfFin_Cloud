CREATE OR ALTER PROCEDURE sp_GetUserListings
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SELECT L.Id, L.Title, L.Price, L.Condition, L.Description, L.Location, L.Status, L.IsTradeEnabled, L.VideoUrl, L.CreatedAt, C.Name AS CategoryName,
           (SELECT TOP 1 ImageUrl FROM ListingImages WHERE ListingId = L.Id ORDER BY IsPrimary DESC, DisplayOrder ASC) AS PrimaryImageUrl
    FROM Listings L
    INNER JOIN Categories C ON L.CategoryId = C.Id
    WHERE L.SellerId = @UserId
    ORDER BY L.CreatedAt DESC;
END;
GO

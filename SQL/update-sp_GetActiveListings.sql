CREATE OR ALTER PROCEDURE sp_GetActiveListings
    @SearchTerm NVARCHAR(100) = NULL,
    @CategoryId INT = NULL,
    @Page INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SELECT L.Id, L.Title, L.Price, L.Condition, L.Description, L.Location, L.Status, L.IsTradeEnabled, L.VideoUrl, L.CreatedAt, C.Name AS CategoryName,
           (SELECT TOP 1 ImageUrl FROM ListingImages WHERE ListingId = L.Id ORDER BY IsPrimary DESC, DisplayOrder ASC) AS PrimaryImageUrl
    FROM Listings L
    INNER JOIN Categories C ON L.CategoryId = C.Id
    WHERE L.Status = 'Active'
      AND (@SearchTerm IS NULL OR L.Title LIKE '%' + @SearchTerm + '%' OR L.Description LIKE '%' + @SearchTerm + '%')
      AND (@CategoryId IS NULL OR L.CategoryId = @CategoryId)
    ORDER BY L.CreatedAt DESC
    OFFSET (@Page - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

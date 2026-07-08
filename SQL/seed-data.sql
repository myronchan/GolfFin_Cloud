-- SQL script to seed GolfFin database with sample data
-- Re-runnable: deletes existing data before seeding.

BEGIN TRANSACTION;

-- Disable constraints/delete records safely
DELETE FROM Notifications;
DELETE FROM PaymentMethods;
DELETE FROM TradeOffers;
DELETE FROM Orders;
DELETE FROM Messages;
DELETE FROM Conversations;
DELETE FROM ListingImages;
DELETE FROM Listings;
DELETE FROM Users;
DELETE FROM Categories;

-- 1. Insert Categories
SET IDENTITY_INSERT Categories ON;

INSERT INTO Categories (Id, Name, ParentCategoryId) VALUES (1, 'Woods', NULL);
INSERT INTO Categories (Id, Name, ParentCategoryId) VALUES (2, 'Irons', NULL);
INSERT INTO Categories (Id, Name, ParentCategoryId) VALUES (3, 'Hybrids', NULL);
INSERT INTO Categories (Id, Name, ParentCategoryId) VALUES (4, 'Wedges', NULL);
INSERT INTO Categories (Id, Name, ParentCategoryId) VALUES (5, 'Putters', NULL);

SET IDENTITY_INSERT Categories OFF;

-- 2. Insert 10 Users
DECLARE @User1 UNIQUEIDENTIFIER = NEWID();
DECLARE @User2 UNIQUEIDENTIFIER = NEWID();
DECLARE @User3 UNIQUEIDENTIFIER = NEWID();
DECLARE @User4 UNIQUEIDENTIFIER = NEWID();
DECLARE @User5 UNIQUEIDENTIFIER = NEWID();
DECLARE @User6 UNIQUEIDENTIFIER = NEWID();
DECLARE @User7 UNIQUEIDENTIFIER = NEWID();
DECLARE @User8 UNIQUEIDENTIFIER = NEWID();
DECLARE @User9 UNIQUEIDENTIFIER = NEWID();
DECLARE @User10 UNIQUEIDENTIFIER = NEWID();

INSERT INTO Users (Id, B2C_ObjectId, Email, DisplayName, ProfileImageUrl, Phone, ShippingAddress) VALUES
(@User1, 'b2c_user_001', 'tiger.woods@example.com', 'Tiger W.', 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=150', '+1 (555) 019-2831', '123 Fairway Ln, Augusta, GA'),
(@User2, 'b2c_user_002', 'rory.mcilroy@example.com', 'Rory M.', 'https://images.unsplash.com/photo-1593111774240-d529f12cf4bb?w=150', NULL, NULL),
(@User3, 'b2c_user_003', 'phil.mickelson@example.com', 'Phil M.', 'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?w=150', NULL, NULL),
(@User4, 'b2c_user_004', 'nelly.korda@example.com', 'Nelly K.', 'https://images.unsplash.com/photo-1592919016384-90aa38d3885d?w=150', NULL, NULL),
(@User5, 'b2c_user_005', 'scottie.scheffler@example.com', 'Scottie S.', 'https://images.unsplash.com/photo-1605296867304-46d5465a25f1?w=150', NULL, NULL),
(@User6, 'b2c_user_006', 'jon.rahm@example.com', 'Jon R.', 'https://images.unsplash.com/photo-1591491640784-3232eb748d4b?w=150', NULL, NULL),
(@User7, 'b2c_user_007', 'brooks.koepka@example.com', 'Brooks K.', 'https://images.unsplash.com/photo-1593111774642-a63af05e83ec?w=150', NULL, NULL),
(@User8, 'b2c_user_008', 'lexi.thompson@example.com', 'Lexi T.', 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=150', NULL, NULL),
(@User9, 'b2c_user_009', 'viktor.hovland@example.com', 'Viktor H.', 'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?w=150', NULL, NULL),
(@User10, 'b2c_user_010', 'ludvig.aberg@example.com', 'Ludvig A.', 'https://images.unsplash.com/photo-1592919016384-90aa38d3885d?w=150', NULL, NULL);

-- 2.1 Insert Payment Methods for Tiger W.
INSERT INTO PaymentMethods (Id, UserId, CardType, Last4, Expiry, IsDefault) VALUES
(NEWID(), @User1, 'Visa', '4242', '12/28', 1),
(NEWID(), @User1, 'Mastercard', '5555', '09/27', 0);

-- 3. Insert 150 Listings and their Images/Videos
-- We can create a temp table to hold listing metadata templates, then loop over them to create 150 listings.

CREATE TABLE #ListingsTemplate (
    Brand NVARCHAR(100),
    Model NVARCHAR(100),
    CategoryId INT,
    BasePrice DECIMAL(18, 2),
    Condition NVARCHAR(20),
    ImageUrl NVARCHAR(2048),
    Hand NVARCHAR(20),
    Shaft NVARCHAR(50),
    Flex NVARCHAR(20)
);

INSERT INTO #ListingsTemplate (Brand, Model, CategoryId, BasePrice, Condition, ImageUrl, Hand, Shaft, Flex) VALUES
('TaylorMade', 'Qi10 Max Driver', 1, 599.99, 'Like New', 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=500', 'Mens/Right', 'Graphite', 'Stiff'),
('Callaway', 'Paradym Ai Smoke Triple Diamond Driver', 1, 629.99, 'New', 'https://images.unsplash.com/photo-1591491640784-3232eb748d4b?w=500', 'Mens/Right', 'Graphite', 'X-Stiff'),
('Ping', 'G430 LST Driver', 1, 549.99, 'Very Good', 'https://images.unsplash.com/photo-1592919016384-90aa38d3885d?w=500', 'Mens/Left', 'Graphite', 'Stiff'),
('Titleist', 'TSR3 Driver', 1, 499.00, 'Good', 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=500', 'Mens/Right', 'Graphite', 'Regular'),
('Cobra', 'Darkspeed X Driver', 1, 449.99, 'Gently Used', 'https://images.unsplash.com/photo-1591491640784-3232eb748d4b?w=500', 'Mens/Right', 'Graphite', 'Regular'),
('TaylorMade', 'Stealth 2 Fairway Wood', 1, 279.99, 'Good', 'https://images.unsplash.com/photo-1592919016384-90aa38d3885d?w=500', 'Mens/Right', 'Graphite', 'Stiff'),
('Callaway', 'Apex Utility Wood', 1, 249.99, 'Very Good', 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=500', 'Mens/Right', 'Graphite', 'Stiff'),
('Titleist', 'TSR2 Hybrid', 3, 199.99, 'Like New', 'https://images.unsplash.com/photo-1591491640784-3232eb748d4b?w=500', 'Womens/Right', 'Graphite', 'Ladies'),
('Ping', 'G425 Hybrid', 3, 169.50, 'Fair', 'https://images.unsplash.com/photo-1592919016384-90aa38d3885d?w=500', 'Mens/Right', 'Graphite', 'Regular'),
('Titleist', 'T100 Iron Set (5-PW)', 2, 899.99, 'Like New', 'https://images.unsplash.com/photo-1593111774642-a63af05e83ec?w=500', 'Mens/Right', 'Steel', 'Stiff'),
('Ping', 'i230 Iron Set (4-UW)', 2, 799.00, 'Very Good', 'https://images.unsplash.com/photo-1593111774642-a63af05e83ec?w=500', 'Mens/Right', 'Steel', 'Stiff'),
('Callaway', 'Paradym Iron Set (5-AW)', 2, 749.99, 'Good', 'https://images.unsplash.com/photo-1593111774642-a63af05e83ec?w=500', 'Mens/Left', 'Steel', 'Regular'),
('Mizuno', 'JPX923 Hot Metal Irons', 2, 699.99, 'Gently Used', 'https://images.unsplash.com/photo-1593111774642-a63af05e83ec?w=500', 'Mens/Right', 'Steel', 'Stiff'),
('Titleist', 'Vokey Design SM10 Wedge', 4, 189.00, 'New', 'https://images.unsplash.com/photo-1592919016384-90aa38d3885d?w=500', 'Mens/Right', 'Steel', 'Wedge Flex'),
('TaylorMade', 'Milled Grind 4 Wedge', 4, 159.99, 'Like New', 'https://images.unsplash.com/photo-1592919016384-90aa38d3885d?w=500', 'Mens/Right', 'Steel', 'Stiff'),
('Cleveland', 'RTX ZipCore Wedge', 4, 119.99, 'Good', 'https://images.unsplash.com/photo-1592919016384-90aa38d3885d?w=500', 'Womens/Right', 'Graphite', 'Ladies'),
('Scotty Cameron', 'Super Select Newport 2', 5, 449.99, 'Like New', 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=500', 'Mens/Right', 'Steel', 'Putter'),
('Odyssey', 'Ai-ONE #7 Putter', 5, 299.99, 'New', 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=500', 'Mens/Left', 'Steel', 'Putter'),
('PING', 'PLD Milled Anser Putter', 5, 379.00, 'Very Good', 'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=500', 'Mens/Right', 'Steel', 'Putter');

-- Define 15 Sample video URLs
CREATE TABLE #Videos (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Url NVARCHAR(2048)
);

INSERT INTO #Videos (Url) VALUES
('https://assets.mixkit.co/videos/preview/mixkit-golf-player-swinging-a-club-on-a-field-34304-large.mp4'),
('https://assets.mixkit.co/videos/preview/mixkit-golf-ball-rolling-into-the-cup-on-green-34306-large.mp4'),
('https://assets.mixkit.co/videos/preview/mixkit-close-up-of-a-golf-ball-on-a-tee-34307-large.mp4'),
('https://assets.mixkit.co/videos/preview/mixkit-golf-player-hitting-the-ball-from-sand-34308-large.mp4'),
('https://assets.mixkit.co/videos/preview/mixkit-golf-balls-lying-in-a-basket-34305-large.mp4'),
('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4'),
('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4'),
('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4'),
('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4'),
('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4'),
('https://assets.mixkit.co/videos/preview/mixkit-golf-player-swinging-a-club-on-a-field-34304-large.mp4'),
('https://assets.mixkit.co/videos/preview/mixkit-golf-ball-rolling-into-the-cup-on-green-34306-large.mp4'),
('https://assets.mixkit.co/videos/preview/mixkit-close-up-of-a-golf-ball-on-a-tee-34307-large.mp4'),
('https://assets.mixkit.co/videos/preview/mixkit-golf-player-hitting-the-ball-from-sand-34308-large.mp4'),
('https://assets.mixkit.co/videos/preview/mixkit-golf-balls-lying-in-a-basket-34305-large.mp4');

-- Generate 150 items
DECLARE @Counter INT = 1;
DECLARE @TemplateCount INT = (SELECT COUNT(*) FROM #ListingsTemplate);
DECLARE @VideoCounter INT = 1;

WHILE @Counter <= 150
BEGIN
    -- Determine Seller
    DECLARE @SellerId UNIQUEIDENTIFIER;
    DECLARE @SellerRand INT = @Counter % 10;
    IF @SellerRand = 0 SET @SellerId = @User1;
    IF @SellerRand = 1 SET @SellerId = @User2;
    IF @SellerRand = 2 SET @SellerId = @User3;
    IF @SellerRand = 3 SET @SellerId = @User4;
    IF @SellerRand = 4 SET @SellerId = @User5;
    IF @SellerRand = 5 SET @SellerId = @User6;
    IF @SellerRand = 6 SET @SellerId = @User7;
    IF @SellerRand = 7 SET @SellerId = @User8;
    IF @SellerRand = 8 SET @SellerId = @User9;
    IF @SellerRand = 9 SET @SellerId = @User10;

    -- Choose template row
    DECLARE @TemplateRowId INT = (@Counter % @TemplateCount) + 1;
    
    DECLARE @Brand NVARCHAR(100), @Model NVARCHAR(100), @CategoryId INT, @BasePrice DECIMAL(18,2), @Condition NVARCHAR(20), @ImageUrl NVARCHAR(2048);
    
    ;WITH CTE AS (
        SELECT Brand, Model, CategoryId, BasePrice, Condition, ImageUrl, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as RowNum
        FROM #ListingsTemplate
    )
    SELECT @Brand = Brand, @Model = Model, @CategoryId = CategoryId, @BasePrice = BasePrice, @Condition = Condition, @ImageUrl = ImageUrl
    FROM CTE
    WHERE RowNum = @TemplateRowId;

    -- Add variation to title, price
    DECLARE @Title NVARCHAR(200) = @Brand + ' ' + @Model + ' - #' + CAST(@Counter AS NVARCHAR(10));
    DECLARE @Price DECIMAL(18,2) = @BasePrice + ((@Counter % 7) - 3) * 5.00;
    DECLARE @Desc NVARCHAR(MAX) = 'This is a great ' + @Brand + ' ' + @Model + '. Sparingly used, clean details. Message me with questions or trades!';
    DECLARE @Loc NVARCHAR(200) = CASE (@Counter % 5)
        WHEN 0 THEN 'Pebble Beach, CA'
        WHEN 1 THEN 'Scottsdale, AZ'
        WHEN 2 THEN 'Orlando, FL'
        WHEN 3 THEN 'St Andrews, UK'
        ELSE 'Bandon Dunes, OR'
    END;

    -- Video assignment logic: Assign one of 15 videos to the first 15 listings
    DECLARE @VideoUrl NVARCHAR(2048) = NULL;
    IF @Counter <= 15
    BEGIN
        SET @VideoUrl = (SELECT Url FROM #Videos WHERE Id = @VideoCounter);
        SET @VideoCounter = @VideoCounter + 1;
    END

    -- Insert Listing
    DECLARE @ListingId UNIQUEIDENTIFIER = NEWID();
        -- Calculate price dynamically with some random variation
        DECLARE @T_Brand NVARCHAR(100) = @Brand;
        DECLARE @T_Model NVARCHAR(100) = @Model;
        DECLARE @T_CategoryId INT = @CategoryId;
        DECLARE @T_Condition NVARCHAR(20) = @Condition;
        DECLARE @I INT = @Counter;
        DECLARE @CreatedAt DATETIME = GETDATE();
        DECLARE @Location NVARCHAR(200) = @Loc;
        DECLARE @ActualPrice DECIMAL(18, 2) = @Price * (1 + (RAND() * 0.2 - 0.1)); -- +/- 10%
        
        DECLARE @T_Hand NVARCHAR(20) = (SELECT Hand FROM #ListingsTemplate WHERE Brand = @T_Brand AND Model = @T_Model);
        DECLARE @T_Shaft NVARCHAR(50) = (SELECT Shaft FROM #ListingsTemplate WHERE Brand = @T_Brand AND Model = @T_Model);
        DECLARE @T_Flex NVARCHAR(20) = (SELECT Flex FROM #ListingsTemplate WHERE Brand = @T_Brand AND Model = @T_Model);

        INSERT INTO Listings (
            Id, SellerId, CategoryId, Title, Price, Condition, Description, Location, Status, IsTradeEnabled, VideoUrl, CreatedAt, UpdatedAt, Manufacturer, ClubModel, Hand, Shaft, Flex
        ) VALUES (
            @ListingId,
            @SellerId,
            @T_CategoryId,
            @T_Brand + ' ' + @T_Model,
            @ActualPrice,
            @T_Condition,
            'Selling my ' + @T_Brand + ' ' + @T_Model + ' in ' + @T_Condition + ' condition. Used for a few rounds, works great! Feel free to message me with any questions. Local pickup preferred but willing to ship.',
            @Location,
            CASE WHEN @I % 7 = 0 THEN 'Sold' ELSE 'Active' END,
            CASE WHEN @I % 5 = 0 THEN 1 ELSE 0 END, -- 20% allow trade
            @VideoUrl,
            @CreatedAt,
            @CreatedAt,
            @T_Brand,
            @T_Model,
            @T_Hand,
            @T_Shaft,
            @T_Flex
        );

    -- Insert Listing Images (1 primary image, and 1 extra random image)
    INSERT INTO ListingImages (ListingId, ImageUrl, IsPrimary, DisplayOrder)
    VALUES (@ListingId, @ImageUrl, 1, 0);

    INSERT INTO ListingImages (ListingId, ImageUrl, IsPrimary, DisplayOrder)
    VALUES (@ListingId, 'https://images.unsplash.com/photo-1592919016384-90aa38d3885d?w=500', 0, 1);

    SET @Counter = @Counter + 1;
END

-- Clean up temp tables
DROP TABLE #ListingsTemplate;
DROP TABLE #Videos;

-- 4. Trade Offers and Notifications Seed
DECLARE @TargetListing UNIQUEIDENTIFIER = (SELECT TOP 1 Id FROM Listings WHERE SellerId = @User2);
DECLARE @OfferedListing UNIQUEIDENTIFIER = (SELECT TOP 1 Id FROM Listings WHERE SellerId = @User1);

IF @TargetListing IS NOT NULL AND @OfferedListing IS NOT NULL
BEGIN
    INSERT INTO TradeOffers (Id, SenderId, ReceiverId, OfferedListingId, TargetListingId, CashAdjustment, Note, Status)
    VALUES (NEWID(), @User1, @User2, @OfferedListing, @TargetListing, 50.00, 'Hey Rory, interested in a trade?', 'Pending');

    INSERT INTO TradeOffers (Id, SenderId, ReceiverId, OfferedListingId, TargetListingId, CashAdjustment, Note, Status)
    VALUES (NEWID(), @User2, @User1, @TargetListing, @OfferedListing, 0.00, 'I would like to trade for your driver.', 'Pending');
END

INSERT INTO Notifications (Id, UserId, Title, Message, Type, IsRead) VALUES 
(NEWID(), @User1, 'New Trade Offer', 'Rory M. has sent you a trade offer.', 'Trade', 0),
(NEWID(), @User1, 'Order Shipped', 'Your order #GF-99281 has been shipped.', 'Order', 1),
(NEWID(), @User1, 'System Update', 'Welcome to GolfFin!', 'System', 1);

COMMIT TRANSACTION;
PRINT 'Successfully seeded 10 users, 11 categories, 150 listings, 300 listing images, and 15 listing videos.';

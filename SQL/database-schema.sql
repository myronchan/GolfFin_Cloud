-- GolfFin Database Schema for Azure SQL
-- Designed based on UI Wireframes

-- 1. Users Table (Core identity synced with Azure AD B2C)
CREATE TABLE Users (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    B2C_ObjectId NVARCHAR(100) UNIQUE NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    DisplayName NVARCHAR(100),
    ProfileImageUrl NVARCHAR(2048),
    Phone NVARCHAR(50),
    ShippingAddress NVARCHAR(MAX),
    CreatedAt DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    UpdatedAt DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET()
);

-- 2. Categories Table
CREATE TABLE Categories (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL,
    ParentCategoryId INT NULL REFERENCES Categories(Id) -- Supports "Clubs (Driver)" hierarchy
);

-- 3. Listings Table (Expanded with Condition and Status)
CREATE TABLE Listings (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    SellerId UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id),
    CategoryId INT NOT NULL REFERENCES Categories(Id),
    Title NVARCHAR(200) NOT NULL,
    Price DECIMAL(18, 2) NOT NULL,
    Condition NVARCHAR(20) NOT NULL CHECK (Condition IN ('New', 'Like New', 'Very Good', 'Good', 'Fair', 'Gently Used', 'Open Box')),
    Description NVARCHAR(MAX),
    Location NVARCHAR(200),
    Manufacturer NVARCHAR(100),
    ClubModel NVARCHAR(100),
    Hand NVARCHAR(20),
    Shaft NVARCHAR(50),
    Flex NVARCHAR(20),
    Status NVARCHAR(20) DEFAULT 'Active' CHECK (Status IN ('Active', 'Sold', 'Draft', 'Archived')),
    IsTradeEnabled BIT DEFAULT 0, -- Indicates if the seller is open to trading this item
    VideoUrl NVARCHAR(2048) NULL, -- Optional 5-10 second video URL
    CreatedAt DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    UpdatedAt DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET()
);

-- 4. Listing Images
CREATE TABLE ListingImages (
    Id INT PRIMARY KEY IDENTITY(1,1),
    ListingId UNIQUEIDENTIFIER NOT NULL REFERENCES Listings(Id) ON DELETE CASCADE,
    ImageUrl NVARCHAR(2048) NOT NULL,
    IsPrimary BIT DEFAULT 0,
    DisplayOrder INT DEFAULT 0
);

-- 5. Orders Table (For Checkout Flow)
CREATE TABLE Orders (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    BuyerId UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id),
    ListingId UNIQUEIDENTIFIER NOT NULL REFERENCES Listings(Id),
    TotalPrice DECIMAL(18, 2) NOT NULL,
    ShippingAddress NVARCHAR(MAX) NOT NULL,
    DeliveryMethod NVARCHAR(50),
    PaymentStatus NVARCHAR(20) DEFAULT 'Pending' CHECK (PaymentStatus IN ('Pending', 'Paid', 'Failed', 'Refunded')),
    OrderStatus NVARCHAR(20) DEFAULT 'Confirmed' CHECK (OrderStatus IN ('Confirmed', 'Shipped', 'Delivered', 'Cancelled')),
    CreatedAt DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    UpdatedAt DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET()
);

-- 5.1 Trade Offers Table
CREATE TABLE TradeOffers (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    SenderId UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id),
    ReceiverId UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id),
    OfferedListingId UNIQUEIDENTIFIER NOT NULL REFERENCES Listings(Id), -- The item being offered
    TargetListingId UNIQUEIDENTIFIER NOT NULL REFERENCES Listings(Id),  -- The item wanted in return
    CashAdjustment DECIMAL(18, 2) DEFAULT 0, -- Optional cash added to balance the trade
    Note NVARCHAR(500), -- Optional message from the sender to explain the offer
    ExpiresAt DATETIMEOFFSET, -- Timestamp when the offer automatically expires
    Status NVARCHAR(20) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Accepted', 'Rejected', 'Cancelled')),
    CreatedAt DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    UpdatedAt DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET()
);

-- 6. Chat / Messaging System
CREATE TABLE Conversations (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    ListingId UNIQUEIDENTIFIER REFERENCES Listings(Id),
    BuyerId UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id),
    SellerId UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id),
    LastMessageAt DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET()
);

CREATE TABLE Messages (
    Id BIGINT PRIMARY KEY IDENTITY(1,1),
    ConversationId UNIQUEIDENTIFIER NOT NULL REFERENCES Conversations(Id),
    SenderId UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id),
    Content NVARCHAR(MAX) NOT NULL,
    IsRead BIT DEFAULT 0,
    SentAt DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET()
);

-- 7. Reviews and Ratings
CREATE TABLE Reviews (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    OrderId UNIQUEIDENTIFIER UNIQUE NOT NULL REFERENCES Orders(Id),
    ReviewerId UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id),
    TargetUserId UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id),
    Rating INT CHECK (Rating >= 1 AND Rating <= 5),
    Comment NVARCHAR(MAX),
    CreatedAt DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET()
);

-- 8. Payment Methods
CREATE TABLE PaymentMethods (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id),
    CardType NVARCHAR(50) NOT NULL,
    Last4 NVARCHAR(4) NOT NULL,
    Expiry NVARCHAR(10) NOT NULL,
    IsDefault BIT DEFAULT 0,
    CreatedAt DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET(),
    UpdatedAt DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET()
);

-- 9. Notifications
CREATE TABLE Notifications (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL REFERENCES Users(Id),
    Title NVARCHAR(200) NOT NULL,
    Message NVARCHAR(MAX) NOT NULL,
    Type NVARCHAR(50) NOT NULL,
    IsRead BIT DEFAULT 0,
    CreatedAt DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET()
);

-- Indexes for Performance
CREATE INDEX IX_Listings_Status ON Listings(Status);
CREATE INDEX IX_Listings_SellerId ON Listings(SellerId);
CREATE INDEX IX_Listings_Category_Price ON Listings(CategoryId, Price);
CREATE INDEX IX_Messages_ConversationId ON Messages(ConversationId);
CREATE INDEX IX_Conversations_Participants ON Conversations(BuyerId, SellerId);
CREATE INDEX IX_ListingImages_ListingId ON ListingImages(ListingId);
CREATE INDEX IX_TradeOffers_ReceiverId ON TradeOffers(ReceiverId);
CREATE INDEX IX_TradeOffers_SenderId ON TradeOffers(SenderId);
CREATE INDEX IX_PaymentMethods_UserId ON PaymentMethods(UserId);
CREATE INDEX IX_Notifications_UserId ON Notifications(UserId);


-- ### Key Improvements based on UI Design:
-- 1.  **Condition Field**: Added to the `Listings` table as shown in the "Product Detail" and "Sell Item" screens.
-- 2.  **Order Management**: Added an `Orders` table to handle the checkout flow, including shipping addresses and delivery methods.
-- 3.  **Messaging System**: Introduced `Conversations` and `Messages` tables to support the "Chat / Inbox" wireframe.
-- 4.  **Reviews**: Added a `Reviews` table to support the "Seller Rating" displayed in the product details.
-- 5.  **Hierarchy**: The `Categories` table now supports a parent-child relationship (e.g., Category "Clubs" can have a sub-category "Driver").
-- 6.  **Soft States**: Included `Status` fields for listings and orders to track progress (Draft, Active, Sold).

-- <!--
-- [PROMPT_SUGGESTION]Can you generate the Prisma schema (schema.prisma) based on this expanded SQL design?[/PROMPT_SUGGESTION]
-- [PROMPT_SUGGESTION]How should I handle real-time chat updates in React Native using this database structure?[/PROMPT_SUGGESTION]
-- ->
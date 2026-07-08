-- =============================================
-- Author:      GolfFin System
-- Description: Get user's inbox conversations
-- =============================================
CREATE OR ALTER PROCEDURE sp_GetInbox
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.Id AS ConversationId,
        c.ListingId,
        c.BuyerId,
        c.SellerId,
        c.LastMessageAt,
        CASE 
            WHEN c.BuyerId = @UserId THEN s.DisplayName
            ELSE b.DisplayName
        END AS OtherUserName,
        CASE 
            WHEN c.BuyerId = @UserId THEN s.ProfileImageUrl
            ELSE b.ProfileImageUrl
        END AS OtherUserProfileImageUrl,
        (SELECT TOP 1 Content FROM Messages m WHERE m.ConversationId = c.Id ORDER BY SentAt DESC) AS LastMessageText,
        (SELECT COUNT(*) FROM Messages m WHERE m.ConversationId = c.Id AND m.SenderId != @UserId AND m.IsRead = 0) AS UnreadCount
    FROM 
        Conversations c
    INNER JOIN Users b ON c.BuyerId = b.Id
    INNER JOIN Users s ON c.SellerId = s.Id
    WHERE 
        c.BuyerId = @UserId OR c.SellerId = @UserId
    ORDER BY 
        c.LastMessageAt DESC;
END
GO

-- =============================================
-- Author:      GolfFin System
-- Description: Get messages for a conversation
-- =============================================
CREATE OR ALTER PROCEDURE sp_GetMessages
    @ConversationId UNIQUEIDENTIFIER,
    @UserId UNIQUEIDENTIFIER -- Passed to mark messages as read for this user
AS
BEGIN
    SET NOCOUNT ON;

    -- Mark messages as read
    UPDATE Messages
    SET IsRead = 1
    WHERE ConversationId = @ConversationId AND SenderId != @UserId AND IsRead = 0;

    -- Return messages
    SELECT 
        m.Id,
        m.ConversationId,
        m.SenderId,
        m.Content,
        m.IsRead,
        m.SentAt
    FROM 
        Messages m
    WHERE 
        m.ConversationId = @ConversationId
    ORDER BY 
        m.SentAt ASC;
END
GO

-- =============================================
-- Author:      GolfFin System
-- Description: Send a message (and create conversation if needed)
-- =============================================
CREATE OR ALTER PROCEDURE sp_SendMessage
    @SenderId UNIQUEIDENTIFIER,
    @ReceiverId UNIQUEIDENTIFIER,
    @ListingId UNIQUEIDENTIFIER = NULL, -- Optional, could be general chat
    @Content NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ConversationId UNIQUEIDENTIFIER;

    -- Check if a conversation already exists
    IF @ListingId IS NOT NULL
    BEGIN
        SELECT @ConversationId = Id 
        FROM Conversations 
        WHERE ListingId = @ListingId 
          AND ((BuyerId = @SenderId AND SellerId = @ReceiverId) OR (BuyerId = @ReceiverId AND SellerId = @SenderId));
    END
    ELSE
    BEGIN
        SELECT @ConversationId = Id 
        FROM Conversations 
        WHERE ListingId IS NULL 
          AND ((BuyerId = @SenderId AND SellerId = @ReceiverId) OR (BuyerId = @ReceiverId AND SellerId = @SenderId));
    END

    -- If no conversation exists, create one
    IF @ConversationId IS NULL
    BEGIN
        SET @ConversationId = NEWID();
        INSERT INTO Conversations (Id, ListingId, BuyerId, SellerId, LastMessageAt)
        VALUES (@ConversationId, @ListingId, @SenderId, @ReceiverId, SYSDATETIMEOFFSET());
    END
    ELSE
    BEGIN
        -- Update LastMessageAt
        UPDATE Conversations
        SET LastMessageAt = SYSDATETIMEOFFSET()
        WHERE Id = @ConversationId;
    END

    -- Insert the message
    INSERT INTO Messages (ConversationId, SenderId, Content, IsRead, SentAt)
    VALUES (@ConversationId, @SenderId, @Content, 0, SYSDATETIMEOFFSET());

    -- Return the inserted message details (e.g. Identity ID, ConversationId)
    SELECT 
        SCOPE_IDENTITY() AS MessageId,
        @ConversationId AS ConversationId,
        @SenderId AS SenderId,
        @Content AS Content,
        SYSDATETIMEOFFSET() AS SentAt;
END
GO

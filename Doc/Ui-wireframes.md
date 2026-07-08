# ISO (In Search Of) Feature - UI Wireframes

## 1. ISO Feed / Marketplace Tab
A dedicated feed or a toggle in the main marketplace to view ISO requests.

```text
+-----------------------------------+
| < Back     Marketplace      [+]   |
+-----------------------------------+
| [ For Sale ]    [ *In Search Of*] |
+-----------------------------------+
| Filters: [ All Categories v ]     |
+-----------------------------------+
|                                   |
| (O) Sarah Jenkins       2h ago    |
| Looking for: TaylorMade Stealth 2 |
| Description: Must be right handed |
|              stiff flex.          |
| Target Price: $250                |
|                                   |
| [      I HAVE THIS ITEM       ]   |
+-----------------------------------+
|                                   |
| (O) Mike R.             5h ago    |
| Looking for: Titleist Pro V1x     |
| Target Price: $30 / dozen         |
|                                   |
| [      I HAVE THIS ITEM       ]   |
+-----------------------------------+
```

- **Header**: "In Search Of" / "Looking to Buy"
- **Filter/Sort**: By category, recent, distance.
- **List Items**:
  - Requester Profile Pic & Name
  - Title/Brief description of the item
  - Target Price (Optional)
  - Time posted
  - "I have this!" button for potential sellers

---

## 2. Create ISO Request Screen
Accessible via a floating action button or "Post" menu.

```text
+-----------------------------------+
| [X]       New ISO Request         |
+-----------------------------------+
| What are you looking for?         |
| [ e.g., Scotty Cameron Putter ]   |
|                                   |
| Description                       |
| +-------------------------------+ |
| | Add details like condition,   | |
| | specs, or specific features...| |
| |                               | |
| +-------------------------------+ |
|                                   |
| Category                          |
| [ Select Category             v ] |
|                                   |
| Target Price (Optional)           |
| [ $                 ]             |
|                                   |
| Reference Images (Optional)       |
| [ + Add Photo ]                   |
|                                   |
|                                   |
| [        POST REQUEST         ]   |
+-----------------------------------+
```

- **Title Input**: "What are you looking for?"
- **Description TextArea**: "Describe the item in detail..."
- **Category Dropdown**: Select relevant category
- **Target Price Input (Optional)**: "How much are you willing to pay?"
- **Image Upload (Optional)**: Reference images (e.g., "I'm looking for this specific model")
- **Submit Button**: "Post Request"

---

## 3. ISO Request Details Screen
When a user clicks on an ISO request from the feed.

```text
+-----------------------------------+
| < Back      Request Details       |
+-----------------------------------+
|                                   |
|       [ Reference Image ]         |
|                                   |
+-----------------------------------+
| TaylorMade Stealth 2 Driver       |
| Target Price: $250                |
|                                   |
| Description:                      |
| Must be right handed, stiff flex. |
| Good condition or better.         |
|                                   |
| Posted by:                        |
| (O) Sarah Jenkins                 |
|                                   |
+-----------------------------------+
|                                   |
| Do you have this item?            |
|                                   |
| [        MAKE AN OFFER        ]   |
| [        MESSAGE BUYER        ]   |
|                                   |
+-----------------------------------+
```

- **Full Details**: Title, Description, Reference Images, Category, Target Price.
- **Requester Info**: Profile summary.
- **Action for Sellers**: "Make an Offer" / "Message Buyer" button.
- **Action for Requester (if own post)**: "Edit", "Mark as Found", "Delete".

---

## 4. Make an Offer Screen (For Sellers)
When a seller clicks "Make an Offer" on someone else's ISO request.

```text
+-----------------------------------+
| < Back        Make Offer          |
+-----------------------------------+
| Offering to: Sarah Jenkins        |
| For: TaylorMade Stealth 2 Driver  |
+-----------------------------------+
| Your Selling Price                |
| [ $ 260             ]             |
|                                   |
| Condition                         |
| [ Used - Very Good            v ] |
|                                   |
| Message to Buyer (Optional)       |
| +-------------------------------+ |
| | I have this in great shape.   | |
| | Used for only one season.     | |
| +-------------------------------+ |
|                                   |
| Photos of your item               |
| [Img 1] [Img 2] [ + Add Photo ]   |
|                                   |
|                                   |
| [         SEND OFFER          ]   |
+-----------------------------------+
```

- **Item Condition**: Dropdown (New, Used, etc.)
- **Selling Price**: Input field.
- **Message**: Optional note to the buyer.
- **Photos**: Upload photos of the actual item the seller possesses.
- **Submit Button**: "Send Offer"

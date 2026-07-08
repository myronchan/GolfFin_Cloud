# ISO (In Search Of) Feature - Business Logic

## Core Workflows

### 1. Creating an ISO Request (Buyer)
- **Validation**: Ensure title and description meet minimum length requirements. Check against prohibited items policies.
- **Creation**: Save the ISO request to the database with status `active`.
- **Notification**: (Optional) Notify sellers who have subscribed to alerts for the chosen category.

### 2. Browsing & Discovering (Seller)
- **Retrieval**: Fetch `active` ISO requests, paginated and sortable by date or relevance.
- **Filtering**: Allow sellers to filter by category or keywords to find requests they can fulfill.

### 3. Fulfilling a Request / Making an Offer (Seller)
- **Validation**: Ensure seller's account is in good standing. Validate offer details (price, photos).
- **Creation**: Create an offer record linked to the ISO request.
- **Notification**: Send a push notification/email to the buyer that an offer has been made on their ISO request.

### 4. Reviewing Offers & Transaction (Buyer)
- **Review**: Buyer can view all offers made on their request.
- **Acceptance**: Buyer accepts an offer.
- **State Change**:
  - The accepted offer's status changes to `accepted`.
  - The ISO request status changes to `fulfilled` or `pending_transaction`.
  - Other pending offers are automatically declined or hidden.
- **Next Steps**: Transition to the standard transaction/chat flow used for regular marketplace items.

### 5. Managing Requests (Buyer)
- **Edit**: Update description or target price.
- **Cancel/Close**: Mark request as `closed` if they found the item elsewhere or changed their mind.

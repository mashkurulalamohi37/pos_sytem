# Firestore Security Rules - Production Configuration

This document explains the production-ready Firestore security rules for Aronium POS.

## Overview

The security rules implement **role-based access control (RBAC)** with three user roles:
- **Admin**: Full access to all collections
- **Manager**: Can manage products, categories, customers, sales, inventory (but not users)
- **Cashier**: Can create sales, view products/customers (read-only for most data)

## Security Principles

1. **Authentication Required**: All operations require authentication
2. **Active Users Only**: Only active users can perform operations
3. **Role-Based Access**: Permissions based on user roles
4. **Data Validation**: Required fields are validated on create/update
5. **Ownership Protection**: Users can only modify their own data where applicable
6. **Immutable Records**: Sales and cash sessions are protected from unauthorized modifications

## Collection Rules

### 1. Users Collection (`/users/{userId}`)

**Read:**
- Users can read their own document
- Admins can read all user documents

**Create:**
- Only admins can create users
- Must include required fields: `username`, `role`, `createdAt`, `updatedAt`
- Role must be one of: `admin`, `manager`, `cashier`
- New users must be active (`isActive == true`)

**Update:**
- Only admins can update users
- Users cannot change their own role

**Delete:**
- Only admins can delete users
- Admins cannot delete themselves

### 2. Products Collection (`/products/{productId}`)

**Read:**
- All authenticated active users can read products

**Create/Update/Delete:**
- Only admin/manager can create, update, or delete products
- Required fields on create: `name`, `price`, `stockQuantity`, `createdAt`, `updatedAt`

### 3. Categories Collection (`/categories/{categoryId}`)

**Read:**
- All authenticated active users can read categories

**Create/Update/Delete:**
- Only admin/manager can create, update, or delete categories
- Required fields on create: `name`, `createdAt`, `updatedAt`

### 4. Customers Collection (`/customers/{customerId}`)

**Read:**
- All authenticated active users can read customers

**Create/Update/Delete:**
- Only admin/manager can create, update, or delete customers
- Required fields on create: `name`, `createdAt`, `updatedAt`

### 5. Sales Collection (`/sales/{saleId}`)

**Read:**
- All authenticated active users can read sales

**Create:**
- All authenticated users can create sales (for POS checkout)
- Must include required fields: `userId`, `branchId`, `subtotal`, `totalAmount`, `paymentMethod`, `status`, `createdAt`
- `userId` must match the authenticated user
- `status` must be `completed`

**Update:**
- Only admin/manager can update sales (for refunds, corrections)

**Delete:**
- Only admin can delete sales

**Sale Items Subcollection (`/sales/{saleId}/items/{itemId}`):**
- All authenticated users can read sale items
- Can create items when creating a sale
- Only admin/manager can update sale items
- Only admin can delete sale items

### 6. Cash Sessions Collection (`/cashSessions/{sessionId}`)

**Read:**
- Users can read their own cash sessions
- Admin/manager can read all cash sessions

**Create:**
- Users can create their own cash sessions
- Required fields: `userId`, `branchId`, `openingCash`, `openedAt`, `status`
- `userId` must match the authenticated user
- `status` must be `open`

**Update:**
- Users can update their own open sessions
- Admin/manager can update any session
- Cannot change `userId`

**Delete:**
- Only admin can delete cash sessions

### 7. Tax Rates Collection (`/taxRates/{taxRateId}`)

**Read:**
- All authenticated active users can read tax rates

**Create/Update/Delete:**
- Only admin/manager can create, update, or delete tax rates
- Required fields on create: `name`, `rate`, `createdAt`, `updatedAt`

### 8. Stock Levels Collection (`/stockLevels/{stockLevelId}`)

**Read:**
- All authenticated active users can read stock levels

**Create/Update/Delete:**
- Only admin/manager can create, update, or delete stock levels

### 9. Stock Movements Collection (`/stockMovements/{movementId}`)

**Read:**
- All authenticated active users can read stock movements

**Create:**
- Only admin/manager can create stock movements
- Required fields: `productId`, `branchId`, `movementType`, `quantity`, `createdAt`

**Update:**
- Only admin/manager can update stock movements

**Delete:**
- Only admin can delete stock movements

### 10. Branches Collection (`/branches/{branchId}`)

**Read:**
- All authenticated active users can read branches

**Create/Update/Delete:**
- Only admin can create, update, or delete branches
- Required fields on create: `name`, `createdAt`, `updatedAt`

## Helper Functions

The rules use several helper functions:

- `isAuthenticated()`: Checks if user is authenticated
- `getUserData()`: Gets the user document data
- `hasRole(role)`: Checks if user has a specific role
- `isAdmin()`: Checks if user is admin
- `isManager()`: Checks if user is manager
- `isCashier()`: Checks if user is cashier
- `isAdminOrManager()`: Checks if user is admin or manager
- `isUserActive()`: Checks if user is active
- `hasRequiredFields(fields)`: Validates required fields

## Deployment

### Deploy Rules via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** > **Rules**
4. Copy the contents of `firestore.rules`
5. Paste into the rules editor
6. Click **Publish**

### Deploy Rules via Firebase CLI

```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase (if not already done)
firebase init firestore

# Deploy rules
firebase deploy --only firestore:rules
```

### Test Rules

Before deploying to production, test your rules:

1. Go to Firebase Console > Firestore Database > Rules
2. Click **Rules Playground**
3. Test various scenarios:
   - Admin creating a user
   - Cashier creating a sale
   - Manager updating a product
   - Unauthenticated user trying to read data

## Security Best Practices

1. **Regular Audits**: Review rules periodically for security gaps
2. **Monitor Access**: Use Firebase Audit Logs to monitor access patterns
3. **Test Thoroughly**: Test all user roles and operations
4. **Keep Updated**: Update rules as new features are added
5. **Backup Rules**: Keep a backup of your rules in version control

## Troubleshooting

### Common Issues

1. **Permission Denied Errors**
   - Check if user is authenticated
   - Verify user role in Firestore
   - Ensure user is active (`isActive == true`)
   - Check if operation is allowed for the user's role

2. **Missing Required Fields**
   - Ensure all required fields are included in create/update operations
   - Check field names match exactly (case-sensitive)

3. **Role Not Recognized**
   - Verify user document exists in `/users/{userId}`
   - Check `role` field value matches exactly: `admin`, `manager`, or `cashier`

## Migration from Open Rules

If you're migrating from open rules (like the temporary rules), follow these steps:

1. **Backup Current Data**: Export all Firestore data
2. **Deploy Rules**: Deploy the new production rules
3. **Test Thoroughly**: Test all user roles and operations
4. **Monitor**: Watch for permission denied errors
5. **Rollback Plan**: Keep the old rules as backup in case of issues

## Support

For issues or questions about security rules:
- Check [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- Review [Firestore Security Rules Examples](https://firebase.google.com/docs/firestore/security/rules-conditions)


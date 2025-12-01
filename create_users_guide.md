# Quick Guide: Creating Users in Firebase

## The Problem
If you're getting "Invalid username or password", it means the users haven't been created in Firebase Auth yet.

## Solution: Create Users in Firebase Console

### Step 1: Go to Firebase Console
1. Open https://console.firebase.google.com
2. Select your project: `possystem-e1655`

### Step 2: Enable Authentication
1. Go to **Authentication** in the left sidebar
2. Click **Get Started** if not already enabled
3. Go to **Sign-in method** tab
4. Enable **Email/Password** provider
5. Click **Save**

### Step 3: Create Users in Firebase Auth
1. Go to **Authentication** → **Users** in the left sidebar
2. Click **Add user** button
3. For each user, fill in:

#### Admin User:
- **Email**: `admin@aronium.local`
- **Password**: `admin123`
- **Email verified**: ✅ (check this box)

#### Manager User:
- **Email**: `manager@aronium.local`
- **Password**: `manager123`
- **Email verified**: ✅

#### Cashier User:
- **Email**: `cashier@aronium.local`
- **Password**: `cashier123`
- **Email verified**: ✅

### Step 4: Create Users in Firestore
After creating auth users, you need to create corresponding documents in the `users` collection in Firestore:

1. Go to **Firestore Database** in Firebase Console
2. Create a collection named `users` if it doesn't exist
3. For each user, create a document with the following fields:

#### Admin User Document:
- **Document ID**: Use the Firebase Auth UID (you can find it in Authentication → Users)
- **Fields**:
  - `username`: `admin` (string)
  - `role`: `admin` (string)
  - `fullName`: `Administrator` (string, optional)
  - `isActive`: `true` (boolean)
  - `createdAt`: Current timestamp
  - `updatedAt`: Current timestamp

#### Manager User Document:
- **Document ID**: Firebase Auth UID
- **Fields**:
  - `username`: `manager` (string)
  - `role`: `manager` (string)
  - `fullName`: `Manager` (string, optional)
  - `isActive`: `true` (boolean)
  - `createdAt`: Current timestamp
  - `updatedAt`: Current timestamp

#### Cashier User Document:
- **Document ID**: Firebase Auth UID
- **Fields**:
  - `username`: `cashier` (string)
  - `role`: `cashier` (string)
  - `fullName`: `Cashier` (string, optional)
  - `isActive`: `true` (boolean)
  - `createdAt`: Current timestamp
  - `updatedAt`: Current timestamp

### Step 5: Test Login
Now try logging in with:
- Username: `admin`, Password: `admin123`
- Username: `manager`, Password: `manager123`
- Username: `cashier`, Password: `cashier123`

## Troubleshooting

### "Invalid login credentials"
- Make sure users are created in Authentication → Users
- Check that email format is exactly: `username@aronium.local`
- Verify password is correct
- Ensure email is verified

### "User not found"
- Users must be created in Firebase Auth first
- Check Authentication → Users to see if users exist
- Verify that corresponding documents exist in Firestore `users` collection

### "Email not verified"
- Make sure email is verified when creating users
- Or manually verify users in the Authentication → Users section

### Firestore Security Rules
Make sure your Firestore security rules allow authenticated users to read/write:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Note**: The above rules are permissive for development. For production, implement proper role-based access control.

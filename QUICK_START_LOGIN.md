# Quick Start: How to Login

## Prerequisites
Make sure you have:
1. ✅ Firebase project created
2. ✅ `google-services.json` file in `android/app/` folder
3. ✅ Firebase Authentication enabled
4. ✅ Firestore Database created

## Step-by-Step: Create Users and Login

### Step 1: Enable Email/Password Authentication

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Authentication** → **Sign-in method**
4. Click on **Email/Password**
5. Enable it and click **Save**

### Step 2: Create Users in Firebase Authentication

1. Go to **Authentication** → **Users**
2. Click **Add user** button
3. Create these 3 users:

**Admin User:**
- Email: `admin@aronium.local`
- Password: `admin123`
- ✅ Check "Email verified" (or verify manually after creation)

**Manager User:**
- Email: `manager@aronium.local`
- Password: `manager123`
- ✅ Check "Email verified"

**Cashier User:**
- Email: `cashier@aronium.local`
- Password: `cashier123`
- ✅ Check "Email verified"

### Step 3: Create User Documents in Firestore

After creating auth users, you need to create corresponding documents in Firestore:

1. Go to **Firestore Database** in Firebase Console
2. Click **Start collection** (if database is empty) or navigate to existing `users` collection
3. For each user, create a document:

**For Admin User:**
- Click **Add document**
- **Document ID**: Copy the UID from Authentication → Users (for the admin user)
- Add these fields:
  - `username` (string): `admin`
  - `role` (string): `admin`
  - `fullName` (string): `Administrator` (optional)
  - `isActive` (boolean): `true`
  - `createdAt` (timestamp): Click timestamp icon, use current time
  - `updatedAt` (timestamp): Click timestamp icon, use current time

**For Manager User:**
- Document ID: Manager user's UID
- Fields:
  - `username`: `manager`
  - `role`: `manager`
  - `fullName`: `Manager`
  - `isActive`: `true`
  - `createdAt`: Current timestamp
  - `updatedAt`: Current timestamp

**For Cashier User:**
- Document ID: Cashier user's UID
- Fields:
  - `username`: `cashier`
  - `role`: `cashier`
  - `fullName`: `Cashier`
  - `isActive`: `true`
  - `createdAt`: Current timestamp
  - `updatedAt`: Current timestamp

### Step 4: Set Firestore Security Rules (Important!)

1. Go to **Firestore Database** → **Rules**
2. Update the rules to allow authenticated users:

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

3. Click **Publish**

### Step 5: Login in the App

1. Run the app: `flutter run`
2. On the login screen, enter:
   - **Username**: `admin` (or `manager` or `cashier`)
   - **Password**: `admin123` (or `manager123` or `cashier123`)
3. Click **Login**

**Note**: The app automatically converts username to email format (`username@aronium.local`)

## Default Login Credentials

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Manager | `manager` | `manager123` |
| Cashier | `cashier` | `cashier123` |

## Troubleshooting

### "Invalid username or password"
- ✅ Verify user exists in Firebase Authentication
- ✅ Check email format is `username@aronium.local`
- ✅ Ensure password is correct
- ✅ Make sure email is verified

### "User not found"
- ✅ Check that Firestore `users` collection exists
- ✅ Verify document exists with correct UID as document ID
- ✅ Ensure document has `username` field matching the login username

### "Permission denied" or Firestore errors
- ✅ Check Firestore security rules allow authenticated users
- ✅ Verify user is authenticated in Firebase Auth

### App crashes on login
- ✅ Check `google-services.json` is in `android/app/` folder
- ✅ Verify Firebase is initialized in `main.dart`
- ✅ Check console logs for specific error messages

## Quick Test

After setup, you can quickly test with:
- Username: `admin`
- Password: `admin123`

If login succeeds, you'll be redirected to the home screen!


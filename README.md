# Aronium POS - Full-Featured Point of Sale System

A comprehensive, offline-first Point of Sale (POS) system built with Flutter, featuring inventory management, sales tracking, customer management, and reporting capabilities.

## Features

### ✅ Implemented
- **Authentication & Roles**: Login system with role-based access (Admin, Manager, Cashier)
- **Firebase Integration**: Cloud authentication and database using Firebase Auth and Firestore
- **POS Checkout**: Complete point of sale interface with product selection, cart management, and payment processing
- **Database**: Firebase Firestore for cloud database with real-time sync
- **Clean Architecture**: Domain/Data/Presentation layers with repository pattern
- **State Management**: Riverpod for reactive state management
- **Cloud-First**: Firebase backend with real-time sync capabilities

### 🚧 In Progress / Planned
- Products & Categories CRUD screens
- Sales history and receipt generation
- Inventory management with stock movements
- Customer management with loyalty points
- Cash session management
- Reports with PDF/CSV export
- Thermal printer integration
- Barcode scanning
- Cloud sync (Firebase Firestore)

## Architecture

```
lib/
├── core/                    # Constants, utilities
├── domain/                  # Business logic layer
│   ├── entities/           # Domain models
│   └── repositories/       # Repository interfaces
├── data/                    # Data layer
│   ├── database/           # Drift database schema
│   └── repositories/       # Repository implementations
└── presentation/           # UI layer
    ├── screens/            # App screens
    ├── widgets/            # Reusable widgets
    └── providers/          # Riverpod providers
```

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Code

The project uses code generation for Drift database and other features. Run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run the App

```bash
flutter run
```

## Firebase Setup

Before running the app, you need to set up your Firebase project:

1. **Firebase Project**: Create a Firebase project at https://console.firebase.google.com
2. **Add Android App**: Add your Android app to the Firebase project (package: `com.example.aronium`)
3. **Download google-services.json**: Download the `google-services.json` file and place it in `android/app/`
4. **Enable Authentication**: In Firebase Console > Authentication, enable Email/Password authentication
5. **Create Firestore Database**: In Firebase Console > Firestore, create a new database
6. **Create Auth Users**: In Firebase Console > Authentication > Users, create users:
   - `admin@aronium.local` / `admin123`
   - `manager@aronium.local` / `manager123`
   - `cashier@aronium.local` / `cashier123`
7. **Create Users Collection**: Create a `users` collection in Firestore with documents for each user containing:
   - `username`: The username (e.g., "admin")
   - `role`: User role ("admin", "manager", or "cashier")
   - `fullName`: Full name (optional)
   - `isActive`: true
   - `createdAt`: Timestamp
   - `updatedAt`: Timestamp

## Default Login Credentials

- **Admin**: `admin` / `admin123` (email: `admin@aronium.local`)
- **Manager**: `manager` / `manager123` (email: `manager@aronium.local`)
- **Cashier**: `cashier` / `cashier123` (email: `cashier@aronium.local`)

**Note**: The app converts usernames to email format automatically (username@aronium.local)

## Database Schema

The app uses Firebase Firestore with the following main collections:

- **users**: User accounts with roles
- **products**: Product catalog with pricing and stock
- **categories**: Product categories
- **sales**: Sales transactions (with `items` subcollection)
- **stockLevels**: Current stock levels per branch
- **stockMovements**: Stock movement history
- **customers**: Customer database
- **cashSessions**: Cash drawer sessions
- **branches**: Store/branch locations

## Development Roadmap

1. ✅ Project setup and architecture
2. ✅ Database schema and repositories
3. ✅ Authentication and role-based navigation
4. ✅ POS checkout screen
5. 🚧 Products & Categories management
6. 🚧 Sales history and receipts
7. 🚧 Inventory management
8. 🚧 Customer management
9. 🚧 Cash sessions
10. 🚧 Reports and exports
11. 🚧 Printing integration
12. 🚧 Cloud sync

## Dependencies

- **flutter_riverpod**: State management
- **firebase_core**: Firebase core functionality
- **firebase_auth**: Firebase authentication
- **cloud_firestore**: Firebase Firestore database
- **pdf**: PDF generation
- **printing**: Print functionality
- **mobile_scanner**: Barcode scanning
- **intl**: Internationalization and formatting

## License

This project is private and proprietary.

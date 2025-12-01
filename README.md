# Aronium POS - Full-Featured Point of Sale System

<div align="center">

![Aronium POS](https://img.shields.io/badge/Aronium-POS-blue?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.8+-02569B?style=for-the-badge&logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Cloud-orange?style=for-the-badge&logo=firebase)
![License](https://img.shields.io/badge/License-Private-red?style=for-the-badge)

A comprehensive, cloud-based Point of Sale (POS) system built with Flutter and Firebase, featuring inventory management, sales tracking, customer management, barcode scanning, and comprehensive reporting capabilities.

[Features](#-features) • [Installation](#-installation) • [Quick Start](#-quick-start) • [Documentation](#-documentation)

</div>

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Firebase Setup](#-firebase-setup)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Role-Based Access Control](#-role-based-access-control)
- [Usage Guide](#-usage-guide)
- [Screenshots](#-screenshots)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

### 🔐 Authentication & Security
- **Firebase Authentication** with email/password
- **Role-Based Access Control** (Admin, Manager, Cashier)
- **Persistent Sessions** - Stay logged in across app restarts
- **Secure User Management** - Create, update, and manage user accounts

### 🛒 Point of Sale (POS)
- **Product Selection** - Browse and search products with category filtering
- **Cart Management** - Add/remove items, adjust quantities
- **Barcode Scanning** - Quick product lookup using mobile scanner
- **Flexible Discounts** - Apply discounts per item or overall cart (fixed amount or percentage)
- **Customer Selection** - Optional customer assignment for sales
- **Multiple Payment Methods** - Cash, Card, Mobile Payment, etc.
- **Real-time Stock Updates** - Automatic inventory deduction after sales

### 📦 Inventory Management
- **Product Management** - Full CRUD operations for products
- **Category Management** - Organize products by categories
- **Stock Tracking** - Real-time stock quantity monitoring
- **Low Stock Alerts** - Visual indicators for products running low
- **Stock Adjustments** - Manual stock corrections
- **Branch Management** - Multi-location inventory support

### 👥 Customer Management
- **Customer Database** - Store customer information
- **Quick Customer Creation** - Add customers directly from POS
- **Customer Search** - Find customers quickly during checkout
- **Customer History** - Track sales by customer

### 💰 Sales & Reporting
- **Sales History** - Complete transaction history
- **Sale Details** - Detailed view of each transaction
- **Receipt Generation** - Professional PDF receipts with proper formatting
- **CSV Export** - Export sales reports to CSV format
- **Sales Reports** - Comprehensive sales analytics
- **Date Range Filtering** - Filter sales by date ranges

### 💵 Cash Session Management
- **Session Tracking** - Open and close cash sessions
- **Session History** - View past cash sessions
- **Balance Tracking** - Monitor cash drawer balances
- **Session Reports** - Detailed session summaries

### 🏢 User Management (Admin Only)
- **User CRUD** - Create, read, update, and delete users
- **Role Management** - Promote/demote users between roles
- **User Activation** - Activate/deactivate user accounts
- **User Search** - Find users quickly

### 📱 Additional Features
- **Barcode Integration** - Scan barcodes to add products
- **Product Status** - Active/Inactive product management
- **Responsive UI** - Optimized for various screen sizes
- **Offline Support** - Works with Firebase offline persistence
- **Currency Formatting** - All prices displayed in TK (Taka)

## 🛠 Tech Stack

### Frontend
- **Flutter** 3.8+ - Cross-platform UI framework
- **Dart** - Programming language
- **Riverpod** - State management
- **Material Design** - UI components

### Backend & Services
- **Firebase Auth** - Authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Core** - Firebase integration

### Key Packages
- `flutter_riverpod` - State management
- `firebase_core` - Firebase core functionality
- `firebase_auth` - Authentication
- `cloud_firestore` - Cloud database
- `mobile_scanner` - Barcode scanning
- `pdf` & `printing` - Receipt generation
- `intl` - Internationalization
- `share_plus` - File sharing
- `csv` - CSV export

## 📦 Prerequisites

Before you begin, ensure you have:

- **Flutter SDK** (3.8.1 or higher)
- **Dart SDK** (included with Flutter)
- **Android Studio** / **VS Code** with Flutter extensions
- **Firebase Account** - [Create one here](https://console.firebase.google.com)
- **Android Device/Emulator** or **iOS Simulator**
- **Git** - For version control

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/mashkurulalamohi37/pos_sytem.git
cd pos_sytem
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code (if needed)

The project uses code generation for some features:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Firebase Setup

Follow the [Firebase Setup Guide](#firebase-setup) below to configure Firebase.

### 5. Run the App

```bash
flutter run
```

## 🔥 Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add project**
3. Enter project name: `Aronium POS` (or your preferred name)
4. Follow the setup wizard

### Step 2: Add Android App

1. In Firebase Console, click **Add app** → **Android**
2. **Package name**: `com.example.aronium`
3. Download `google-services.json`
4. Place it in `android/app/` directory

### Step 3: Enable Authentication

1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Click **Save**

### Step 4: Create Firestore Database

1. Go to **Firestore Database**
2. Click **Create database**
3. Start in **Production mode** (or Test mode for development)
4. Choose a location

### Step 5: Set Firestore Security Rules

Go to **Firestore Database** → **Rules** and update:

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

Click **Publish**.

### Step 6: Create Initial Users

#### In Firebase Authentication:

1. Go to **Authentication** → **Users**
2. Click **Add user** and create:

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@aronium.local` | `admin123` |
| Manager | `manager@aronium.local` | `manager123` |
| Cashier | `cashier@aronium.local` | `cashier123` |

#### In Firestore Database:

1. Go to **Firestore Database**
2. Create collection: `users`
3. For each user, create a document with **Document ID = User UID** (from Authentication)
4. Add fields:

```json
{
  "username": "admin",
  "role": "admin",
  "fullName": "Administrator",
  "isActive": true,
  "createdAt": [timestamp],
  "updatedAt": [timestamp]
}
```

Repeat for manager and cashier with appropriate values.

## 🏁 Quick Start

1. **Complete Firebase Setup** (see above)
2. **Run the app**: `flutter run`
3. **Login** with default credentials:
   - Username: `admin`
   - Password: `admin123`
4. **Start using the app!**

For detailed login instructions, see [QUICK_START_LOGIN.md](QUICK_START_LOGIN.md)

## 📁 Project Structure

```
lib/
├── core/                    # Core utilities and constants
│   ├── constants.dart      # App-wide constants
│   └── firebase_config.dart # Firebase configuration
│
├── domain/                  # Business logic layer (Clean Architecture)
│   ├── entities/           # Domain models
│   │   ├── product.dart
│   │   ├── sale.dart
│   │   ├── user.dart
│   │   └── ...
│   └── repositories/       # Repository interfaces
│       ├── product_repository.dart
│       ├── sale_repository.dart
│       └── ...
│
├── data/                    # Data layer
│   ├── database/           # Local database (Drift)
│   │   └── app_database.dart
│   └── repositories/       # Repository implementations
│       ├── product_repository_firestore_impl.dart
│       ├── sale_repository_firestore_impl.dart
│       └── ...
│
└── presentation/           # UI layer
    ├── screens/            # App screens
    │   ├── pos/           # POS-related screens
    │   ├── products/      # Product management
    │   ├── sales/         # Sales history
    │   └── ...
    ├── widgets/           # Reusable widgets
    │   ├── barcode_scanner_widget.dart
    │   └── discount_dialog.dart
    └── providers/          # Riverpod providers
        ├── product_provider.dart
        ├── pos_provider.dart
        └── ...
```

## 👥 Role-Based Access Control

### Admin
- ✅ Full access to all features
- ✅ User management (create, edit, delete, promote/demote)
- ✅ All product/inventory management
- ✅ All sales and reports access
- ✅ Cash session management

### Manager
- ✅ Product and inventory management
- ✅ Sales and reports access
- ✅ Customer management
- ✅ Cash session management
- ❌ User management

### Cashier
- ✅ POS operations (sales)
- ✅ View products
- ✅ Quick customer creation
- ✅ View own sales history
- ❌ Product management
- ❌ Reports access
- ❌ User management

## 📖 Usage Guide

### Creating a Sale

1. Navigate to **POS** from the home screen
2. **Search or browse** products
3. **Tap products** to add to cart (or scan barcode)
4. Click **Next** to go to cart screen
5. **Select customer** (optional) or add new customer
6. **Apply discounts** (optional):
   - Per-item discount: Tap discount icon on item
   - Overall discount: Tap "Apply Discount" button
7. Review totals and click **Checkout**
8. Select **Payment Method** and complete sale

### Managing Products

1. Go to **Products** screen
2. Click **+** to add new product
3. Fill in product details:
   - Name, SKU, Barcode
   - Cost Price, Selling Price
   - Stock Quantity
   - Category
4. Toggle **Active** to show/hide in POS
5. Save product

### Viewing Sales Reports

1. Navigate to **Reports** screen
2. Select **Date Range** (optional)
3. View sales summary
4. Click **Export CSV** to download report

### Printing Receipts

1. Go to **Sales History**
2. Tap on any sale
3. Click **Print** icon
4. Select printer or save as PDF

## 📸 Screenshots

> **Note**: Screenshots will be added soon. The app features a modern, clean Material Design interface optimized for retail environments.

## 🤝 Contributing

This is a private project. For contributions or suggestions, please contact the repository owner.

## 📄 License

This project is **private and proprietary**. All rights reserved.

---

<div align="center">

**Built with ❤️ using Flutter & Firebase**

[Report Bug](https://github.com/mashkurulalamohi37/pos_sytem/issues) • [Request Feature](https://github.com/mashkurulalamohi37/pos_sytem/issues)

</div>

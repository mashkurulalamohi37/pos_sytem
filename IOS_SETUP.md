# iOS Setup Guide for Aronium POS

This guide will help you set up and run the Aronium POS app on iOS.

## Prerequisites

1. **macOS** - iOS development requires a Mac computer
2. **Xcode** - Install Xcode from the App Store (latest version recommended)
3. **CocoaPods** - Install CocoaPods if not already installed:
   ```bash
   sudo gem install cocoapods
   ```
4. **Flutter** - Ensure Flutter is installed and configured
5. **iOS Simulator or Physical Device** - For testing

## Setup Steps

### 1. Install iOS Dependencies

Navigate to the iOS directory and install CocoaPods dependencies:

```bash
cd ios
pod install
cd ..
```

### 2. Configure Firebase for iOS

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Click **Add app** → **iOS**
4. Enter your **Bundle ID** (found in `ios/Runner.xcodeproj` or `ios/Runner/Info.plist`)
   - Default: `com.example.aronium`
5. Download `GoogleService-Info.plist`
6. Place it in `ios/Runner/` directory
7. Add it to Xcode project (drag and drop into Runner folder in Xcode)

### 3. Update Bundle Identifier (Optional)

If you want to change the bundle identifier:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** project in the navigator
3. Select the **Runner** target
4. Go to **Signing & Capabilities** tab
5. Update **Bundle Identifier** to your desired value (e.g., `com.yourcompany.aronium`)

### 4. Configure Signing & Capabilities

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** project
3. Select the **Runner** target
4. Go to **Signing & Capabilities** tab
5. Select your **Team** (Apple Developer account)
6. Xcode will automatically manage signing

### 5. Permissions

The app requires the following permissions (already configured in `Info.plist`):

- **Camera** - For barcode scanning
- **Photo Library** - For saving receipts and reports

These are already set up in `ios/Runner/Info.plist`.

## Running the App

### On iOS Simulator

```bash
flutter run -d ios
```

Or select iOS Simulator from your IDE.

### On Physical Device

1. Connect your iOS device via USB
2. Trust the computer on your device
3. Enable Developer Mode on your device (iOS 16+)
4. Run:
   ```bash
   flutter run -d <device-id>
   ```

To see available devices:
```bash
flutter devices
```

## Building for Release

### Build IPA File

```bash
flutter build ipa
```

This creates an `.ipa` file in `build/ios/ipa/`

### Build App Bundle for App Store

```bash
flutter build ios --release
```

Then archive and upload from Xcode.

## Troubleshooting

### Issue: "CocoaPods not installed"

**Solution:**
```bash
sudo gem install cocoapods
cd ios
pod install
```

### Issue: "No Podfile found"

**Solution:**
```bash
cd ios
pod init
pod install
```

### Issue: "Firebase not working"

**Solution:**
1. Verify `GoogleService-Info.plist` is in `ios/Runner/`
2. Check it's added to Xcode project (should appear in Xcode navigator)
3. Clean and rebuild:
   ```bash
   flutter clean
   cd ios
   pod deintegrate
   pod install
   cd ..
   flutter pub get
   flutter run
   ```

### Issue: "Camera not working"

**Solution:**
1. Verify camera permission is in `Info.plist` (already added)
2. Check device settings: Settings → Privacy → Camera → Aronium
3. Grant camera permission when prompted

### Issue: "Build errors related to Swift"

**Solution:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Go to **File** → **Project Settings**
3. Set **Build System** to **New Build System**
4. Clean build folder: **Product** → **Clean Build Folder**

### Issue: "Signing errors"

**Solution:**
1. Open Xcode project
2. Select **Runner** target
3. Go to **Signing & Capabilities**
4. Select your **Team**
5. Ensure **Automatically manage signing** is checked

## iOS-Specific Features

### Camera/Barcode Scanning
- Uses `mobile_scanner` package
- Requires camera permission (already configured)
- Works on both simulator (with limitations) and physical devices

### File Sharing
- CSV export works on iOS
- Uses `share_plus` package
- Files are saved to app's temporary directory

### Firebase
- Fully supported on iOS
- Uses `GoogleService-Info.plist` for configuration

## Minimum iOS Version

The app supports **iOS 12.0 and above** (as configured in `ios/Podfile` and project settings).

## Testing Checklist

- [ ] App launches successfully
- [ ] Login works with Firebase
- [ ] Camera/barcode scanner works
- [ ] POS checkout flow works
- [ ] Receipt generation works
- [ ] CSV export works
- [ ] All screens are accessible
- [ ] Role-based access control works

## Additional Notes

- The app uses Firebase Firestore, so an internet connection is required
- Camera functionality works best on physical devices
- Some features may have limitations on iOS Simulator
- For App Store submission, ensure all privacy descriptions are accurate

## Support

If you encounter issues:
1. Check Flutter doctor: `flutter doctor`
2. Check iOS-specific issues: `flutter doctor -v`
3. Clean and rebuild the project
4. Check Xcode console for detailed error messages


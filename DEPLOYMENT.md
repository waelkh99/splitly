# iOS Deployment Guide (Template)

## App Info (Fill Before Release)
- **App Name:** `<YOUR_APP_NAME>`
- **Bundle ID:** `<YOUR_BUNDLE_ID>`
- **Team ID:** `<YOUR_TEAM_ID>`
- **Signing:** Automatic (recommended)

---

## 1. Pre-flight Checks

### Bundle ID & Display Name
- Bundle ID is set in `ios/Runner.xcodeproj/project.pbxproj`
- Display name is set in `ios/Runner/Info.plist` → `CFBundleDisplayName`

### Capabilities (Xcode → Runner → Signing & Capabilities)
- **Only Signing** should be present — nothing else
- Do NOT enable: Push Notifications, Background Modes, HealthKit, iCloud
- Local notifications do not require any capability entitlement

### App Icon
To regenerate icons from `assets/logo.png`:
```bash
dart run flutter_launcher_icons
```

---

## 2. Register on App Store Connect (first time only)
1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Apps → **+** → **New App**
3. Platform: iOS
4. Name: `<YOUR_APP_NAME>`
5. Bundle ID: `<YOUR_BUNDLE_ID>`
6. SKU: `<your-app-sku-001>`
7. Click **Create**

---

## 3. Build Release

```bash
cd "<PATH_TO_YOUR_FLUTTER_APP>"
flutter build ios --release
```

Expected output: `✓ Built build/ios/iphoneos/Runner.app`

---

## 4. Archive in Xcode

```bash
open "<PATH_TO_YOUR_FLUTTER_APP>/ios/Runner.xcworkspace"
```

In Xcode:
1. **Product → Destination → Any iOS Device (arm64)**
2. **Product → Archive**
3. Wait for Organizer to open with the archive

> **Note:** You may see a warning about `objective_c.framework` dSYM — this is a known Flutter/Xcode quirk and can be safely ignored. It does not block upload or submission.

---

## 5. Upload to App Store Connect

In the Organizer window:
1. Select the archive → **Distribute App**
2. Choose **App Store Connect** → Next
3. Choose **Upload** → Next
4. Leave all defaults → Next
5. Click **Upload**

Upload takes a few minutes. Build appears in App Store Connect → TestFlight within 5–15 minutes.

---

## 6. TestFlight (Recommended Before Submission)

1. App Store Connect → Your App → **TestFlight** tab
2. Wait for build to finish processing
3. Add testers and install on device to verify core app flows

---

## 7. App Store Submission

1. App Store Connect → Your App → **App Store** tab
2. Fill in: description, keywords, screenshots, and category
3. Age rating: 4+
4. Select the uploaded build
5. Submit for Review

---

## Future Releases

For each new version:
1. Bump version in `pubspec.yaml` (`version: 1.0.1+2` etc.)
2. Run `flutter build ios --release`
3. Archive in Xcode (Product → Archive)
4. Upload via Organizer
5. Select new build in App Store Connect and submit

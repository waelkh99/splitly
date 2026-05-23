# Android Port Plan

Splitly was built iOS-first. The Android scaffolding exists (from `flutter create`) but has never been built or tested. This doc is the punch list to get it from "untouched scaffolding" to "Play Store-ready."

---

## Prerequisites (one-time setup)

- [ ] Install **Android Studio** from https://developer.android.com/studio
  - Bundles the Android SDK, emulator, and SDK Manager
  - On first launch, accept the prompts to install SDK components
- [ ] Accept Android licenses: `flutter doctor --android-licenses`
- [ ] Verify with `flutter doctor` — Android toolchain should now show ✓
- [ ] Create an emulator (Android Studio → Device Manager → Pixel 7, API 34)
  - Or plug in a physical Android device with USB debugging enabled

---

## Phase A — Make it run cleanly

Goal: app boots on an Android emulator and the golden path works end-to-end.

### 1. Fix identity / branding
- [ ] Change `applicationId` in [android/app/build.gradle.kts:24](android/app/build.gradle.kts#L24) from `com.example.splitly` to a real package (e.g., `com.djangus.splitly` or whatever bundle ID matches the iOS side)
- [ ] Update `namespace` in [android/app/build.gradle.kts:9](android/app/build.gradle.kts#L9) to match
- [ ] Change `android:label="splitly"` → `"Splitly"` in [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)
- [ ] Update `pubspec.yaml` description — currently says "for iOS"

### 2. Launcher icons
- [ ] In [pubspec.yaml:46](pubspec.yaml#L46) flip `android: false` → `android: true` in the `flutter_launcher_icons` config
- [ ] Add `adaptive_icon_background` + `adaptive_icon_foreground` keys for Android 8+ adaptive icons (Android shows icons inside a system-chosen mask)
- [ ] Run `dart run flutter_launcher_icons` to regenerate

### 3. Manifest permissions
Currently no permissions declared, but the app uses features that need them on Android:
- [ ] Add `<uses-permission android:name="android.permission.CAMERA"/>` — required by `mobile_scanner` for QR scanning
- [ ] Add `<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>` (Android 13+) and/or `READ_EXTERNAL_STORAGE` (older) for `image_picker`
- [ ] If receipt photos ever attach via camera capture: `<uses-feature android:name="android.hardware.camera" android:required="false"/>`

### 4. First boot
- [ ] `flutter run -d <android-device-id>` and confirm the app launches
- [ ] Walk the golden path: Home → People Selection → Bill Split → Adjustments → Summary
- [ ] Test share flow (Android share sheet behaves differently than iOS)
- [ ] Test QR scan flow (camera permission prompt should appear)
- [ ] Test image picker (media permission prompt should appear)
- [ ] `flutter analyze` should still pass with zero issues

---

## Phase B — Polish

Goal: app feels native on Android, not like a transplanted iOS app.

### 1. Widget audit
- [ ] Grep for any `Cupertino*` widgets — replace with `Material` equivalents or wrap in `Platform.isIOS ? Cupertino : Material` branches
- [ ] Check `ListTile` / `SwitchListTile` styling looks right
- [ ] Check `showModalBottomSheet` (Adjustments sheet) — Android default is fine, but verify drag handle / safe area

### 2. Theming
- [ ] Verify `ThemeData` works for both light + Android system dark mode
- [ ] Status bar style — Android uses `SystemUiOverlayStyle`; make sure it reads well on light/dark surfaces
- [ ] Back button — Android hardware/gesture back must navigate correctly (Flutter `Navigator` handles this by default, but verify modal bottom sheets dismiss)

### 3. Platform-specific flows to retest
- [ ] **Share** — `share_plus` on Android uses the system share sheet. Verify share text wraps/displays correctly.
- [ ] **QR generation + scan** — confirm both directions of the groups flow work between iOS and Android (cross-platform import)
- [ ] **Hive storage** — should "just work" but verify data survives app restart on Android
- [ ] **Localization** — Android device language switching picks up correctly
- [ ] **Keyboard behavior** — `android:windowSoftInputMode="adjustResize"` is already set, but check forms (amount input, name input) don't hide behind the keyboard

### 4. Device size matrix
- [ ] Small phone (e.g., Pixel 4a, ~5.8")
- [ ] Large phone (e.g., Pixel 7 Pro, 6.7")
- [ ] Tablet (Pixel Tablet) — at minimum, doesn't crash; ideally looks OK
- [ ] Android 7 / API 24 (lowest reasonable target) up through Android 14 / API 34

---

## Phase C — Release prep

Goal: signed AAB uploadable to Play Console.

### 1. Signing
- [ ] Generate a release keystore: `keytool -genkey -v -keystore ~/splitly-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias splitly`
- [ ] Store the keystore **outside** the repo (never commit `.jks` files)
- [ ] Create `android/key.properties` (gitignored) with `storeFile`, `storePassword`, `keyAlias`, `keyPassword`
- [ ] Update [android/app/build.gradle.kts](android/app/build.gradle.kts) to load `key.properties` and wire up a real `signingConfigs.release` (replaces the TODO at line 35-38 that currently signs release with debug keys)
- [ ] Add `key.properties` and `*.jks` to `.gitignore`

### 2. Build config
- [ ] Set `versionCode` / `versionName` strategy (currently inherited from Flutter — fine, but document the bump rule)
- [ ] Enable R8/Proguard shrinking: `isMinifyEnabled = true`, `isShrinkResources = true` in release `buildTypes`
- [ ] Add Proguard rules if any plugins need them (`mobile_scanner`, `hive_flutter` are usually fine)
- [ ] Test the release build locally: `flutter build appbundle --release` then install via `bundletool`

### 3. Play Console setup
- [ ] Create app listing in Play Console (one-time $25 dev fee if account isn't already registered)
- [ ] Prepare store assets:
  - Feature graphic (1024×500)
  - Phone screenshots (at least 2, max 8) — 16:9 or 9:16
  - Short description (80 chars)
  - Full description (4000 chars)
  - App icon (512×512 PNG)
  - Privacy policy URL (required even for offline apps because of camera/photo permissions)
- [ ] Fill in Data Safety form — Splitly is genuinely offline, so this is mostly "no data collected"
- [ ] Content rating questionnaire
- [ ] Target API level — Play requires latest-1 (currently API 34 as of 2026)

### 4. Internal testing → production
- [ ] Upload AAB to **Internal testing** track first
- [ ] Add a few testers (own devices, friends)
- [ ] Promote to **Closed testing** → **Open testing** → **Production** in stages
- [ ] Monitor crash reports in Play Console for the first week

---

## Decisions deferred

- **Freemium / IAP**: Out of scope for this Android port. Once Android is shipping, revisit the freemium plan (one-time unlock vs subscription, feature gates). Google Play Billing has its own SDK separate from iOS StoreKit — the entitlement layer should be abstracted so either platform plugs in.
- **CI for Android builds**: Skipped for v1. Local builds are fine until release cadence justifies GitHub Actions / Codemagic.

---

## Open questions to revisit later

- Do you want the Android package name to match the iOS bundle ID (recommended for brand consistency), or a separate identifier?
- Minimum supported Android API level — default `flutter.minSdkVersion` is currently 21 (Android 5.0). Bumping to API 24 (Android 7) trims old devices but simplifies a few things.
- Do you want a single AAB for all Android devices, or per-ABI splits for smaller download size?

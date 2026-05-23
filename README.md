# Splitly

Offline-first iOS app for splitting group bills fast. Built with Flutter; an Android port is planned (see [ANDROID_PLAN.md](ANDROID_PLAN.md)).

## Overview

Splitly helps small groups split a bill in under a minute using a simple 3-step flow:

1. Choose people
2. Add/assign items (with or without receipt photo)
3. Review and share

The app runs entirely on-device with no backend and no account requirement.

## Current Features

- People selection with recent chips and quick add
- Add people mid-split without restarting the flow
- Reusable groups with QR-code import/export for sharing between devices
- Receipt photo canvas with movable, draggable item pins
- Manual item mode when no photo is used
- Equal **or unequal** item splits per assignee
- "Pay to" field to record who fronted the bill
- Multi-currency support
- Bill adjustments (tax, delivery, discount, total override)
- Share summary (image with text fallback)
- Local history (latest 10 splits) with detail view
- In-app user guide
- Onboarding flow for first-time users
- English and Arabic with RTL support

## Tech Stack

- Flutter (Material 3)
- Riverpod (`flutter_riverpod`) for state management
- Hive (`hive_flutter`) for local storage
- `image_picker` for receipt photos
- `share_plus` for sharing
- `qr_flutter` + `mobile_scanner` for group QR import/export
- `package_info_plus` for runtime app version
- `intl` + Flutter localization for i18n

## Project Structure

`lib/` follows a feature-first layout:

- `core/` app-wide concerns (theme, routing, l10n, storage, shared providers)
- `data/` models and repositories
- `features/` screens and feature-specific widgets/logic

## Getting Started

### Prerequisites

- Flutter SDK `^3.10.3`
- Xcode (for iOS builds)
- Android Studio + Android SDK (for Android builds — see [ANDROID_PLAN.md](ANDROID_PLAN.md))

### Install and Run

```bash
flutter pub get
flutter run
```

### Common Commands

```bash
flutter analyze
flutter test
flutter gen-l10n
```

## Documentation

- Product/implementation status: [PROGRESS.md](PROGRESS.md)
- Full product specification: [splitly_full_claude_spec.md](splitly_full_claude_spec.md)
- Generic iOS deployment manual template: [DEPLOYMENT.md](DEPLOYMENT.md)
- Android port roadmap (setup, polish, release prep): [ANDROID_PLAN.md](ANDROID_PLAN.md)

## Release Notes

### v1.0.3

- Unequal item splits — assignees can take different shares of the same item instead of always splitting evenly
- Item pins on the receipt canvas are now movable for clearer placement and reassignment
- People can be added mid-split without restarting the flow
- New in-app user guide
- "Pay to" field to record who covered the bill
- Multi-currency support
- Group import/export (QR-based) for sharing groups between devices
- Bug fixes

## Known Gaps

- No tip field yet
- No cloud sync/export
- Group editing is limited

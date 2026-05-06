# Splitly

Offline-first iOS app for splitting group bills fast.

## Overview

Splitly helps small groups split a bill in under a minute using a simple 3-step flow:

1. Choose people
2. Add/assign items (with or without receipt photo)
3. Review and share

The app runs entirely on-device with no backend and no account requirement.

## Current Features

- People selection with recent chips and quick add
- Reusable groups
- Receipt photo canvas with draggable item assignment
- Manual item mode when no photo is used
- Bill adjustments (tax, delivery, discount, total override)
- Share summary (image with text fallback)
- Local history (latest 10 splits)
- English and Arabic with RTL support

## Tech Stack

- Flutter (Material 3)
- Riverpod (`flutter_riverpod`) for state management
- Hive (`hive_flutter`) for local storage
- `image_picker` for receipt photos
- `share_plus` for sharing
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

- Product/implementation status: `PROGRESS.md`
- Full product specification: `splitly_full_claude_spec.md`
- Generic iOS deployment manual template: `DEPLOYMENT.md`

## Known Gaps

- No tip field yet
- No percentage/weighted split mode
- No cloud sync/export
- Group editing is limited

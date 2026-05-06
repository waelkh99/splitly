# Splitly — Build Progress

## What Is Splitly

An offline-first iOS bill-splitting app built in Flutter. The goal: split any shared bill in under 60 seconds, with minimal friction. Works entirely on-device — no accounts, no internet.

---

## Tech Stack

| Concern | Package | Version |
|---|---|---|
| State management | `flutter_riverpod` | ^2.6.1 |
| Local storage | `hive_flutter` | ^1.1.0 |
| Image picker | `image_picker` | ^1.1.2 |
| Share sheet | `share_plus` | ^10.1.4 |
| Localization | `flutter_localizations` + `intl` | ^0.20.2 |
| UUID generation | `uuid` | ^4.5.1 |

Flutter SDK: `^3.10.3` · iOS only · Material 3

---

## App Flow (3-Step Wizard)

```
Home → Step 1: Who's in? → Step 2: Split the bill → Step 3: Summary
                                        ↕
                               Adjustments (modal)
```

---

## Screens & Features

### Home Screen
- App logo + "New Split" CTA
- Quick links to History and Settings
- Settings icon (top-right)

### Step 1 — People Selection (`/people`)
- Recent people shown as tappable chips (tap to select/deselect)
- "Add person" chip → bottom sheet with name field
- "Paste names" → parses comma-separated string into chips
- Groups drawer (hamburger) — create, load, and reuse saved groups
- Next button enabled when ≥ 2 people selected

### Step 2 — Bill Split (`/split`)

The core screen. Full-height receipt canvas with a people drop-strip at the bottom.

**Receipt canvas (with photo)**
- Pick a receipt photo via `image_picker`
- Tap anywhere on the photo → floating item popup appears at the tap location
- Long-press any item pin → drag it to a person in the drop strip
- Item pins are color-coded: blue = assigned, grey = unassigned
- Ghost pin shown at tap location while the form is open

**Receipt canvas (no photo)**
- Manual item list shown in place of the photo
- "Add item" FAB to add items without a photo
- Same drag-to-assign and tap-to-edit behaviour

**Floating item popup (`_ItemFormPopup`)**
- Appears at the exact tap location on the canvas — no bottom modal
- Smart above/below positioning: shows above the tap point by default, flips below if near the top of the screen
- Screen-edge clamping so it never goes off-screen
- Fields: item name + price (side by side)
- Person chips below the fields (tap to toggle assignment)
- Saves the relative canvas position (`imageX`, `imageY`) so pins re-appear in the right place on re-open
- Keyboard does not push or compress the canvas (`resizeToAvoidBottomInset: false`)

**People drop-strip**
- Horizontal scrollable row of person cards at the bottom
- Each card is a `DragTarget<BillItem>` — drop an item pin onto a person to assign/unassign
- Shows each person's running total (updates live as items are assigned)
- Hidden while the item popup is open so it doesn't visually attach to the popup

**Adjustments (modal bottom sheet)**
- Triggered from the AppBar "Adjustments" button
- Fields: Tax, Delivery fee, Discount, Total override (2×2 grid)
- Uses `showModalBottomSheet(isScrollControlled: true)` + `Padding(EdgeInsets.only(bottom: viewInsets.bottom))` — keyboard-aware, slides above keyboard cleanly
- "Total override" replaces the item sum entirely (for when you just want to enter the receipt total directly)
- Live preview of the new total updates the summary

**Unassigned badge**
- AppBar badge shows count of unassigned items while any remain

### Step 3 — Summary (`/summary`)

**Share card (on-screen + captured as image)**
- Gradient header with localized app name (`l.appName` → `سبلتلي` in Arabic) and date
- Items list: each item shows name, assigned-person initials (coloured circles), and price
- Adjustments breakdown: subtotal → tax → delivery → discount (only shown when adjustments exist)
- Grand total (large, primary-coloured)
- Per-person breakdown: each person in a card with a **coloured left accent bar**, avatar, name, and their amount
- Footer: "Split with [AppName] ✨"
- All labels (Total, Subtotal, Tax, Delivery fee, Discount) are fully localised via ARB keys

**Sharing**
- "Share" button captures the share card as a PNG image (`RepaintBoundary` → `toImage` → `XFile`)
- Pixel ratio 3× for sharp output on Retina displays
- Saved to `Directory.systemTemp` then handed to `Share.shareXFiles`
- `sharePositionOrigin` always provided from the button's `RenderBox` — avoids iOS `UIActivityViewController` popover crash
- Falls back to plain text if image capture fails

**Auto-save to history**
- Session is saved to Hive on first render of the summary screen
- Pruned to last 10 entries

### History Screen (`/history`)
- List of past splits: date, total, people count
- Tap → detail screen with full per-person breakdown
- Share button on detail screen (plain text share)

### Groups Screen (`/groups`)
- List of saved groups (name + member count)
- Create group FAB → name + select from known people
- Swipe to delete

### Settings Screen (`/settings`)
- Language toggle: English / Arabic
- Currency field (default: JD)
- RTL layout mirrors automatically when Arabic is selected

---

## Data Models

### `Person`
```dart
String id;       // UUID
String name;
DateTime lastUsed;
```

### `BillItem`
```dart
String id;
String name;
double price;
List<String> assignedPersonIds;  // empty = unassigned, multiple = shared equally
double? imageX;  // 0.0–1.0 relative position on receipt photo
double? imageY;
```

### `Adjustment`
```dart
double tax;
double deliveryFee;
double discount;
double? totalOverride;  // replaces item sum when set
```

### `SplitSession` (active state in Riverpod)
```dart
String id;
List<Person> people;
List<BillItem> items;
Adjustment adjustment;
String? receiptImagePath;
DateTime createdAt;
```

### `SplitResult` (computed, never stored)
```dart
double total;
Map<String, double> amountPerPerson;  // personId → amount
```

**Split logic:**
- Item assigned to N people → each pays `price / N`
- Unassigned items split equally across all people
- `tax + deliveryFee - discount` split equally across all people
- `totalOverride` replaces item sum and is split equally

### `HistoryEntry`
```dart
String id;
DateTime date;
SplitSession session;
SplitResult result;
```

---

## Storage (Hive)

| Box | Content |
|---|---|
| `people` | All known `Person` objects |
| `groups` | All `Group` objects |
| `history` | Last 10 `HistoryEntry` objects (oldest pruned) |
| `settings` | `{ currency, locale }` |

No code generation — all models use `toMap()` / `fromMap()`.

---

## Riverpod Providers

| Provider | Type | Purpose |
|---|---|---|
| `splitSessionProvider` | `StateNotifierProvider` | Active session state |
| `splitResultProvider` | `Provider` (derived) | Computed result from session |
| `recentPeopleProvider` | `StateNotifierProvider` | Last-used people from Hive |
| `groupsProvider` | `StateNotifierProvider` | Groups from Hive |
| `historyProvider` | `StateNotifierProvider` | History entries from Hive |
| `settingsProvider` | `StateNotifierProvider` | Currency + locale settings |

---

## Theme

| Token | Value |
|---|---|
| Primary | `#1A7FD4` (blue) |
| Secondary | `#0ABFBC` (teal) |
| Background | `#F5F7FA` |
| Surface | `#FFFFFF` |
| Error | `#E53935` |
| Typography | System font (SF Pro on iOS) |

Material 3, `colorScheme.fromSeed`, custom `CardTheme`, `InputDecorationTheme`, `ElevatedButtonTheme`.

---

## Localisation

- Languages: English (`en`) and Arabic (`ar`)
- ARB files: `lib/core/l10n/app_en.arb` and `app_ar.arb`
- Generated via `flutter gen-l10n` (configured in `l10n.yaml`)
- Locale stored in Hive settings box, toggled from Settings screen
- RTL layout: Flutter mirrors automatically when `locale = ar`
- All UI labels in the share card are localised (no hardcoded English strings)
- App name localised: `Splitly` (EN) → `سبلتلي` (AR)

---

## Key Engineering Decisions

### No bottom modals for item entry
Bottom sheets caused the receipt photo to be barely visible when the keyboard opened, regardless of `resizeToAvoidBottomInset` setting. Replaced with a floating popup that appears at the exact tap location on the canvas. The popup positions itself above or below the tap point based on available space, and is clamped to screen edges.

### Keyboard handling (`resizeToAvoidBottomInset: false`)
The bill split screen uses `false` to prevent the canvas from shrinking. The popup is positioned using `MediaQuery.of(context).viewInsets.bottom` to stay above the keyboard. Adjustments use a proper modal bottom sheet with `isScrollControlled: true` which Flutter handles natively.

### iOS share crash fix
`share_plus` on iOS crashes when `sharePositionOrigin` is `CGRectZero` (the native `popoverPresentationController` requires a non-zero origin rect). Fixed by always computing the button's `RenderBox` rect and passing it as `sharePositionOrigin`.

### Drag-and-drop assignment
`LongPressDraggable<BillItem>` on item pins + `DragTarget<BillItem>` on person cards in the drop strip. Drop calls `togglePersonOnItem` — adds the person if not assigned, removes them if already assigned. This makes drag-drop a toggle, not a one-way assignment.

### Share image generation
`RepaintBoundary` wraps the share card widget. On share: `boundary.toImage(pixelRatio: 3.0)` → `toByteData(ImageByteFormat.png)` → write to `Directory.systemTemp` → `Share.shareXFiles([XFile(path)])`. The card is visible on screen so what you see is exactly what gets shared (WYSIWYG).

---

## File Structure

```
lib/
  main.dart
  app.dart
  core/
    l10n/          ← ARB files + generated localizations
    providers/     ← Riverpod providers (session, result, people, groups, history, settings)
    router/        ← Named routes
    storage/       ← Hive init + box accessors
    theme/         ← AppColors, AppTheme
    utils/         ← currency_formatter, share_formatter
    widgets/       ← StepIndicator
  data/
    models/        ← Person, BillItem, Adjustment, SplitSession, SplitResult, Group, HistoryEntry
    repositories/  ← People, Groups, History (Hive CRUD)
  features/
    home/
    people_selection/
    bill_split/
      bill_split_screen.dart      ← Main canvas + floating popup + drop strip
      widgets/
        receipt_canvas.dart       ← Photo canvas + manual list + drag pins
    summary/
      summary_screen.dart         ← Share card + image capture + share
    history/
    groups/
    settings/
assets/
  logo.png                        ← App icon (1024×1024, used by flutter_launcher_icons)
```

---

## Known Limitations / Future Work

- No tip splitting (tip field could be added to Adjustments)
- No split-by-percentage option (only equal splits for shared items)
- History limited to 10 entries (intentional — keeps storage lean)
- No iCloud sync or export
- Groups screen does not yet support editing group members after creation

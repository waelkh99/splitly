# Splitly — Ultra-Fast Social Bill Splitter

## 1. Product Overview
Splitly is a lightweight, offline-first mobile application designed to quickly split shared bills in social environments (restaurants, delivery orders, office meals).

### Core Goal
Enable users to split a bill in under 60 seconds with minimal input and zero confusion.

---

## 2. Core Principles
- Speed over precision
- Minimal input required
- No accounts / no backend
- Designed for real-life group behavior
- Instant shareability (WhatsApp-first)

---

## 3. Target Users
- Office teams ordering food
- Friend groups dining out
- Small recurring social groups

---

## 4. App Flow

### Step 1: Who’s In?
#### UI
- Chip-based user selection
- Recent users auto-suggested
- Groups available in side drawer

#### Features
- Tap to select users
- Add user inline
- Paste multiple names (comma-separated)
- “Use last group” shortcut

---

### Step 2: Bill Split

#### Layout
- Right: Receipt image
- Left: People canvas

#### Interactions
- Drag item → assign to person
- Tap item → assign/reassign
- Multi-select → batch assign

---

### Adjustments Panel
Optional:
- Total override
- Tax
- Delivery fee
- Discount

All adjustments split equally.

---

### Output
WhatsApp-ready text:

🍽️ Splitly Bill Summary
Total: XX JD

User A: XX
User B: XX

---

## 5. Groups System
- Create group
- Save group
- Reuse groups
- Groups act as shortcuts

---

## 6. History
- Store last 10 splits
- View + share again

---

## 7. Localization

### Languages
- English
- Arabic

### Requirements
- Full RTL support
- Layout mirroring
- Arabic-friendly phrasing

---

## 8. App Icon
- Minimal, no text
- Receipt split visual
- Blue/teal color palette
- iOS compliant (1024x1024)

---

## 9. Tech Stack
- Flutter
- Local storage (Hive)
- Riverpod state management
- Offline-first

---

## 10. MVP Scope

### Must Have
- User chips
- Groups
- Receipt image
- Drag split system
- Adjustments
- Share output
- Arabic + English

### Not Included
- Backend
- Accounts
- OCR
- Payments

---

## 11. Success Metric
User can split a bill in under 60 seconds.

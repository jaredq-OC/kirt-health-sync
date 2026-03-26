# Kirt Health Sync

Custom iPhone app that syncs Apple Health data to Firebase Firestore every ~15 minutes via Background App Refresh.

## What It Syncs

- **Steps** — daily step count
- **Sleep** — sleep analysis by stage (REM, deep, core, awake)
- **Weight** — body mass in pounds
- **Workouts** — activity type, duration, calories burned
- **Nutrition** — calories, protein, carbs, fat, fiber, sugar, sodium
- **Resting Heart Rate** — trends from Apple Watch

## Setup Instructions

### Prerequisites
- Xcode 15+
- Apple Developer account with HealthKit capability enabled
- XcodeGen installed (`brew install xcodegen`)
- CocoaPods installed (`brew install cocoapods`) OR use SPM

### Step 1 — Configure Apple Developer Portal
1. Go to [developer.apple.com](https://developer.apple.com)
2. Create a new App ID: `com.kirt.healthsync`
3. Enable **HealthKit** capability
4. Generate a **Provisioning Profile** for development
5. Add your device to the portal

### Step 2 — Open in Xcode
```bash
cd KirtHealthSync
xcodegen generate  # generates .xcodeproj from project.yml
open KirtHealthSync.xcodeproj
```

Or use SPM directly in Xcode: File → Add Package Dependencies → add Firebase iOS SDK

### Step 3 — Add GoogleService-Info.plist
The `GoogleService-Info.plist` is already in `Resources/`. In Xcode:
1. Right-click on `KirtHealthSync` folder → Add Files
2. Select `Resources/GoogleService-Info.plist`
3. Make sure "Copy items if needed" is checked

### Step 4 — Configure Signing
In Xcode:
1. Select the `KirtHealthSync` target
2. Go to "Signing & Capabilities"
3. Set Team to your Apple Developer account
4. Set Bundle Identifier to `com.kirt.healthsync`
5. Enable HealthKit capability

### Step 5 — Build & Run
1. Connect your iPhone via USB
2. Select your device as the run destination
3. Press ⌘R to build and run

### Step 6 — Authorize HealthKit
On first launch, the app will request access to:
- Read: steps, sleep, workouts, nutrition, heart rate, weight
- Write: weight

Grant access for the sync to work.

## Project Structure

```
KirtHealthSync/
├── Sources/
│   ├── App/
│   │   ├── KirtHealthSyncApp.swift    # SwiftUI app entry point
│   │   └── AppDelegate.swift            # HealthKit + Firebase init
│   ├── HealthKit/
│   │   └── HealthKitManager.swift      # All HealthKit data syncing
│   └── Views/
│       └── ContentView.swift            # Main SwiftUI interface
├── Resources/
│   ├── GoogleService-Info.plist         # Firebase config
│   ├── Info.plist                       # App config
│   ├── LaunchScreen.storyboard
│   └── Assets.xcassets/
├── project.yml                          # XcodeGen config
└── Package.swift                        # SPM config
```

## Firebase

- Project: **Kirt Health Sync**
- Database: **Firestore** (nam5, production mode)
- Data stored in: `healthData` collection
- Documents keyed by type + timestamp

## How It Works

1. App launches → initializes Firebase + requests HealthKit authorization
2. Once authorized → schedules background task (every 15 min)
3. Background task fires → syncs last 1 hour of health data to Firestore
4. Manual "Sync Now" button triggers immediate sync

## Troubleshooting

**HealthKit not authorized:**
- Go to Settings → Privacy & Security → Health → Kirt Health Sync → enable access

**Firebase not connecting:**
- Verify `GoogleService-Info.plist` is added to the target in Xcode
- Check the bundle ID matches between Firebase and Apple Developer Portal

**Background sync not working:**
- Go to Settings → General → Background App Refresh → enable for Kirt Health Sync

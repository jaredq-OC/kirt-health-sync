# Kirt Health Sync

iPhone app that syncs Apple Health data to Firebase Firestore every ~15 minutes via Background App Refresh.

## What It Syncs
- Steps (daily total)
- Sleep stages (REM, deep, core, awake)
- Weight
- Workouts (type, duration, calories)
- Nutrition (calories, protein, carbs, fat, fiber, sugar, sodium)
- Resting heart rate

## Prerequisites
- Xcode 26+
- Apple Developer account
- Physical iPhone (HealthKit unavailable in simulator)
- Firebase project with Firestore enabled

## Setup

### 1. Clone the Repo
```bash
git clone https://github.com/jaredq-OC/kirt-health-sync.git
cd kirt-health-sync/KirtHealthSync
```

### 2. Add Firebase
1. Open `KirtHealthSync.xcodeproj` in Xcode
2. File → Add Package Dependencies
3. Add `https://github.com/firebase/firebase-ios-sdk`
4. Add these products: `FirebaseFirestore`, `FirebaseAuth`, `FirebaseAnalytics`

### 3. Add GoogleService-Info.plist
1. Download from Firebase Console → Project Settings → Your Apps → iOS app
2. Copy into `KirtHealthSync/Resources/` (overwrite the placeholder)

### 4. Configure Signing
1. Open `KirtHealthSync.xcodeproj`
2. Select the `KirtHealthSync` target
3. Signing & Capabilities → Enable "Automatically manage signing"
4. Select your Apple Developer team
5. Bundle ID must match your Firebase app's bundle ID

### 5. Build & Run
1. Connect iPhone via USB
2. Select your iPhone as the run destination
3. Press ⌘R to build and run
4. Authorize HealthKit permissions on the device

## Architecture
```
iPhone (HealthKit) → Firebase iOS SDK → Firestore (cloud)
```

## Background Sync
The app uses `BGTaskScheduler` to sync every ~15 minutes in the background. This requires:
- Physical iPhone (not simulator)
- HealthKit + Background App Refresh permissions on device
- The app has been launched at least once

## Data Structure (Firestore)
```
healthData/
  steps_<timestamp>   — { value, unit, startDate, endDate, timestamp }
  sleep_<timestamp>  — { totalMinutes, stages: {...}, startDate, endDate, timestamp }
  weight_<timestamp> — { value, unit, startDate, timestamp }
  workout_<timestamp>— { activityType, duration, energyBurned, startDate, endDate, timestamp }
  nutrition_<timestamp>— { nutrients: {...}, startDate, endDate, timestamp }
  restingHR_<timestamp>— { value, unit, startDate, timestamp }
```

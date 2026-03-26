# Build Attempts — apple-health-sync

## Attempt #1 — 2026-03-25
**Error:** Firebase iOS SDK version mismatch
**Fix:** Updated to Firebase 11.0.0 SPM

## Attempt #2 — 2026-03-25
**Error:** HKObjectType.categoryType vs quantityType for sleepAnalysis
**Fix:** Changed to categoryType(forIdentifier: .sleepAnalysis)

## Attempt #3 — 2026-03-25
**Error:** UIKit.framework copy error / framework not found
**Fix:** Changed project.yml from `framework:` to `sdk:` for system frameworks

## Attempt #4 — 2026-03-25
**Error:** sleepAnalysis iOS 16 availability guards
**Fix:** Wrapped in `if #available(iOS 16.0, *)`

## Attempt #5 — 2026-03-26
**Error:** workout.energyBurned deprecated
**Fix:** Changed to workout.totalEnergyBurned?.doubleValue

## Attempt #6 — 2026-03-26
**Error:** .xcodeproj gitignored — Kirt's Xcode couldn't resolve SPM packages
**Fix:** Committed .xcodeproj and Package.resolved to git

## Attempt #7 — 2026-03-26
**Error:** Xcode 26 deployment target mismatch (iOS 26.3 vs 26.4)
**Fix:** Set deployment target to 26.3 manually in Xcode UI

## Attempt #8 — 2026-03-26
**Error:** iPhone Development Mode not enabled
**Fix:** Enable Development Mode in Settings → restart device → success ✅

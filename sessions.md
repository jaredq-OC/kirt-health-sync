
## 2026-03-26 Session 5 — 22:37 AEDT
**Goal:** Get app running on physical iPhone

**Outcome:** SUCCESS ✅

**What happened:**
- Deployment target 26.3 needed manual override in Xcode: KirtHealthSync → General → Target changed to 26.3
- Codesign keychain password forgotten — had to work around it
- iPhone required **Enable Development Mode** toggle in Settings → Privacy & Security
- iPhone required restart after enabling Development Mode
- After restart: app installed and ran on physical iPhone ✅

**Key findings:**
- Xcode 26 does NOT read deployment target from project.yml correctly — must set manually in Xcode UI
- iOS 26 on physical iPhone requires "Enable Development Mode" (new in iOS 26)
- Development Mode requires a restart to activate

**Next steps:**
- Test HealthKit data sync on physical device
- Verify Firestore writes from device
- Set up Background App Refresh
- TestFlight deployment

## 2026-03-27 Session 6 — 00:25 AEDT
**Goal:** Build + test on local simulator; fix cascading SDK type errors

**Outcome:** SUCCESS ✅

**What happened:**
- Build failed with 4 types not in iOS 26 simulator SDK: distanceRunning, cardioFitnessLevel, electrocardiogram, mindfulnessSession
- Python edits during subagent session corrupted HealthKitManager.swift (extra/missing braces)
- File restored cleanly from git + fixes reapplied
- Build #2: blood glucose unit error (HKUnit millimolePerLiter invalid) + sortDescriptors array bug
- Build #3: framework linking errors (sdk: prefix not working, used working project.yml from c16e55a)
- Build #4 (final): **BUILD SUCCEEDED** ✅
- App installed and launched on iPhone 17 simulator ✅
- Runtime logs: **NO CRASHES** — app runs cleanly
  - No SceneDelegate errors
  - No BGTaskScheduler assertions
  - Network errors expected (headless Mac has no network)

**Key findings:**
- iOS 26 simulator SDK missing: distanceRunning, cardioFitnessLevel, electrocardiogram, mindfulnessSession
- HKUnit blood glucose: use `HKUnit(from: "mg/dL")` — mmol/L requires molar mass
- sortDescriptors in HKSampleQuery needs `[NSSortDescriptor]` array, not bare NSSortDescriptor
- xcodegen `sdk:` prefix creates local framework refs, not SDK refs — use project.yml from known-good commit

**Subagent timeout issue:** 30-min timeout too short for SPM builds + test cycles. Subagent timed out before completing. Need: shorter test loops or incremental builds.

**Next steps:**
- Pull latest on your Mac: `git pull`
- Rebuild on your iPhone
- Fix Firestore security rules (reads blocked)
- Verify HealthKit data syncing on physical device


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

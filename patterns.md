
---

## pat-2026-03-26-007: Xcode 26 deployment target must be set manually in UI
**First seen:** 2026-03-26, Kirt's MacBook
**Pattern:** project.yml deployment target not respected by Xcode 26 — always reverts to its own internal mapping
**Fix:** Manually set target in Xcode: KirtHealthSync → General → Target → iOS 26.3
**Status:** CONFIRMED
**Lesson:** XcodeGen project.yml deployment target is not reliably read by Xcode 26 on pull. Always verify in Xcode Build Settings after pull.

---

## pat-2026-03-26-008: iOS 26 requires Enable Development Mode on device
**First seen:** 2026-03-26
**Pattern:** Physical iPhone on iOS 26 blocks app installation until Development Mode is enabled
**Fix:** Settings → Privacy & Security → Enable Development Mode → restart device
**Status:** CONFIRMED

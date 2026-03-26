
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

## pat-2026-03-27-001: iOS 26 simulator SDK — not all types available
**First seen:** 2026-03-27
**Pattern:** distanceRunning, cardioFitnessLevel, electrocardiogram, mindfulnessSession don't exist in iOS 26 simulator SDK
**Fix:** Remove from typesToRead and corresponding sync functions. Use `distanceWalkingRunning` instead of `distanceRunning`.
**Status:** CONFIRMED
**Note:** These may exist on physical iOS 26 devices. Simulator SDK ≠ device SDK.

## pat-2026-03-27-002: Blood glucose HKUnit
**First seen:** 2026-03-27
**Pattern:** `HKUnit(dimension: .millimolePerLiter)` is invalid. mmol/L requires molar mass.
**Fix:** Use `HKUnit(from: "mg/dL")` for US units, or `HKUnit.moleUnit(with: .milli).unitDivided(by: .liter())` with proper molarMass
**Status:** CONFIRMED

## pat-2026-03-27-003: sortDescriptors must be array
**First seen:** 2026-03-27
**Pattern:** `sortDescriptors: sortDescriptor` (bare NSSortDescriptor) causes compile error. HKSampleQuery expects `[NSSortDescriptor]`
**Fix:** Wrap in array: `sortDescriptors: [sortDescriptor]`
**Status:** CONFIRMED

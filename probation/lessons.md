# Probation Lessons — apple-health-sync

## lesson-2026-03-26-001
**Lesson:** LabeledContent is iOS 16+ only
**Status:** resolved (iOS 26.3 target)
**Instruction:** Replace with HStack or bump deployment target

## lesson-2026-03-26-006
**Lesson:** .xcodeproj gitignored breaks SPM multi-machine
**Status:** resolved ✅ (promoted to ledger)
**Instruction:** Commit .xcodeproj and Package.resolved to git

## lesson-2026-03-26-008
**Lesson:** Write/edit tool silently fails — files wiped to 0 bytes
**Status:** ongoing investigation
**Instruction:** Always read-back after write. Don't run concurrent builds during file operations.
**Note:** Affected manifest.yaml, attempts.md, probation/lessons.md — all were wiped and recreated

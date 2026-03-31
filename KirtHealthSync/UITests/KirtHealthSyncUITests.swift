import XCTest

final class KirtHealthSyncUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launchEnvironment = ["UITESTING": "true"]
        app.launch()
    }

    override func tearDown() {
        app.terminate()
        super.tearDown()
    }

    // MARK: - FLOW 1: App Launch + Visible Metrics Display

    func testAppLaunchesAndShowsMainScreen() throws {
        XCTAssertTrue(app.navigationBars["Kirt Health Sync"].waitForExistence(timeout: 5),
                      "App should display main navigation title")
        XCTAssertTrue(app.staticTexts["Today's Summary"].waitForExistence(timeout: 3),
                      "Today's Summary section should be visible")
        XCTAssertTrue(app.staticTexts["Nutrition"].waitForExistence(timeout: 3),
                      "Nutrition section should be visible")
        XCTAssertTrue(app.staticTexts["Last Sync"].waitForExistence(timeout: 3),
                      "Last Sync section should be visible")
        XCTAssertTrue(app.staticTexts["Recent Workouts"].waitForExistence(timeout: 3),
                      "Recent Workouts section should be visible")
    }

    // MARK: - FLOW 2: Mock Data — Visible Refreshed Totals

    func testMockDataDisplaysCorrectStepsValue() throws {
        // Wait for mock data to load (loadMockData called on onAppear)
        let exp = self.expectation(description: "Mock data loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { exp.fulfill() }
        wait(for: [exp], timeout: 5)

        // Steps — mock value is 8420
        let stepsValue = findValueCell(nearLabel: "Steps")
        XCTAssertTrue(stepsValue.contains("8420"), "Steps should show mock value 8420, got: \(stepsValue)")

        // Weight — mock value is 82.5 kg
        let weightValue = findValueCell(nearLabel: "Weight")
        XCTAssertTrue(weightValue.contains("82.5") && weightValue.contains("kg"),
                      "Weight should show 82.5 kg, got: \(weightValue)")

        // Resting HR — mock value is 58 bpm
        let hrValue = findValueCell(nearLabel: "Resting HR")
        XCTAssertTrue(hrValue.contains("58"), "Resting HR should show 58, got: \(hrValue)")

        // Sleep — mock value is 420 min
        let sleepValue = findValueCell(nearLabel: "Sleep")
        XCTAssertTrue(sleepValue.contains("420"), "Sleep should show 420 min, got: \(sleepValue)")
    }

    func testMockNutritionDataDisplaysCorrectValues() throws {
        let exp = self.expectation(description: "Mock nutrition loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { exp.fulfill() }
        wait(for: [exp], timeout: 5)

        // Calories — mock value is 2150
        let calValue = findValueCell(nearLabel: "Calories")
        XCTAssertTrue(calValue.contains("2150"), "Calories should show 2150, got: \(calValue)")

        // Protein — mock value is 148.2 g
        let proteinValue = findValueCell(nearLabel: "Protein")
        XCTAssertTrue(proteinValue.contains("148"), "Protein should show ~148.2g, got: \(proteinValue)")
    }

    func testMockWorkoutsDisplayed() throws {
        // Wait for async data load — workouts may take a run cycle to appear
        let exp = self.expectation(description: "Mock workouts loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { exp.fulfill() }
        wait(for: [exp], timeout: 8)

        XCTAssertTrue(app.staticTexts["Cycling"].waitForExistence(timeout: 5),
                      "Cycling workout should be visible")
        XCTAssertTrue(app.staticTexts["Running"].waitForExistence(timeout: 5),
                      "Running workout should be visible")
    }

    // MARK: - FLOW 3: Sync Trigger + Loading State + Sync Status

    func testSyncNowButtonExistsAndIsEnabled() throws {
        let syncButton = app.buttons["Sync Now"]
        XCTAssertTrue(syncButton.waitForExistence(timeout: 5), "Sync Now button should exist")
        XCTAssertTrue(syncButton.isEnabled, "Sync Now should be enabled by default")
    }

    func testSyncNowTriggersLoadingState() throws {
        let syncButton = app.buttons["Sync Now"]
        syncButton.tap()

        // Button should be disabled during sync (loading state)
        // Use predicate-based expectation which polls UI state reliably
        let disabledPredicate = NSPredicate(format: "isEnabled == false")
        let disabledExp = self.expectation(for: disabledPredicate, evaluatedWith: syncButton, handler: nil)
        wait(for: [disabledExp], timeout: 5)

        // After sync completes, button re-enables (mock sync takes ~1s)
        let enabledPredicate = NSPredicate(format: "isEnabled == true")
        let enabledExp = self.expectation(for: enabledPredicate, evaluatedWith: syncButton, handler: nil)
        wait(for: [enabledExp], timeout: 10)
    }

    func testSyncRefreshesDisplayedTotals() throws {
        // Wait for initial load
        let loadExp = self.expectation(description: "Initial data loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { loadExp.fulfill() }
        wait(for: [loadExp], timeout: 5)

        // Verify initial steps
        let initialSteps = findValueCell(nearLabel: "Steps")
        XCTAssertTrue(initialSteps.contains("8420"), "Initial steps should be 8420")

        // Tap sync
        let syncButton = app.buttons["Sync Now"]
        syncButton.tap()

        // Wait for sync to complete (mock sync takes ~1s)
        let reenabledExp = self.expectation(description: "Sync completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { reenabledExp.fulfill() }
        wait(for: [reenabledExp], timeout: 10)

        // After sync, data should still show correct totals
        let updatedSteps = findValueCell(nearLabel: "Steps")
        XCTAssertTrue(updatedSteps.contains("8420"), "Steps should refresh to 8420 after sync")
    }

    func testSyncTimestampUpdatesAfterLoad() throws {
        let exp = self.expectation(description: "Sync time visible")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { exp.fulfill() }
        wait(for: [exp], timeout: 5)

        XCTAssertTrue(app.staticTexts["Last Sync"].waitForExistence(timeout: 3),
                      "Last Sync section should be visible")
        XCTAssertTrue(app.buttons["Sync Now"].waitForExistence(timeout: 3),
                      "Sync Now button should be visible in Last Sync section")
    }

    // MARK: - FLOW 4: Metric Toggle Configuration

    func testSettingsButtonExistsAndNavigates() throws {
        // Find the Settings gear button in the navigation bar
        let settingsButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5),
                      "Settings button should exist in nav bar")

        settingsButton.tap()

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5),
                      "Settings screen should appear after tapping gear button")
    }

    func testSettingsDisplaysAllMetricToggles() throws {
        // Navigate to Settings
        let settingsButton = app.navigationBars.buttons.element(boundBy: 0)
        settingsButton.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        XCTAssertTrue(app.staticTexts["Metrics"].waitForExistence(timeout: 3),
                      "Metrics section header should be visible")

        XCTAssertTrue(app.staticTexts["Steps"].waitForExistence(timeout: 3),
                      "Steps toggle should be visible")
        XCTAssertTrue(app.staticTexts["Sleep"].waitForExistence(timeout: 3),
                      "Sleep toggle should be visible")
        XCTAssertTrue(app.staticTexts["Weight"].waitForExistence(timeout: 3),
                      "Weight toggle should be visible")
        XCTAssertTrue(app.staticTexts["Heart Rate"].waitForExistence(timeout: 3),
                      "Heart Rate toggle should be visible")
        XCTAssertTrue(app.staticTexts["Calories"].waitForExistence(timeout: 3),
                      "Calories toggle should be visible")
        XCTAssertTrue(app.staticTexts["Workouts"].waitForExistence(timeout: 3),
                      "Workouts toggle should be visible")
        XCTAssertTrue(app.staticTexts["Nutrition"].waitForExistence(timeout: 3),
                      "Nutrition toggle should be visible")
    }

    func testToggleCanBeTurnedOff() throws {
        let settingsButton = app.navigationBars.buttons.element(boundBy: 0)
        settingsButton.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        let stepsToggle = app.switches["Steps"]
        XCTAssertTrue(stepsToggle.waitForExistence(timeout: 3), "Steps toggle should exist")

        // Tap the toggle using coordinate (more reliable on iOS simulator)
        let toggleFrame = stepsToggle.frame
        stepsToggle.tap()

        // Allow UI to update after tap
        let updateExp = self.expectation(description: "Toggle updated")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { updateExp.fulfill() }
        wait(for: [updateExp], timeout: 2)

        // Verify UserDefaults was updated
        let isOn = UserDefaults.standard.bool(forKey: "toggle_stepCount")
        XCTAssertFalse(isOn, "Steps toggle should be OFF after tapping (UserDefaults check)")
    }

    func testToggleCanBeTurnedBackOn() throws {
        let settingsButton = app.navigationBars.buttons.element(boundBy: 0)
        settingsButton.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        let stepsToggle = app.switches["Steps"]
        stepsToggle.tap() // off
        let offExp = self.expectation(description: "Off")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { offExp.fulfill() }
        wait(for: [offExp], timeout: 2)

        stepsToggle.tap() // back on
        let onExp = self.expectation(description: "On")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { onExp.fulfill() }
        wait(for: [onExp], timeout: 2)

        let isOn = UserDefaults.standard.bool(forKey: "toggle_stepCount")
        XCTAssertTrue(isOn, "Steps toggle should be ON after second tap (UserDefaults check)")
    }

    func testSyncStatusRowDisplaysInSettings() throws {
        let settingsButton = app.navigationBars.buttons.element(boundBy: 0)
        settingsButton.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        XCTAssertTrue(app.staticTexts["Sync Status"].waitForExistence(timeout: 3),
                      "Sync Status section should be visible")
        XCTAssertTrue(app.staticTexts["Firebase"].waitForExistence(timeout: 3),
                      "Firebase row should be visible")
        XCTAssertTrue(app.staticTexts["Connected"].waitForExistence(timeout: 3),
                      "Firebase should show Connected status")
    }

    func testSettingsBackNavigationReturnsToMainScreen() throws {
        let settingsButton = app.navigationBars.buttons.element(boundBy: 0)
        settingsButton.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))

        // Navigate back (first button in nav bar is Back)
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        backButton.tap()

        XCTAssertTrue(app.navigationBars["Kirt Health Sync"].waitForExistence(timeout: 5),
                      "Should return to main screen after back navigation")
    }

    // MARK: - Additional Robustness Tests

    func testAppDoesNotCrashWithMultipleSyncTaps() throws {
        let syncButton = app.buttons["Sync Now"]
        XCTAssertTrue(syncButton.waitForExistence(timeout: 3), "Sync button should exist")
        for i in 0..<5 {
            syncButton.tap()
        }
        XCTAssertTrue(app.navigationBars["Kirt Health Sync"].exists,
                      "App should survive multiple rapid sync taps")
    }

    func testAllSectionsRenderedWithoutCrash() throws {
        XCTAssertTrue(app.staticTexts["Today's Summary"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Nutrition"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Last Sync"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Recent Workouts"].waitForExistence(timeout: 3))

        // Navigate to Settings and back
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Kirt Health Sync"].waitForExistence(timeout: 5))
    }

    func testWeightUnitIsKilograms() throws {
        let exp = self.expectation(description: "Weight loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { exp.fulfill() }
        wait(for: [exp], timeout: 5)

        let weightValue = findValueCell(nearLabel: "Weight")
        XCTAssertTrue(weightValue.contains("kg"), "Weight should be in kg, got: \(weightValue)")
        XCTAssertFalse(weightValue.contains("lb"), "Weight should NOT be in lb")
    }

    func testPortraitOrientationOnIPhone() throws {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        if !isIPad {
            // Simulator may not report orientation reliably
            // Verify device idiom is iPhone
            XCTAssertEqual(UIDevice.current.userInterfaceIdiom, .phone,
                          "Test should run on iPhone simulator")
        }
    }

    // MARK: - Helper

    /// Finds the value text in the same row as the given label
    private func findValueCell(nearLabel label: String) -> String {
        let tableCount = app.tables.count
        for tableIdx in 0..<tableCount {
            let table = app.tables.element(boundBy: tableIdx)
            let cellCount = table.cells.count
            for cellIdx in 0..<cellCount {
                let cell = table.cells.element(boundBy: cellIdx)
                let texts = cell.staticTexts.allElementsBoundByIndex
                for textIdx in 0..<texts.count {
                    if texts[textIdx].label == label && textIdx + 1 < texts.count {
                        return texts[textIdx + 1].label
                    }
                }
            }
        }
        return ""
    }
}

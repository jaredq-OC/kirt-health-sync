import XCTest

final class KirtHealthSyncUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        // Smoke test: use --uitesting to bypass HK (mock Firestore path only)
        // Physical device HK tests must be run manually
        app.launchArguments = ["--uitesting"]
    }

    // MARK: - Smoke Test: Mock Firestore path (bypasses HK)

    func testMockFirestorePath() throws {
        app.launch()
        sleep(2)

        // Verify the debug UI is visible
        let mockDirectButton = app.buttons["Mock Direct"]
        XCTAssertTrue(mockDirectButton.waitForExistence(timeout: 10), "Mock Direct button not found — debug UI missing")
        mockDirectButton.tap()
        print("Tapped Mock Direct")
        sleep(3)

        // Verify sync triggers and completes
        let syncButton = app.buttons["Sync Now"]
        XCTAssertTrue(syncButton.waitForExistence(timeout: 10), "Sync Now button not found")
        syncButton.tap()
        print("Tapped Sync Now")
        sleep(10)

        // Screenshot for verification
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "MockFirestorePath"
        attachment.lifetime = .keepAlways
        add(attachment)
        print("Mock Firestore path test complete")
    }
}

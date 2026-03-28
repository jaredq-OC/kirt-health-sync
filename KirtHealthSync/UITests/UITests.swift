import XCTest

final class KirtHealthSyncUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
    }

    func testDismissHealthKitPermissionAndSync() throws {
        // Launch the app
        app.launch()

        // Wait for the HealthKit authorization alert
        sleep(2)

        // Try to find and tap the "Allow" button in the HealthKit dialog
        let allowButton = XCUIApplication().buttons["Allow"]
        if allowButton.waitForExistence(timeout: 5) {
            allowButton.tap()
            print("Tapped Allow on HealthKit dialog")
        } else {
            let okButton = XCUIApplication().buttons["OK"]
            if okButton.waitForExistence(timeout: 2) {
                okButton.tap()
                print("Tapped OK on dialog")
            } else {
                let alert = XCUIApplication().alerts.firstMatch
                if alert.waitForExistence(timeout: 3) {
                    let dontAllow = alert.buttons["Don't Allow"]
                    let allow = alert.buttons["Allow"]
                    if allow.exists {
                        allow.tap()
                        print("Tapped Allow via alert element")
                    } else if !dontAllow.exists {
                        alert.buttons.firstMatch.tap()
                        print("Tapped first alert button")
                    }
                } else {
                    print("HealthKit dialog did not appear or already dismissed")
                }
            }
        }

        // Wait for the app to settle after authorization
        sleep(3)

        // Find and tap the Sync Now button
        let syncButton = XCUIApplication().buttons["Sync Now"]
        if syncButton.waitForExistence(timeout: 5) {
            let coord = syncButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            coord.tap()
            print("Tapped Sync Now button at center coordinate")
            sleep(10) // Wait longer for Firebase write to complete
        } else {
            print("Sync Now button not found")
        }

        // Take a screenshot for verification
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "HealthSyncUITest-Final"
        attachment.lifetime = .keepAlways
        add(attachment)

        // Wait for sync to complete
        sleep(5)
        print("UITest complete — Firebase check should show data")
    }
}

import UIKit
import Firebase
import HealthKit

class AppDelegate: NSObject, UIApplicationDelegate {

    /// Set to true during UITests — signals to other components to skip Firebase/HealthKit.
    /// Initialized BEFORE didFinishLaunching so it's safe for use in static/class initializers.
    static var isUITesting: Bool = {
        // Check at class initialization time (before didFinishLaunching)
        return ProcessInfo.processInfo.environment["XCTest"] != nil ||
               ProcessInfo.processInfo.environment["UITESTING"] == "true" ||
               ProcessInfo.processInfo.arguments.contains("--uitesting")
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        if AppDelegate.isUITesting {
            print("[UITesting] Test mode — skipping Firebase and HealthKit initialization")
            return true
        }

        // Normal mode — initialize Firebase
        FirebaseApp.configure()

        // Request HealthKit authorization
        HealthKitManager.shared.requestAuthorization { success, error in
            if success {
                print("HealthKit authorization granted")
                HealthKitManager.shared.startBackgroundSync()
            } else if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }

        return true
    }
}

import UIKit
import Firebase
import HealthKit

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // Initialize Firebase
        FirebaseApp.configure()

        // Request HealthKit authorization
        HealthKitManager.shared.requestAuthorization { success, error in
            if success {
                print("[AppDelegate] HealthKit authorization granted")
                // Write mock data first so there's data to sync
                print("[AppDelegate] Writing mock HealthKit data...")
                HealthKitManager.shared.writeDebugMockData { mockSuccess, mockError in
                    print("[AppDelegate] Mock data write: \(mockSuccess), error: \(mockError?.localizedDescription ?? "none")")
                    print("[AppDelegate] Starting background sync...")
                    HealthKitManager.shared.startBackgroundSync()
                }
            } else if let error = error {
                print("[AppDelegate] HealthKit authorization failed: \(error.localizedDescription)")
            }
        }

        return true
    }
}

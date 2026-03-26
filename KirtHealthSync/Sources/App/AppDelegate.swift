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
                print("HealthKit authorization granted")
                // Start background sync once authorized
                HealthKitManager.shared.startBackgroundSync()
            } else if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }

        return true
    }
}

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
                // Write mock data first, THEN sync
                print("[AppDelegate] Writing mock HealthKit data...")
                HealthKitManager.shared.writeDebugMockData { mockSuccess, mockError in
                    if mockSuccess {
                        print("[AppDelegate] Mock data written successfully")
                    } else {
                        print("[AppDelegate] Mock data failed: \(mockError?.localizedDescription ?? "unknown")")
                    }
                    // Give HK a moment to index the saved samples
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        // Debug: query what HK actually has
                        print("[AppDelegate] Debug querying HK...")
                        HealthKitManager.shared.debugQueryAllData { results in
                            print("[AppDelegate] HK Debug results: \(results)")
                            // Check if we got any data
                            let hasData = results.values.contains { ($0 as? [String: Any])?["count"] as? Int ?? 0 > 0 }
                            print("[AppDelegate] HK has data: \(hasData)")
                            // Now start the real sync
                            print("[AppDelegate] Starting sync...")
                            HealthKitManager.shared.startBackgroundSync()
                        }
                    }
                }
            } else if let error = error {
                print("[AppDelegate] HealthKit authorization failed: \(error.localizedDescription)")
            }
        }

        return true
    }
}

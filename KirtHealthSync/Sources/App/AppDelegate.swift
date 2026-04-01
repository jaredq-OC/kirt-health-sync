import UIKit
import Firebase
import HealthKit

class AppDelegate: NSObject, UIApplicationDelegate {

    private var syncGroup = DispatchGroup()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // Initialize Firebase
        FirebaseApp.configure()

        // Request HealthKit authorization (skip in UITest mode — UI handles it)
        if !CommandLine.arguments.contains("--uitesting") {
            HealthKitManager.shared.requestAuthorization { success, error in
                if success {
                    print("[AppDelegate] HealthKit authorization granted")
                    // Start background sync + one-shot sync of real HK data
                    // Mock data is ONLY for the debug UI, not automatic writes
                    HealthKitManager.shared.startBackgroundSync()
                } else if let error = error {
                    print("[AppDelegate] HealthKit authorization failed: \(error.localizedDescription)")
                }
            }

            // Keep app alive until sync completes
            DispatchQueue.global().async {
                self.syncGroup.wait()
                print("[AppDelegate] Sync group complete — app can exit")
            }
        }

        return true
    }
}

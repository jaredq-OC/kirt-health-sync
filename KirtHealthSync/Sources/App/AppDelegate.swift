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
                    // Sync real health data — do NOT write mock data here
                    // Mock data is only written via the debug UI (MockDataInputView)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        print("[AppDelegate] Starting sync with completion wait...")
                        self.syncGroup.enter()
                        HealthKitManager.shared.syncHealthData { syncSuccess in
                            print("[AppDelegate] Sync completed: \(syncSuccess)")
                            self.syncGroup.leave()
                        }
                    }
                } else if let error = error {
                    print("[AppDelegate] HealthKit authorization failed: \(error.localizedDescription)")
                }
            }

            // Keep app alive until sync completes (for background sync)
            DispatchQueue.global().async {
                self.syncGroup.wait()
                print("[AppDelegate] Sync group complete — app can exit")
            }
        }

        return true
    }
}

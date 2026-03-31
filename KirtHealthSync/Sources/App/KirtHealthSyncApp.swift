import SwiftUI
import Firebase
import HealthKit

@main
struct KirtHealthSyncApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        // Install safety net for Firebase ObjC exceptions as early as possible
        KirtHealthSyncApp.installFirebaseSafetyNet()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    /// Installs an ObjC exception handler to prevent Firebase SDK crashes
    /// from terminating the app when the Firebase project is suspended.
    private static func installFirebaseSafetyNet() {
        NSSetUncaughtExceptionHandler { exception in
            let name = exception.name.rawValue
            if name.contains("FIRFirestore") || name.contains("FIRInvalidArgument") {
                print("[SAFETY NET] Caught Firebase exception: \(name) — continuing")
                return
            }
        }
    }
}

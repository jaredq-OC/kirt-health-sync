import SwiftUI

struct SettingsView: View {
    @State private var toggleSteps: Bool = true
    @State private var toggleSleep: Bool = true
    @State private var toggleWeight: Bool = true
    @State private var toggleHeartRate: Bool = true
    @State private var toggleCalories: Bool = true
    @State private var toggleWorkouts: Bool = true
    @State private var toggleNutrition: Bool = true

    var body: some View {
        List {
            Section(header: Text("Metrics")) {
                Toggle("Steps", isOn: $toggleSteps)
                    .onChange(of: toggleSteps) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "toggle_stepCount")
                    }
                Toggle("Sleep", isOn: $toggleSleep)
                    .onChange(of: toggleSleep) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "toggle_sleep")
                    }
                Toggle("Weight", isOn: $toggleWeight)
                    .onChange(of: toggleWeight) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "toggle_weight")
                    }
                Toggle("Heart Rate", isOn: $toggleHeartRate)
                    .onChange(of: toggleHeartRate) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "toggle_heartRate")
                    }
                Toggle("Calories", isOn: $toggleCalories)
                    .onChange(of: toggleCalories) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "toggle_calories")
                    }
                Toggle("Workouts", isOn: $toggleWorkouts)
                    .onChange(of: toggleWorkouts) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "toggle_workouts")
                    }
                Toggle("Nutrition", isOn: $toggleNutrition)
                    .onChange(of: toggleNutrition) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "toggle_nutrition")
                    }
            }

            Section(header: Text("Sync Status")) {
                HStack {
                    Text("Firebase")
                    Spacer()
                    Text("Connected")
                        .foregroundColor(.green)
                        .font(.caption)
                }
                HStack {
                    Text("Last Sync")
                    Spacer()
                    Text(lastSyncTimeString)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            loadToggleStates()
        }
    }

    private var lastSyncTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        if let timestamp = UserDefaults.standard.object(forKey: "HKManager_LastSyncTime") as? Date {
            return formatter.string(from: timestamp)
        }
        return "Never"
    }

    private func loadToggleStates() {
        if UserDefaults.standard.object(forKey: "toggle_stepCount") != nil {
            toggleSteps = UserDefaults.standard.bool(forKey: "toggle_stepCount")
        }
        if UserDefaults.standard.object(forKey: "toggle_sleep") != nil {
            toggleSleep = UserDefaults.standard.bool(forKey: "toggle_sleep")
        }
        if UserDefaults.standard.object(forKey: "toggle_weight") != nil {
            toggleWeight = UserDefaults.standard.bool(forKey: "toggle_weight")
        }
        if UserDefaults.standard.object(forKey: "toggle_heartRate") != nil {
            toggleHeartRate = UserDefaults.standard.bool(forKey: "toggle_heartRate")
        }
        if UserDefaults.standard.object(forKey: "toggle_calories") != nil {
            toggleCalories = UserDefaults.standard.bool(forKey: "toggle_calories")
        }
        if UserDefaults.standard.object(forKey: "toggle_workouts") != nil {
            toggleWorkouts = UserDefaults.standard.bool(forKey: "toggle_workouts")
        }
        if UserDefaults.standard.object(forKey: "toggle_nutrition") != nil {
            toggleNutrition = UserDefaults.standard.bool(forKey: "toggle_nutrition")
        }
    }
}

import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject private var viewModel = HealthDataViewModel()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Today's Summary")) {
                    LabeledContent("Steps", value: "\(viewModel.todaySteps)")
                    LabeledContent("Sleep", value: "\(viewModel.todaySleepMinutes) min")
                    LabeledContent("Weight", value: String(format: "%.1f lb", viewModel.latestWeight))
                    LabeledContent("Resting HR", value: "\(viewModel.latestRestingHR) bpm")
                }

                Section(header: Text("Last Sync")) {
                    Text(viewModel.lastSyncTime)
                        .foregroundColor(.secondary)
                    Button("Sync Now") {
                        viewModel.syncNow()
                    }
                }

                Section(header: Text("Recent Workouts")) {
                    if viewModel.recentWorkouts.isEmpty {
                        Text("No workouts logged")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.recentWorkouts.prefix(5), id: \.self) { workout in
                            VStack(alignment: .leading) {
                                Text(workout.activityType)
                                    .font(.headline)
                                Text("\(Int(workout.duration)) min • \(Int(workout.energyBurned)) kcal")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Kirt Health Sync")
            .onAppear {
                viewModel.loadData()
            }
        }
    }
}

@MainActor
class HealthDataViewModel: ObservableObject {
    @Published var todaySteps: Int = 0
    @Published var todaySleepMinutes: Int = 0
    @Published var latestWeight: Double = 0
    @Published var latestRestingHR: Int = 0
    @Published var lastSyncTime: String = "Never"
    @Published var recentWorkouts: [WorkoutItem] = []
    @Published var isLoading: Bool = false

    func loadData() {
        // Load from Firestore
        let db = Firestore.firestore()

        // Get today's steps
        let today = Calendar.current.startOfDay(for: Date())
        db.collection("healthData")
            .whereField("timestamp", isGreaterThan: Timestamp(date: today))
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    for doc in docs {
                        let data = doc.data()
                        if let value = data["value"] as? Int, doc.documentID.hasPrefix("steps") {
                            DispatchQueue.main.async {
                                self.todaySteps = value
                            }
                        }
                    }
                }
            }

        // Update last sync time
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        DispatchQueue.main.async {
            self.lastSyncTime = formatter.string(from: Date())
        }
    }

    func syncNow() {
        isLoading = true
        HealthKitManager.shared.syncHealthData { success in
            DispatchQueue.main.async {
                self.isLoading = false
                self.loadData()
            }
        }
    }
}

struct WorkoutItem: Identifiable {
    let id = UUID()
    let activityType: String
    let duration: TimeInterval
    let energyBurned: Double
}

// Extension to make HKWorkout conform to Identifiable for SwiftUI
extension HKWorkout {
    var workoutItem: WorkoutItem {
        WorkoutItem(
            activityType: self.workoutActivityType.name,
            duration: self.duration,
            energyBurned: self.energyBurned?.doubleValue(for: .kilocalorie()) ?? 0
        )
    }
}

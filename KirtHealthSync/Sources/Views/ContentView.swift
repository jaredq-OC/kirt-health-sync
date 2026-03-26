import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @StateObject private var viewModel = HealthDataViewModel()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Today's Summary")) {
                    HStack { Text("Steps"); Spacer(); Text("\(viewModel.todaySteps)").foregroundColor(.secondary) }
                    HStack { Text("Sleep"); Spacer(); Text("\(viewModel.todaySleepMinutes) min").foregroundColor(.secondary) }
                    HStack { Text("Weight"); Spacer(); Text(String(format: "%.1f lb", viewModel.latestWeight)).foregroundColor(.secondary) }
                    HStack { Text("Resting HR"); Spacer(); Text("\(viewModel.latestRestingHR) bpm").foregroundColor(.secondary) }
                }

                Section(header: Text("Nutrition")) {
                    HStack { Text("Calories"); Spacer(); Text(String(format: "%.0f kcal", viewModel.nutritionData.calories)).foregroundColor(.secondary) }
                    HStack { Text("Protein"); Spacer(); Text(String(format: "%.1f g", viewModel.nutritionData.protein)).foregroundColor(.secondary) }
                    HStack { Text("Carbs"); Spacer(); Text(String(format: "%.1f g", viewModel.nutritionData.carbs)).foregroundColor(.secondary) }
                    HStack { Text("Fat"); Spacer(); Text(String(format: "%.1f g", viewModel.nutritionData.fat)).foregroundColor(.secondary) }
                }

                Section(header: Text("Last Sync")) {
                    Text(viewModel.lastSyncTime)
                        .foregroundColor(.secondary)
                    Button("Sync Now") {
                        viewModel.syncNow()
                    }
                    .disabled(viewModel.isLoading)
                }

                Section(header: Text("Recent Workouts")) {
                    if viewModel.recentWorkouts.isEmpty {
                        Text("No workouts logged")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.recentWorkouts) { workout in
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
    @Published var nutritionData: NutritionData = NutritionData()
    @Published var isLoading: Bool = false

    private let db = Firestore.firestore()

    func loadData() {
        let today = Calendar.current.startOfDay(for: Date())
        let todayTimestamp = Timestamp(date: today)

        db.collection("healthData")
            .whereField("timestamp", isGreaterThan: todayTimestamp)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let docs = snapshot?.documents {
                    for doc in docs {
                        let data = doc.data()
                        let docId = doc.documentID

                        if docId.hasPrefix("steps"), let value = data["value"] as? Int {
                            Task { @MainActor in self.todaySteps = value }
                        } else if docId.hasPrefix("sleep"), let total = data["totalMinutes"] as? Double {
                            Task { @MainActor in self.todaySleepMinutes = Int(total) }
                        } else if docId.hasPrefix("weight"), let value = data["value"] as? Double {
                            Task { @MainActor in self.latestWeight = value }
                        } else if docId.hasPrefix("restingHR"), let value = data["value"] as? Double {
                            Task { @MainActor in self.latestRestingHR = Int(value) }
                        } else if docId.hasPrefix("nutrition"), let nutrients = data["nutrients"] as? [String: Any] {
                            Task { @MainActor in
                                self.nutritionData = NutritionData(
                                    calories: nutrients["dietaryEnergyConsumed"] as? Double ?? 0,
                                    protein: nutrients["dietaryProtein"] as? Double ?? 0,
                                    carbs: nutrients["dietaryCarbohydrates"] as? Double ?? 0,
                                    fat: nutrients["dietaryFatTotal"] as? Double ?? 0
                                )
                            }
                        } else if docId.hasPrefix("workout") {
                            if let activity = data["activityType"] as? String,
                               let duration = data["duration"] as? Double,
                               let energy = data["energyBurned"] as? Double {
                                let workout = WorkoutItem(
                                    activityType: activity,
                                    duration: duration,
                                    energyBurned: energy
                                )
                                Task { @MainActor in
                                    if !self.recentWorkouts.contains(where: { $0.id == workout.id }) {
                                        self.recentWorkouts.append(workout)
                                    }
                                }
                            }
                        }
                    }
                }

                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                Task { @MainActor in self.lastSyncTime = formatter.string(from: Date()) }
            }
    }

    func syncNow() {
        isLoading = true
        HealthKitManager.shared.syncHealthData { [weak self] _ in
            Task { @MainActor in
                self?.isLoading = false
                self?.recentWorkouts.removeAll()
                self?.loadData()
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

struct NutritionData {
    var calories: Double = 0
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
}

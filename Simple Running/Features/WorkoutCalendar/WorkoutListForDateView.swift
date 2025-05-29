import SwiftUI

struct WorkoutListForDateView: View {
    @EnvironmentObject var store: WorkoutStore
    @Binding var date: Date
    
    private var workoutsOnDate: [Workout] {
        store.workouts(for: date)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Treinos para \(date, style: .date)")
                .font(.headline)
                .padding(.horizontal)
            
            if store.isLoading && workoutsOnDate.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if workoutsOnDate.isEmpty {
                Text("Nenhum treino agendado para este dia.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                List {
                    ForEach(workoutsOnDate) { workout in
                        WorkoutRow(workout: workout)
                    }
                    .onDelete(perform: deleteWorkout)
                }
                .listStyle(.plain)
            }
        }
    }
    
    private func deleteWorkout(at offsets: IndexSet) {
        let workoutsToDelete = offsets.map { workoutsOnDate[$0] }
        Task {
            for workout in workoutsToDelete {
                await store.deleteWorkout(workout)
                if store.errorMessage != nil {
                    break
                }
            }
        }
    }
}


struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            Image(systemName: workout.type.iconName)
                .foregroundColor(.accentColor)
                .font(.title3)
            VStack(alignment: .leading) {
                Text(workout.type.rawValue)
                    .font(.headline)
                Text(workout.description)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                if let duration = workout.durationMinutes {
                    Text("\(duration) min")
                        .font(.caption2)
                }
                if let distance = workout.distanceKm {
                    Text(String(format: "%.1f km", distance))
                        .font(.caption2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct WorkoutListForDateView_Previews: PreviewProvider {
    static var previews: some View {
        let previewStore = WorkoutStore()
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        previewStore.workouts = [
            Workout(date: today, description: "Preview Run Today", type: .easyRun, durationMinutes: 30),
            Workout(date: today, description: "Preview Intervals Today", type: .intervalTraining, durationMinutes: 45),
            Workout(date: tomorrow, description: "Preview Long Run Tomorrow", type: .longRun, distanceKm: 10)
        ]
        
        return Group {
            WorkoutListForDateView(date: .constant(today))
                .environmentObject(previewStore)
                .previewDisplayName("Workouts for Today")
            
            WorkoutListForDateView(date: .constant(Calendar.current.date(byAdding: .day, value: 2, to: today)!))
                .environmentObject(previewStore)
                .previewDisplayName("No Workouts")
        }
        .frame(height: 250)
    }
}

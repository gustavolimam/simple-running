import SwiftUI

struct TodayView: View {
    @ObservedObject var store: WorkoutStore
    @State private var showingAddWorkoutSheet = false
    
    var body: some View {
        NavigationView {
            Group {
                if store.isLoading && store.workouts.isEmpty {
                    ProgressView("Carregando treinos...")
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            if let todayWorkout = store.workoutForToday() {
                                WorkoutDetailCard(workout: todayWorkout)
                            } else {
                                NoWorkoutView()
                            }
                            UpcomingWorkoutsView(workouts: store.workouts)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Treino de Hoje")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if store.isLoading {
                        ProgressView()
                    } else {
                        Button {
                            Task {
                                await store.fetchWorkouts()
                            }
                        } label: {
                            Label("Recarregar", systemImage: "arrow.clockwise")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddWorkoutSheet) {
                AddWorkoutView()
            }
            .alert("Erro", isPresented: .constant(store.errorMessage != nil), actions: {
                Button("OK", role: .cancel) { store.errorMessage = nil }
            }, message: {
                Text(store.errorMessage ?? "Ocorreu um erro desconhecido.")
            })
        }
        .navigationViewStyle(.stack)
    }
}

struct UpcomingWorkoutsView: View {
    var workouts: [Workout]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Próximos Treinos")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 5)
            
            let upcoming = workouts
                .filter { $0.date > Date() && !Calendar.current.isDateInToday($0.date) }
                .sorted { $0.date < $1.date }
                .prefix(3)
            
            if upcoming.isEmpty {
                Text("Nenhum treino agendado para os próximos dias.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array(upcoming)) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        MinimalWorkoutRow(workout: workout)
                    }
                    if workout.id != upcoming.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

struct WorkoutDetailCard: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: workout.type.iconName)
                    .font(.title)
                    .foregroundColor(.accentColor)
                Text(workout.type.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Text(workout.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let duration = workout.durationMinutes {
                Text("Duração: \(duration) minutos")
                    .font(.callout)
            }
            if let distance = workout.distanceKm {
                Text("Distância: \(String(format: "%.1f", distance)) km")
                    .font(.callout)
            }

            Text("Descrição:")
                .font(.headline)
            Text(workout.description)
                .font(.body)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

struct NoWorkoutView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("Nenhum treino para hoje!")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Aproveite para descansar ou adicione um novo treino.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

struct MinimalWorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading) {
                Text(workout.type.rawValue)
                    .font(.headline)
                Text(workout.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct WorkoutDetailView: View {
    let workout: Workout
    
    var body: some View {
        ScrollView {
            WorkoutDetailCard(workout: workout)
                .padding()
        }
        .navigationTitle("Detalhes do Treino")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//Mark: Previews
struct UpcomingWorkoutsView_Previews: PreviewProvider {
    static let workoutsMocked: [Workout] = [
        Workout(
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            description: "Treino leve de recuperação.",
            type: .easyRun,
            durationMinutes: 40,
            distanceKm: 8.0
        ),
        Workout(
            date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            description: "Treino intervalado moderado.",
            type: .intervalTraining,
            durationMinutes: 50,
            distanceKm: 10.0
        ),
        Workout(
            date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            description: "Treino longo para resistência.",
            type: .longRun,
            durationMinutes: 90,
            distanceKm: 18.0
        )
    ]
    
    static var previews: some View {
        UpcomingWorkoutsView(workouts: workoutsMocked)
            .previewDisplayName("UpcomingWorkoutsView")
    }
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static let workoutMocked: Workout =
    Workout(
        date: Calendar.current.date(byAdding: .day, value: 0, to: Date())!,
        description: "Treino intervalado intenso.",
        type: .easyRun,
        durationMinutes: 50,
        distanceKm: 12.0
    )
    
    static var previews: some View {
        WorkoutDetailView(workout: workoutMocked)
            .previewDisplayName("WorkoutDetailView")
    }
}

struct WorkoutDetailCard_Previews: PreviewProvider {
    static let workoutMocked: Workout =
    Workout(
        date: Calendar.current.date(byAdding: .day, value: 0, to: Date())!,
        description: "Treino intervalado intenso.",
        type: .easyRun,
        durationMinutes: 50,
        distanceKm: 12.0
    )
    
    static var previews: some View {
        WorkoutDetailCard(workout: workoutMocked)            
            .previewDisplayName("WorkoutDetailCard")
    }
}

struct MinimalWorkoutRow_Previews: PreviewProvider {
    static let workoutMocked: Workout =
    Workout(
        date: Calendar.current.date(byAdding: .day, value: 0, to: Date())!,
        description: "Treino intervalado intenso.",
        type: .easyRun,
        durationMinutes: 50,
        distanceKm: 12.0
    )
    
    static var previews: some View {
        MinimalWorkoutRow(workout: workoutMocked)
            .previewDisplayName("MinimalWorkoutRow")
    }
}

struct NoWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        NoWorkoutView()
            .previewDisplayName("NoWorkoutView")
    }
}

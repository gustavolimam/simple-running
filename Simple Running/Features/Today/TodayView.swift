import SwiftUI

struct TodayView: View {
    @EnvironmentObject var store: WorkoutStore
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
                            upcomingWorkoutsSection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Treino de Hoje")
            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        showingAddWorkoutSheet = true
//                    } label: {
//                        Label("Adicionar Treino", systemImage: "plus.circle.fill")
//                    }
//                }
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
            .onAppear {
                // Data is fetched by WorkoutStore's init.
                // If you want to refresh every time the view appears:
                // Task {
                //    await store.fetchWorkouts()
                // }
            }
            .alert("Erro", isPresented: .constant(store.errorMessage != nil), actions: {
                Button("OK", role: .cancel) { store.errorMessage = nil }
            }, message: {
                Text(store.errorMessage ?? "Ocorreu um erro desconhecido.")
            })
        }
        .navigationViewStyle(.stack)
    }

    private var upcomingWorkoutsSection: some View {
        VStack(alignment: .leading) {
            Text("Próximos Treinos")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 5)

            let upcoming = store.workouts
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
    }
}

struct WorkoutDetailCard: View {
    let workout: Workout

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: workout.type.iconName)
                        .font(.title)
                        .foregroundColor(.accentColor)
                    Text(workout.type.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(8)
                
                Text(workout.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                
                if let duration = workout.durationMinutes {
                    Text("Duração: \(duration) minutos")
                        .font(.callout)
                        .padding(.horizontal, 8)
                }
                if let distance = workout.distanceKm {
                    Text("Distância: \(String(format: "%.1f", distance)) km")
                        .font(.callout)
                        .padding(.horizontal,8)
                }
                
                Text("Descrição:")
                    .font(.headline)
                    .padding(.top, 5)
                    .padding(.horizontal, 8)
                Text(workout.description)
                    .font(.body)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(radius: 3)
        }
        .padding(.vertical, 8)
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
        HStack {
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


#Preview {
    let previewStores = WorkoutStore()
     let mockWorkout = Workout(date: Date(), description: "Corrida leve de aquecimento.", type: .easyRun, durationMinutes: 30)
    previewStores.workouts = [mockWorkout]
    
    return TodayView()
        .environmentObject(previewStores)
}

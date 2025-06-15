import SwiftUI
import Supabase

@MainActor
class WorkoutStore: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let supabase = SupabaseClientManager.shared.client
    private let tableName = "workouts"
    
    init() {
        print("WorkoutStore initializing. Fetching workouts...")
        Task {
            await fetchWorkouts()
        }
    }
    
    // MARK: - Supabase CRUD Operations
    
    func fetchWorkouts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let fetchedWorkouts: [Workout] = try await supabase
                .from(tableName)
                .select()
                .order("date", ascending: false)
                .execute()
                .value
            
            self.workouts = fetchedWorkouts
            print("Successfully fetched \(fetchedWorkouts.count) workouts.")
        } catch {
            let errorDescription = "Falha ao carregar treinos: \(error.localizedDescription)"
            print("🚨 \(errorDescription)")
            print("\(error)")
            self.errorMessage = errorDescription
            self.workouts = []
        }
    }
    
    func addWorkout(_ workoutData: Workout) async {
        isLoading = true
        errorMessage = nil
        
        let workoutToAdd = workoutData
        do {
            let newWorkout: Workout = try await supabase
                .from(tableName)
                .insert(workoutToAdd, returning: .representation)
                .single()
                .execute()
                .value
            
            workouts.insert(newWorkout, at: 0)
            workouts.sort { $0.date > $1.date }
            print("Successfully added workout: \(newWorkout.id)")
            isLoading = false
        } catch {
            let errorDescription = "Falha ao salvar treino: \(error.localizedDescription)"
            print("🚨 \(errorDescription)")
            errorMessage = errorDescription
            isLoading = false
        }
    }
    
    func updateWorkout(_ workout: Workout) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedWorkout: Workout = try await supabase
                .from(tableName)
                .update(workout, returning: .representation)
                .eq("id", value: workout.id.uuidString)
                .single()
                .execute()
                .value
            
            if let index = workouts.firstIndex(where: { $0.id == updatedWorkout.id }) {
                workouts[index] = updatedWorkout
                workouts.sort { $0.date > $1.date }
            }
            print("Successfully updated workout: \(updatedWorkout.id)")
            isLoading = false
        } catch {
            let errorDescription = "Falha ao atualizar treino: \(error.localizedDescription)"
            print("🚨 \(errorDescription)")
            errorMessage = errorDescription
            isLoading = false
        }
    }
    
    func deleteWorkout(_ workout: Workout) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase
                .from(tableName)
                .delete()
                .eq("id", value: workout.id.uuidString)
                .execute()
            
            workouts.removeAll { $0.id == workout.id }
            print("Successfully deleted workout: \(workout.id)")
            isLoading = false
        } catch {
            let errorDescription = "Falha ao deletar treino: \(error.localizedDescription)"
            print("🚨 \(errorDescription)")
            errorMessage = errorDescription
            isLoading = false
        }
    }
    
    func deleteWorkouts(at offsets: IndexSet) async {
        let workoutsToDelete = offsets.map { workouts[$0] }
        
        for workout in workoutsToDelete {
            await deleteWorkout(workout)
            if errorMessage != nil {
                print("Error during batch delete, stopping further deletions.")
                break
            }
        }
    }
    
    // MARK: - Helper Methods (Client-Side Filtering)
    
    func workouts(for date: Date) -> [Workout] {
        let calendar = Calendar.current
        return workouts.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func workoutForToday() -> Workout? {
        let today = Date()
        return workouts.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    func hasWorkout(on date: Date) -> Bool {
        !workouts(for: date).isEmpty
    }
}

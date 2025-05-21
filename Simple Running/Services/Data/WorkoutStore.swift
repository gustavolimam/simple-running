import SwiftUI

@MainActor
class WorkoutStore: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
        
    private let tableName = "workouts"
    
    init() {
        Task {
           try await SupabaseClientManager.shared.fetchData()
        }
    }
    
    // MARK: - Supabase CRUD Operations
    
//    func fetchWorkouts() async {
//        isLoading = true
//        errorMessage = nil
//        defer { isLoading = false }
//        
//        do {
//            let response = try await supabase
//                .from(tableName)
//                .select()
//                .limit(10)
////                .order("date", ascending: false)
//                .execute()
//            print("JSON bruto:", response.value)
//            let data = response.data
//            print("JSON bruto:", data)
//            if data.isEmpty {
//                print("Nenhum dado retornado do Supabase.")
//                self.workouts = []
//                return
//            }
//            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = .iso8601 // ajuste se necessário
//            let fetchedWorkouts = try decoder.decode([Workout].self, from: data)
//            print("Workouts decodificados:", fetchedWorkouts)
//            self.workouts = fetchedWorkouts
//        } catch {
//            print("🚨 Erro ao buscar treinos: \(error.localizedDescription)")
//            errorMessage = "Falha ao carregar treinos: \(error.localizedDescription)"
//        }
//    }
//    
//    func addWorkout(_ workoutData: Workout) async {
//        isLoading = true
//        errorMessage = nil
//        // defer { isLoading = false } // Pode ser interessante manter o loading até a UI atualizar
//        
//        // Para associar ao usuário logado (se houver autenticação):
//        // var workoutToAdd = workoutData
//        // if let currentUserId = supabase.auth.currentUser?.id {
//        //     workoutToAdd.userId = currentUserId
//        // } else if workoutToAdd.userId == nil {
//        //     // Lidar com caso de usuário não logado se user_id for mandatório na sua lógica
//        //     print("⚠️ Usuário não logado. O treino não será associado a um usuário específico.")
//        // }
//        
//        
//        do {
//            // O Supabase pode retornar o registro inserido.
//            // A struct Workout já é Codable.
//            let newWorkout: Workout = try await supabase
//                .from(tableName)
//                .insert(workoutData, returning: .representation) // Use .representation para obter o objeto de volta
//                .single() // Espera um único resultado
//                .execute()
//                .value
//            
//            workouts.insert(newWorkout, at: 0) // Adiciona no início se ordenado por data desc.
//            workouts.sort { $0.date > $1.date } // Garante a ordenação
//            isLoading = false
//        } catch {
//            print("🚨 Erro ao adicionar treino: \(error.localizedDescription)")
//            errorMessage = "Falha ao salvar treino: \(error.localizedDescription)"
//            isLoading = false
//        }
//    }
//    
//    func updateWorkout(_ workout: Workout) async {
//        isLoading = true
//        errorMessage = nil
//        // defer { isLoading = false }
//        
//        do {
//            try await supabase
//                .from(tableName)
//                .update(workout) // A struct Workout é Encodable
//                .eq("id", value: workout.id.uuidString) // Condição para qual registro atualizar
//                .execute()
//            
//            if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
//                workouts[index] = workout
//                workouts.sort { $0.date > $1.date }
//            }
//            isLoading = false
//        } catch {
//            print("🚨 Erro ao atualizar treino: \(error.localizedDescription)")
//            errorMessage = "Falha ao atualizar treino: \(error.localizedDescription)"
//            isLoading = false
//        }
//    }
//    
//    // Delete por Workout (objeto)
//    func deleteWorkout(_ workout: Workout) async {
//        isLoading = true
//        errorMessage = nil
//        // defer { isLoading = false }
//        
//        do {
//            try await supabase
//                .from(tableName)
//                .delete()
//                .eq("id", value: workout.id.uuidString)
//                .execute()
//            
//            workouts.removeAll { $0.id == workout.id }
//            isLoading = false
//        } catch {
//            print("🚨 Erro ao deletar treino: \(error.localizedDescription)")
//            errorMessage = "Falha ao deletar treino: \(error.localizedDescription)"
//            isLoading = false
//        }
//    }
//    
//    // Delete por IndexSet (usado por List.onDelete)
//    func deleteWorkouts(at offsets: IndexSet) async {
//        let workoutsToDelete = offsets.map { workouts[$0] }
//        for workout in workoutsToDelete {
//            await deleteWorkout(workout) // Chama a função async para cada um
//            if errorMessage != nil { // Se um erro ocorrer, pare
//                break
//            }
//        }
//    }
//    
//    // MARK: - Helpers (alguns podem precisar de ajuste ou se tornar async)
//    // Estes métodos agora apenas operam sobre a cópia local `workouts`.
//    // Para consistência, eles devem sempre refletir o estado do servidor,
//    // que é atualizado por fetchWorkouts() ou após operações de escrita.
//    
//    func workouts(for date: Date) -> [Workout] {
//        let calendar = Calendar.current
//        return workouts.filter { calendar.isDate($0.date, inSameDayAs: date) }
//    }
//    
//    func workoutForToday() -> Workout? {
//        let today = Date()
//        // Assegure-se que a data do treino está comparando apenas dia/mês/ano
//        return workouts.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
//    }
//    
//    func hasWorkout(on date: Date) -> Bool {
//        !workouts(for: date).isEmpty
//    }
}

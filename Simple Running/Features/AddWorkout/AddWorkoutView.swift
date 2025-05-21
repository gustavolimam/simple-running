import SwiftUI

struct AddWorkoutView: View {
    @EnvironmentObject var store: WorkoutStore
    @Environment(\.dismiss) var dismiss // Para fechar a view (se apresentada como sheet)

    @State private var date: Date = Date()
    @State private var description: String = ""
    @State private var type: WorkoutType = .easyRun
    @State private var durationMinutesString: String = ""
    @State private var distanceKmString: String = ""

    @State private var showingAlert = false
    @State private var alertMessage = ""

    let futureDateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        let startDate = calendar.date(from: startComponents)!
        let endComponents = DateComponents(year: calendar.component(.year, from: startDate) + 2, month: 12, day: 31) // Dois anos no futuro
        let endDate = calendar.date(from: endComponents)!
        return startDate...endDate
    }()


    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalhes do Treino")) {
                    DatePicker("Data", selection: $date, in: futureDateRange, displayedComponents: .date)
                    
                    Picker("Tipo de Treino", selection: $type) {
                        ForEach(WorkoutType.allCases) { workoutType in
                            Text(workoutType.rawValue).tag(workoutType)
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Descrição")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $description)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }

                Section(header: Text("Métricas (Opcional)")) {
                    HStack {
                        Text("Duração (minutos)")
                        Spacer()
                        TextField("Ex: 30", text: $durationMinutesString)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Distância (km)")
                        Spacer()
                        TextField("Ex: 5.5", text: $distanceKmString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Button(action: saveWorkout) {
                    HStack {
                        Spacer()
                        Image(systemName: "figure.run")
                        Text("Salvar Treino")
                        Spacer()
                    }
                    .padding(.vertical, 5)
                    .font(.headline)
                }
                .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            }
            .navigationTitle("Novo Treino")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .alert("Atenção", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func saveWorkout() { // Este método não precisa ser async em si
        guard !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "A descrição do treino é obrigatória."
            showingAlert = true
            return
        }

        let duration = Int(durationMinutesString)
        let distance = Double(distanceKmString.replacingOccurrences(of: ",", with: "."))

        // Crie o objeto Workout. O userId e createdAt serão nil por padrão aqui.
        // O userId seria preenchido no WorkoutStore se a autenticação estivesse ativa.
        let newWorkout = Workout(
            date: date,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type,
            durationMinutes: duration,
            distanceKm: distance
        )

//        Task { // Chamar a função async do store dentro de uma Task
//            await store.addWorkout(newWorkout)
//            if store.errorMessage == nil { // Se não houve erro
//                dismiss() // Fecha a view
//            } else {
//                // Opcional: mostrar o erro do store.errorMessage na UI
//                alertMessage = store.errorMessage ?? "Erro desconhecido ao salvar."
//                showingAlert = true
//            }
//        }
    }
}

#Preview {
    AddWorkoutView().environmentObject(WorkoutStore())
}

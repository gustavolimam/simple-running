//
//  AddWorkoutView.swift
//  Simple Running
//
//  Created by Gustavo Monteiro on 28/05/25.
//

import SwiftUI

struct AddWorkoutView: View {
    @EnvironmentObject var store: WorkoutStore
    @Environment(\.dismiss) var dismiss
    
    @State private var date: Date = Date()
    @State private var description: String = ""
    @State private var type: WorkoutType = .easyRun
    @State private var durationMinutesString: String = ""
    @State private var distanceKmString: String = ""
    
    @State private var showingInputAlert = false
    @State private var inputAlertMessage = ""
    
    let futureDateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let endComponents = DateComponents(year: calendar.component(.year, from: startDate) + 2, month: 12, day: 31)
        let endDate = calendar.date(from: endComponents) ?? calendar.date(byAdding: .year, value: 2, to: startDate)!
        return startDate...endDate
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    WorkoutDetailSectionView(
                        date: $date,
                        description: $description,
                        type: $type,
                        futureDateRange: futureDateRange
                    )
                    
                    WorkoutMetricsSectionView(
                        durationMinutesString: $durationMinutesString,
                        distanceKmString: $distanceKmString
                    )
                    
                    Button(action: saveWorkout) {
                        HStack {
                            Spacer()
                            if store.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "figure.run")
                                Text("Salvar Treino")
                            }
                            Spacer()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(isSaveButtonDisabled() ? Color.gray : Color.accentColor)
                        .cornerRadius(12)
                    }
                    .disabled(isSaveButtonDisabled() || store.isLoading)
                    .padding(.top, 10)
                    
                }
                .padding()
            }
            .navigationTitle("Novo Treino")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .disabled(store.isLoading)
                }
            }
            .alert("Atenção", isPresented: $showingInputAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(inputAlertMessage)
            }
            .alert("Erro ao Salvar", isPresented: .constant(store.errorMessage != nil && !store.isLoading)) {
                Button("OK", role: .cancel) { store.errorMessage = nil }
            } message: {
                Text(store.errorMessage ?? "Não foi possível salvar o treino.")
            }
            .background(Color(.systemBackground).ignoresSafeArea())
        }
        .navigationViewStyle(.stack)
    }
    
    private func isSaveButtonDisabled() -> Bool {
        description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveWorkout() {
        guard !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            inputAlertMessage = "A descrição do treino é obrigatória."
            showingInputAlert = true
            return
        }
        
        let duration = Int(durationMinutesString)
        let distance = Double(distanceKmString.replacingOccurrences(of: ",", with: "."))
        
        if !durationMinutesString.isEmpty && duration == nil {
            inputAlertMessage = "A duração deve ser um número válido."
            showingInputAlert = true
            return
        }
        if !distanceKmString.isEmpty && distance == nil {
            inputAlertMessage = "A distância deve ser um número válido (ex: 5 ou 5.5)."
            showingInputAlert = true
            return
        }
        
        let newWorkout = Workout(
            date: date,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type,
            durationMinutes: duration,
            distanceKm: distance
        )
        
        Task {
            await store.addWorkout(newWorkout)
            if store.errorMessage == nil {
                dismiss()
            }
        }
    }
}

// Preview
#Preview {
    AddWorkoutView()
        .environmentObject(WorkoutStore())
        .environment(\.locale, Locale(identifier: "pt_BR"))
}

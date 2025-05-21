import SwiftUI

struct WorkoutCalendarView: View {
    @EnvironmentObject var store: WorkoutStore
    @State private var selectedDate: Date = Date()
    @State private var monthToDisplay: Date = Date()

    // Define o intervalo para o DatePicker de navegação do calendário
    private var calendarNavigationRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        // Início: 2 anos atrás do início do ano corrente
        let startComponents = DateComponents(year: currentYear - 2, month: 1, day: 1)
        let startDate = calendar.date(from: startComponents) ?? Date()
        
        // Fim: 2 anos à frente do fim do ano corrente
        let endComponents = DateComponents(year: currentYear + 2, month: 12, day: 31)
        let endDate = calendar.date(from: endComponents) ?? Date()
        
        return startDate...endDate
    }


    var body: some View {
        NavigationView {
            VStack {
                // Seletor de Mês/Ano customizado
                MonthYearPicker(date: $monthToDisplay, range: calendarNavigationRange)
                    .padding(.horizontal)
                    .padding(.bottom, 10)

                CalendarView(
                    interval: DateInterval(start: monthToDisplay.startOfMonth(), end: monthToDisplay.endOfMonth()),
                    monthToDisplay: $monthToDisplay
                ) { date in
                    Button {
                        self.selectedDate = date
                    } label: {
                        Text(String(Calendar.current.component(.day, from: date)))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .font(.body)
                            .padding(6)
                            .foregroundColor(date.isSameMonth(as: monthToDisplay) ? .primary : .secondary.opacity(0.5))
                            .background(
                                ZStack {
                                    if Calendar.current.isDateInToday(date) {
                                        Circle()
                                            .fill(Color.red.opacity(0.3))
                                    }
//                                    if store.hasWorkout(on: date) {
//                                        Circle()
//                                            .fill(Color.accentColor.opacity(selectedDate == date ? 0.7 : 0.4))
//                                    }
                                    if selectedDate == date {
                                        Circle()
                                            .stroke(Color.accentColor, lineWidth: 2)
                                    }
                                }
                            )
                            .clipShape(Circle()) // Garante que o toque funcione bem na área circular
                    }
                    .disabled(!date.isSameMonth(as: monthToDisplay)) // Desabilita dias de outros meses
                }

//                if store.hasWorkout(on: selectedDate) {
//                    WorkoutListForDate(date: selectedDate)
//                        .padding(.top)
//                } else {
                     Text("Nenhum treino para \(selectedDate, style: .date).")
                        .padding()
                        .font(.headline)
                        .foregroundColor(.secondary)
//                }

                Spacer() // Empurra o conteúdo para cima
            }
            .navigationTitle("Calendário de Treinos")
        }
    }
}

// Picker customizado para Mês e Ano
struct MonthYearPicker: View {
    @Binding var date: Date
    let range: ClosedRange<Date>

    private var year: Int {
        Calendar.current.component(.year, from: date)
    }
    private var month: Int {
        Calendar.current.component(.month, from: date)
    }

    private var monthSymbols: [String] {
        Calendar.current.monthSymbols
    }

    var body: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
            }
            .disabled(!canChangeMonth(by: -1))


            Spacer()
            
            // Picker para Mês
            Picker("Mês", selection: Binding(
                get: { self.month },
                set: { newMonth in
                    let calendar = Calendar.current
                    var components = calendar.dateComponents([.year, .month, .day], from: date)
                    components.month = newMonth
                    if let newDate = calendar.date(from: components), range.contains(newDate.startOfMonth()) {
                        self.date = newDate
                    }
                }
            )) {
                ForEach(1...12, id: \.self) { monthIndex in
                    Text(monthSymbols[monthIndex - 1]).tag(monthIndex)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            
            // Picker para Ano
            Picker("Ano", selection: Binding(
                get: { self.year },
                set: { newYear in
                    let calendar = Calendar.current
                    var components = calendar.dateComponents([.year, .month, .day], from: date)
                    components.year = newYear
                    // Tenta manter o mês, mas ajusta se o novo ano/mês estiver fora do range
                    if let newDate = calendar.date(from: components), range.contains(newDate.startOfMonth()) {
                         self.date = newDate
                    } else { // Se a data exata não funcionar, tenta o início do ano ou o mais próximo no range
                        var adjustedComponents = DateComponents(year: newYear, month: 1, day: 1)
                        if let adjustedDate = calendar.date(from: adjustedComponents) {
                            if adjustedDate < range.lowerBound { self.date = range.lowerBound }
                            else if adjustedDate.endOfMonth() > range.upperBound { self.date = range.upperBound.startOfMonth() } // vai pro inicio do ultimo mes
                            else { self.date = adjustedDate }
                        }
                    }
                }
            )) {
                let currentYear = Calendar.current.component(.year, from: Date())
                let startYear = Calendar.current.component(.year, from: range.lowerBound)
                let endYear = Calendar.current.component(.year, from: range.upperBound)
                ForEach(startYear...endYear, id: \.self) { yearValue in
                    Text(String(yearValue)).tag(yearValue)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()

            Spacer()
            
            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
            }
            .disabled(!canChangeMonth(by: 1))
        }
    }
    
    private func changeMonth(by amount: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: amount, to: date) {
            // Garante que o novo mês esteja dentro do range permitido
            if newDate.startOfMonth() >= range.lowerBound.startOfMonth() && newDate.endOfMonth() <= range.upperBound.endOfMonth() {
                self.date = newDate
            } else if newDate.startOfMonth() < range.lowerBound.startOfMonth() {
                 self.date = range.lowerBound.startOfMonth()
            } else if newDate.endOfMonth() > range.upperBound.endOfMonth() {
                 self.date = range.upperBound.startOfMonth()
            }
        }
    }
    
    private func canChangeMonth(by amount: Int) -> Bool {
        guard let newDate = Calendar.current.date(byAdding: .month, value: amount, to: date) else {
            return false
        }
        // Verifica se o início do novo mês está dentro do range
        return newDate.startOfMonth() >= range.lowerBound.startOfMonth() && newDate.startOfMonth() <= range.upperBound.startOfMonth()

    }
}


//struct WorkoutListForDate: View {
//    @EnvironmentObject var store: WorkoutStore
//    let date: Date
//
//    var body: some View {
//        let workoutsOnDate = store.workouts(for: date)
//        
//        if workoutsOnDate.isEmpty {
//            Text("Nenhum treino para este dia.")
//                .font(.headline)
//                .foregroundColor(.secondary)
//                .padding()
//        } else {
//            List {
//                ForEach(workoutsOnDate) { workout in
//                    WorkoutRow(workout: workout)
//                }
//                .onDelete(perform: deleteWorkout)
//            }
//            .listStyle(.plain) // Ou .insetGrouped para um visual diferente
//            .frame(height: CGFloat(workoutsOnDate.count) * 60 + 40) // Ajustar altura dinamicamente
//        }
//    }
//
//    private func deleteWorkout(at offsets: IndexSet) {
//        // Não é mais suficiente apenas modificar o array local.
//        // Precisamos chamar o método async do store.
//        Task {
//            await store.deleteWorkouts(at: offsets)
//            // A UI irá atualizar automaticamente por causa do @Published workouts
//            // e o store.errorMessage pode ser observado para feedback de erro.
//        }
//    }
//
//}

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
            // Poderia adicionar um chevron ou um botão de editar aqui
        }
        .padding(.vertical, 4)
    }
}

// Helper para Datas
extension Date {
    func startOfMonth() -> Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }

    func endOfMonth() -> Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func isSameMonth(as otherDate: Date) -> Bool {
        Calendar.current.isDate(self, equalTo: otherDate, toGranularity: .month)
    }
}

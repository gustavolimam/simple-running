import SwiftUI

struct WorkoutCalendarView: View {
    @EnvironmentObject var store: WorkoutStore
    @State private var selectedDate: Date = Date()
    @State private var monthToDisplay: Date = Date()
    
    private var calendarNavigationRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        let startDateComponents = DateComponents(year: currentYear - 1, month: 1, day: 1)
        let startDate = calendar.date(from: startDateComponents) ?? Date()
        
        let endDateComponents = DateComponents(year: currentYear + 5, month: 12, day: 31)
        let endDate = calendar.date(from: endDateComponents) ?? Date()
        
        return startDate...endDate
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                MonthYearPicker(date: $monthToDisplay, range: calendarNavigationRange)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                
                CalendarView(
                    interval: DateInterval(start: monthToDisplay.startOfMonth(), end: monthToDisplay.endOfMonth()),
                    monthToDisplay: $monthToDisplay
                ) { date in
                    let isDateInCurrentDisplayMonth = date.isSameMonth(as: monthToDisplay)
                    let workoutsOnThisDate = store.workouts(for: date)
                    
                    Button {
                        if isDateInCurrentDisplayMonth {
                            self.selectedDate = date
                        }
                    } label: {
                        Text(String(Calendar.current.component(.day, from: date)))
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .font(.body)
                            .foregroundColor(isDateInCurrentDisplayMonth ? .primary : .secondary.opacity(0.4))
                            .background(
                                ZStack {
                                    if Calendar.current.isDateInToday(date) && isDateInCurrentDisplayMonth {
                                        Circle()
                                            .fill(Color.red.opacity(0.3))
                                    }
                                    if !workoutsOnThisDate.isEmpty && isDateInCurrentDisplayMonth {
                                        Circle()
                                            .fill(Color.accentColor.opacity(selectedDate == date ? 0.6 : 0.35))
                                    }
                                    if selectedDate == date && isDateInCurrentDisplayMonth {
                                        Circle()
                                            .stroke(Color.accentColor, lineWidth: 2)
                                    }
                                }
                            )
                            .clipShape(Circle())
                    }
                    .disabled(!isDateInCurrentDisplayMonth)
                    .opacity(isDateInCurrentDisplayMonth ? 1.0 : 0.5)
                }
                .padding(.horizontal, 8)
                
                Divider().padding(.top, 10)
                
                WorkoutListForDateView(date: $selectedDate)
                    .padding(.top, 5)
                
                Spacer()
            }
            .navigationTitle("Calendário")
            .navigationBarTitleDisplayMode(.large)
            .alert("Erro", isPresented: .constant(store.errorMessage != nil), actions: {
                Button("OK", role: .cancel) { store.errorMessage = nil }
            }, message: {
                Text(store.errorMessage ?? "Ocorreu um erro desconhecido.")
            })
        }
        .navigationViewStyle(.stack)
    }
}

struct MonthYearPicker: View {
    @Binding var date: Date
    let range: ClosedRange<Date>
    
    private var year: Int { Calendar.current.component(.year, from: date) }
    private var month: Int { Calendar.current.component(.month, from: date) }
    private var monthSymbols: [String] { Calendar.current.monthSymbols }
    
    var body: some View {
        HStack {
            Button { changeMonth(by: -1) } label: { Image(systemName: "chevron.left.circle.fill").font(.title2) }
                .disabled(!canChangeMonth(by: -1))
            Spacer()
            Picker("Mês", selection: Binding(get: { self.month }, set: { newMonth in
                var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
                components.month = newMonth
                if let newDate = Calendar.current.date(from: components), range.contains(newDate.startOfMonth()) {
                    self.date = newDate
                }
            })) {
                ForEach(1...12, id: \.self) { Text(monthSymbols[$0 - 1]).tag($0) }
            }
            .pickerStyle(.menu).labelsHidden()
            
            Picker("Ano", selection: Binding(get: { self.year }, set: { newYear in
                var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
                components.year = newYear
                if let newDate = Calendar.current.date(from: components), range.contains(newDate.startOfMonth()) {
                    self.date = newDate
                } else {
                    var adjustedComponents = DateComponents(year: newYear, month: 1, day: 1)
                    if let adjustedDate = Calendar.current.date(from: adjustedComponents) {
                        if adjustedDate < range.lowerBound { self.date = range.lowerBound }
                        else if adjustedDate.endOfMonth() > range.upperBound { self.date = range.upperBound.startOfMonth() }
                        else { self.date = adjustedDate }
                    }
                }
            })) {
                let startYear = Calendar.current.component(.year, from: range.lowerBound)
                let endYear = Calendar.current.component(.year, from: range.upperBound)
                ForEach(startYear...endYear, id: \.self) { Text(String($0)).tag($0) }
            }
            .pickerStyle(.menu).labelsHidden()
            Spacer()
            Button { changeMonth(by: 1) } label: { Image(systemName: "chevron.right.circle.fill").font(.title2) }
                .disabled(!canChangeMonth(by: 1))
        }
    }
    
    private func changeMonth(by amount: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: amount, to: date) {
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
        guard let newDate = Calendar.current.date(byAdding: .month, value: amount, to: date) else { return false }
        return newDate.startOfMonth() >= range.lowerBound.startOfMonth() && newDate.startOfMonth() <= range.upperBound.startOfMonth()
    }
}

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

#Preview {
    WorkoutCalendarView()
        .environmentObject(WorkoutStore())
}

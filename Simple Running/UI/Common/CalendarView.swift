import SwiftUI

struct CalendarView<DateView: View>: View {
    // A propriedade interval pode ser usada pela view que consome CalendarView
    // para saber qual é o intervalo principal do mês, mas CalendarView em si
    // agora deriva seus dias diretamente de monthToDisplay.
    let interval: DateInterval
    @Binding var monthToDisplay: Date
    let content: (Date) -> DateView

    private var calendar: Calendar
    private var daysOfWeek: [String]

    // Propriedade computada para os dias, em vez de var + onChange
    private var currentGridDays: [Date] {
        Self.generateDaysInMonthGrid(for: monthToDisplay.startOfMonth(), calendar: calendar)
    }

    init(
        interval: DateInterval,
        monthToDisplay: Binding<Date>,
        calendar: Calendar = .current,
        @ViewBuilder content: @escaping (Date) -> DateView
    ) {
        self.interval = interval
        self._monthToDisplay = monthToDisplay
        self.calendar = calendar
        self.content = content
        
        var symbols = calendar.shortWeekdaySymbols
        if calendar.firstWeekday == 2 { // Se a semana começa na Segunda (Monday)
            symbols = Array(symbols[1...]) + [symbols[0]]
        }
        self.daysOfWeek = symbols
    }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 7)

        VStack {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysOfWeek, id: \.self) { daySymbol in
                    Text(daySymbol)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 5)

            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(currentGridDays, id: \.self) { date in
                    content(date)
                        .id(date) // Garante que a view seja atualizada corretamente
                }
            }
        }
        // O .onChange foi removido pois currentGridDays é computada
    }

    static func generateDaysInMonthGrid(for displayDateInMonth: Date, calendar: Calendar) -> [Date] {
        // Usa a "Solução mais simples e robusta" que tínhamos antes
        let firstOfMonth = displayDateInMonth.startOfMonth() // Garante que estamos no início do mês de referência
        let firstOfMonthWeekday = calendar.component(.weekday, from: firstOfMonth)
        
        var daysToSubtract = firstOfMonthWeekday - calendar.firstWeekday
        if daysToSubtract < 0 {
            daysToSubtract += 7
        }
        
        guard let gridActualStartDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: firstOfMonth) else {
            // Se esta guarda falhar, algo está muito errado com as datas do calendário.
            // Retornar um array vazio é uma forma segura de lidar com isso.
            return []
        }

        var finalDays: [Date] = []
        // Gerar sempre 6 semanas (42 dias) para um grid consistente
        for dayOffset in 0..<(6 * 7) {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: gridActualStartDate) {
                finalDays.append(date)
            }
        }
        // Garante que temos no máximo 42 dias
        return Array(finalDays.prefix(42))
    }
}

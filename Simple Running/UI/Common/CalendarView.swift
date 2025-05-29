import SwiftUI

struct CalendarView<DateView: View>: View {
    let interval: DateInterval
    @Binding var monthToDisplay: Date
    let content: (Date) -> DateView

    private var calendar: Calendar
    private var daysOfWeek: [String]

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
        if calendar.firstWeekday == 2 {
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
                        .id(date)
                }
            }
        }
    }

    static func generateDaysInMonthGrid(for displayDateInMonth: Date, calendar: Calendar) -> [Date] {
        let firstOfMonth = displayDateInMonth.startOfMonth()
        let firstOfMonthWeekday = calendar.component(.weekday, from: firstOfMonth)
        
        var daysToSubtract = firstOfMonthWeekday - calendar.firstWeekday
        if daysToSubtract < 0 {
            daysToSubtract += 7
        }
        
        guard let gridActualStartDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: firstOfMonth) else {
            return []
        }

        var finalDays: [Date] = []
        for dayOffset in 0..<(6 * 7) {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: gridActualStartDate) {
                finalDays.append(date)
            }
        }
        return Array(finalDays.prefix(42))
    }
}

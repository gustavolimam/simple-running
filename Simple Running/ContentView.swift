import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: WorkoutStore
    @State private var selectedTab: Tab = .today
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(store:store)
                .tabItem {
                    Label("Hoje", systemImage: "clock")
                }
                .tag(Tab.today)
            WorkoutCalendarView()
                .tabItem {
                    Label("Calendário", systemImage: "calendar")
                }
                .tag(Tab.calendar)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutStore())
}


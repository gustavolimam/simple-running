import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: WorkoutStore
    @State private var selectedTab: TabItem = .today
    
    var body: some View {
        ZStack {
            MainTabView(selectedTab: $selectedTab) { tab in
                switch tab {
                case .today:
                    TodayView()
                case .calendar:
                    WorkoutCalendarView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutStore())
}

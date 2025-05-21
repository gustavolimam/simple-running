//
//  ContentView.swift
//  Simple Running
//
//  Created by Gustavo Monteiro on 14/05/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var store = WorkoutStore()
    @State private var selectedTab: TabItem = .today
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 300)
                .foregroundColor(.red)
                .blur(radius: 10)
                .offset(x: -200, y: -200)
            
            Circle()
                .frame(width: 300)
                .foregroundColor(.cyan)
                .blur(radius: 10)
                .offset(x: 230, y: 180)
            MainTabView(selectedTab: $selectedTab) { tab in
                switch tab {
                case .today:
                    TodayView().environmentObject(store)
                case .calendar:
                    WorkoutCalendarView().environmentObject(store)
                case .add:
                    AddWorkoutView().environmentObject(store)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

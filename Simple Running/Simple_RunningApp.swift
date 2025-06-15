import SwiftUI

@main
struct Simple_RunningApp: App {
    @StateObject var workoutStore = WorkoutStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutStore)                
        }
    }
}

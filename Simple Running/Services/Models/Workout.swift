import Foundation

enum WorkoutType: String, CaseIterable, Identifiable, Codable {
    case easyRun = "Leve"
    case tempoRun = "Tempo Run"
    case intervalTraining = "Intervalado"
    case longRun = "Longo"
    case recoveryRun = "Regenerativa"
    case race = "Prova"

    var id: String { self.rawValue }

    var iconName: String {
        switch self {
        case .easyRun, .recoveryRun:
            return "figure.walk"
        case .tempoRun:
            return "figure.run.square.stack"
        case .intervalTraining:
            return "timer"
        case .longRun:
            return "figure.run"
        case .race:
            return "flag.fill"
        }
    }
}

struct Workout: Identifiable, Codable, Hashable {
    let id: UUID
    var userId: UUID?
    var date: Date
    var description: String
    var type: WorkoutType
    var durationMinutes: Int?
    var distanceKm: Double?
    var createdAt: Date?

    init(id: UUID = UUID(), userId: UUID? = nil, date: Date, description: String, type: WorkoutType, durationMinutes: Int? = nil, distanceKm: Double? = nil, createdAt: Date? = nil) {
        self.id = id
        self.userId = userId
        self.date = date
        self.description = description
        self.type = type
        self.durationMinutes = durationMinutes
        self.distanceKm = distanceKm
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case description
        case type
        case durationMinutes = "duration_minutes"
        case distanceKm = "distance_km"
        case createdAt = "created_at"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Workout, rhs: Workout) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mock Data
extension Workout {
    static var mockWorkouts: [Workout] {
        let calendar = Calendar.current
        let now = Date()
        let userId = UUID() // Consistent user ID for mocks

        return [
            Workout(
                userId: userId,
                date: calendar.date(byAdding: .day, value: -5, to: now)!,
                description: "Manhã tranquila, foco na consistência.",
                type: .easyRun,
                durationMinutes: 45,
                distanceKm: 5.2,
                createdAt: calendar.date(byAdding: .day, value: -5, to: now)!
            ),
            Workout(
                userId: userId,
                date: calendar.date(byAdding: .day, value: -4, to: now)!,
                description: "Sessão de ritmo desafiadora, mas gratificante.",
                type: .tempoRun,
                durationMinutes: 60,
                distanceKm: 10.0,
                createdAt: calendar.date(byAdding: .day, value: -4, to: now)!
            ),
            Workout(
                userId: userId,
                date: calendar.date(byAdding: .day, value: -3, to: now)!,
                description: "8x400m com recuperação de 200m.",
                type: .intervalTraining,
                distanceKm: 6.5, // Total distance including recovery
                createdAt: calendar.date(byAdding: .day, value: -3, to: now)!
            ),
            Workout(
                userId: userId,
                date: calendar.date(byAdding: .day, value: -2, to: now)!,
                description: "Longo do fim de semana, ritmo confortável.",
                type: .longRun,
                durationMinutes: 120,
                distanceKm: 18.5,
                createdAt: calendar.date(byAdding: .day, value: -2, to: now)!
            ),
            Workout(
                userId: userId,
                date: calendar.date(byAdding: .day, value: -1, to: now)!,
                description: "Giro leve para soltar as pernas pós longo.",
                type: .recoveryRun,
                durationMinutes: 30,
                distanceKm: 3.0,
                createdAt: calendar.date(byAdding: .day, value: -1, to: now)!
            ),
            Workout(
                userId: userId,
                date: now,
                description: "Corrida de 10k da cidade! PR!",
                type: .race,
                durationMinutes: 48,
                distanceKm: 10.0,
                createdAt: now
            ),
            Workout( // Another user example or workout without distance/duration
                userId: UUID(), // Different user
                date: calendar.date(byAdding: .hour, value: -2, to: now)!,
                description: "Treino de reforço na academia.",
                type: .easyRun, // Could be a placeholder or a different type
                createdAt: calendar.date(byAdding: .hour, value: -2, to: now)!
            ),
             Workout(
                id: UUID(),
                userId: userId,
                date: calendar.date(byAdding: .day, value: 1, to: now)!, // Future workout
                description: "Planejamento: Tiros curtos na pista.",
                type: .intervalTraining,
                createdAt: now
            )
        ]
    }

    static var mockWorkout: Workout {
        return mockWorkouts.first ?? Workout(date: Date(), description: "Fallback Mock", type: .easyRun)
    }
}

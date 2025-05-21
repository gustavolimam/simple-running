import Foundation

enum WorkoutType: String, CaseIterable, Identifiable, Codable {
    case easyRun = "Corrida Leve"
    case tempoRun = "Tempo Run"
    case intervalTraining = "Treino Intervalado"
    case longRun = "Longão"
    case recoveryRun = "Corrida Regenerativa"
    case race = "Prova"

    var id: String { self.rawValue }

    var iconName: String {
        switch self {
        case .easyRun, .recoveryRun:
            return "figure.walk" // Usando um ícone mais leve para corridas leves
        case .tempoRun:
            return "figure.run.square.stack"
        case .intervalTraining:
            return "timer"
        case .longRun:
            return "figure.outdoor.cycle" // Reutilizando para longão pela distância
        case .race:
            return "flag.fill"
        }
    }
}

struct Workout: Identifiable, Codable, Hashable {
    let id: UUID
    var userId: UUID? // Opcional, para vincular ao usuário do Supabase Auth
    var date: Date
    var description: String
    var type: WorkoutType
    var durationMinutes: Int?
    var distanceKm: Double?
    var createdAt: Date? // Supabase adiciona created_at por padrão

    // Inicializador principal
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

    // CodingKeys para mapear entre camelCase (Swift) e snake_case (Supabase/JSON)
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id" // Mapeia para a coluna user_id
        case date
        case description
        case type
        case durationMinutes = "duration_minutes"
        case distanceKm = "distance_km"
        case createdAt = "created_at"
    }

    // Para conformar com Hashable se `id` é suficiente
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Workout, rhs: Workout) -> Bool {
        lhs.id == rhs.id
    }
}
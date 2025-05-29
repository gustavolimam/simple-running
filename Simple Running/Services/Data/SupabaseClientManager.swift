import Foundation
import Supabase

struct SupabaseClientManager {
    static let shared = SupabaseClientManager()
    let client: SupabaseClient
    
    private init() {
        guard let supabaseURL = URL(string: "https://zuqtrlwvzchqhlmxaavv.supabase.co") else {
            fatalError("Supabase URL é inválida.")
        }

        let supabaseAnnonKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"]
        
        let customDecoder = JSONDecoder()
        customDecoder.dateDecodingStrategy = .custom { decoder throws -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let yyyyMMddFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.calendar = Calendar(identifier: .iso8601)
                formatter.timeZone = Calendar.current.timeZone
                return formatter
            }()
            
            if let date = yyyyMMddFormatter.date(from: dateString) {
                return date
            }
            
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            
            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "A string de data '\(dateString)' não corresponde a um formato conhecido.")
        }
        
        let defaultEncoder = JSONEncoder()
        defaultEncoder.dateEncodingStrategy = .iso8601
        
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseAnnonKey!,
            options: SupabaseClientOptions(
                db: SupabaseClientOptions.DatabaseOptions(
                    encoder: defaultEncoder,
                    decoder: customDecoder,
                ),
            )
        )
        print("SupabaseClient inicializado com sucesso.")
    }
}

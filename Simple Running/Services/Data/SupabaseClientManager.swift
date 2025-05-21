import Foundation
import Supabase

class SupabaseClientManager {
    static let shared = SupabaseClientManager()

    private init() {}
        let client = SupabaseClient(
            supabaseURL: URL(string:"https://zuqtrlwvzchqhlmxaavv.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp1cXRybHd2emNocWhsbXhhYXZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyNDgxNjgsImV4cCI6MjA2MjgyNDE2OH0.0I6yJzNXI2N-kKWzPJSLzHVLgE0fqJStsySx67g7BFA"
        )
    
    func fetchData() async throws {
        let response = try await client.from("workouts").select("*").execute()
        print(response)
    }
}

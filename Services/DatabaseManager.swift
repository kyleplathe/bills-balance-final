import Foundation
import Supabase

final class DatabaseManager {
    static let shared = DatabaseManager()

    let client: SupabaseClient

    private init() {
        let urlString = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""
        let anonKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? ""
        guard let supabaseURL = URL(string: urlString), !anonKey.isEmpty else {
            fatalError("Missing SUPABASE_URL or SUPABASE_ANON_KEY in environment.")
        }

        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: anonKey)
    }
}

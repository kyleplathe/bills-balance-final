import Foundation
import Supabase

final class DatabaseManager {
    static let shared = DatabaseManager()

    /// `nil` when `SUPABASE_URL` / `SUPABASE_ANON_KEY` are missing (e.g. SwiftUI previews without secrets).
    let client: SupabaseClient?

    private init() {
        let urlString = Configuration.supabaseURL
        let anonKey = Configuration.supabaseAnonKey

        guard let supabaseURL = URL(string: urlString),
              !anonKey.isEmpty,
              supabaseURL.scheme == "http" || supabaseURL.scheme == "https"
        else {
            Self.logMissingCredentials(urlString: urlString, anonKeyEmpty: anonKey.isEmpty)
            client = nil
            return
        }

        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: anonKey)
    }

    private static func logMissingCredentials(urlString: String, anonKeyEmpty: Bool) {
        let previewHint = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
            ? " (running for SwiftUI previews)"
            : ""
        print("""
        [DatabaseManager] Supabase is not configured\(previewHint): \
        SUPABASE_URL is \(urlString.isEmpty ? "empty" : "set") \
        and SUPABASE_ANON_KEY is \(anonKeyEmpty ? "empty" : "set"). \
        Add INFOPLIST_KEY_SUPABASE_URL and INFOPLIST_KEY_SUPABASE_ANON_KEY via xcconfig, or set env vars. \
        Ledger/email features that need Supabase will be skipped.
        """)
    }
}

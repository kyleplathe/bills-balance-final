import Foundation

/// Values injected at build time via `Secrets.xcconfig` → `INFOPLIST_KEY_*` (merged into the generated Info.plist).
enum Configuration {
    private static func string(for key: String) -> String {
        let plist = Bundle.main.infoDictionary ?? [:]
        if let raw = plist[key] {
            if let s = raw as? String {
                return normalizePlistString(s)
            }
            if let n = raw as? NSNumber {
                return n.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        if let env = ProcessInfo.processInfo.environment[key] {
            return env.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }

    /// Strips surrounding quotes that sometimes appear when xcconfig values are quoted.
    private static func normalizePlistString(_ value: String) -> String {
        var s = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.count >= 2, s.first == "\"", s.last == "\"" {
            s.removeFirst()
            s.removeLast()
            s = s.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return s
    }

    static let supabaseURL: String = string(for: "SUPABASE_URL")
    /// Supabase anon (publishable) key — same role as `SUPABASE_ANON_KEY` in `.env.local`.
    static let supabaseAnonKey: String = string(for: "SUPABASE_ANON_KEY")
    static let resendAPIKey: String = string(for: "RESEND_API_KEY")
}

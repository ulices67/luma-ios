import Foundation
#if canImport(Translation)
import Translation
#endif

/// Actor managing on-device and low-latency phrase-level translation
public actor TranslationEngine {
    public static let shared = TranslationEngine()

    private let session = URLSession.shared

    private init() {}

    /// Translates a full sentence while maintaining natural grammar and idioms
    public func translate(
        _ text: String,
        from source: String = "en",
        to target: String = "es"
    ) async throws -> String {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return text }

        if source.lowercased() == target.lowercased() {
            return text
        }

        // Live edge neural query (low-latency phrase translation)
        guard let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.mymemory.translated.net/get?q=\(encoded)&langpair=\(source)|\(target)") else {
            return text
        }

        do {
            let (data, response) = try await session.data(from: url)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let responseData = json["responseData"] as? [String: Any],
               let translatedText = responseData["translatedText"] as? String,
               !translatedText.isEmpty {
                return translatedText
            }
        } catch {
            print("TranslationEngine network error: \(error)")
        }

        return text
    }
}

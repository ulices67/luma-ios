import Foundation
import NaturalLanguage

/// Automatic language identification engine for audio transcription
public final class LanguageDetector {
    public static let shared = LanguageDetector()

    private let recognizer = NLLanguageRecognizer()

    private init() {}

    /// Detects dominant BCP-47 language tag (e.g. "en", "es", "fr", "ja")
    public func detectLanguage(text: String) -> String {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return "en" }
        recognizer.reset()
        recognizer.processString(text)
        return recognizer.dominantLanguage?.rawValue ?? "en"
    }
}

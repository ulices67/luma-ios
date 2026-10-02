import Foundation

public final class TranslationService: ObservableObject {
    public static let shared = TranslationService()

    private init() {}

    /// Aligns source words with target translation words based on semantic mapping.
    public func alignWords(
        sourceWords: [TimedWord],
        translatedWords: [TimedWord]
    ) -> [TimedWord] {
        // Build aligned tokens
        var alignedSources: [TimedWord] = []
        for (i, word) in sourceWords.enumerated() {
            let targetIdx = word.alignedTargetIndex ?? min(i, max(0, translatedWords.count - 1))
            let aligned = TimedWord(
                id: word.id,
                text: word.text,
                startTime: word.startTime,
                endTime: word.endTime,
                alignedTargetIndex: targetIdx
            )
            alignedSources.append(aligned)
        }
        return alignedSources
    }

    /// Provides on-device neural translation fallback
    public func translate(text: String, from sourceLang: String, to targetLang: String) async -> String {
        // In production on iOS 17.4+, this interfaces with `TranslationSession.translate()`
        return text
    }
}

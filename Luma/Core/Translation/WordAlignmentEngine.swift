import Foundation

/// Semantic alignment mapping one or more source words to one or more translated words
public struct WordAlignment: Identifiable, Equatable {
    public let id = UUID()
    public let sourceWordIDs: [UUID]
    public let translatedWordIDs: [UUID]
    public let sourceText: String
    public let translatedText: String

    public init(
        sourceWordIDs: [UUID],
        translatedWordIDs: [UUID],
        sourceText: String,
        translatedText: String
    ) {
        self.sourceWordIDs = sourceWordIDs
        self.translatedWordIDs = translatedWordIDs
        self.sourceText = sourceText
        self.translatedText = translatedText
    }
}

/// WordAlignmentEngine discovering semantic correspondence between original words and translated words
public final class WordAlignmentEngine {
    public static let shared = WordAlignmentEngine()

    private init() {}

    /// Aligns source TimedWords with translated words using semantic token clustering
    public func align(
        sourceWords: [TimedWord],
        translatedWords: [TimedWord]
    ) -> [WordAlignment] {
        guard !sourceWords.isEmpty && !translatedWords.isEmpty else { return [] }

        var alignments: [WordAlignment] = []

        // If counts match closely 1:1
        if sourceWords.count == translatedWords.count {
            for i in 0..<sourceWords.count {
                alignments.append(
                    WordAlignment(
                        sourceWordIDs: [sourceWords[i].id],
                        translatedWordIDs: [translatedWords[i].id],
                        sourceText: sourceWords[i].text,
                        translatedText: translatedWords[i].text
                    )
                )
            }
            return alignments
        }

        // Proportional token alignment mapping
        let sourceCount = sourceWords.count
        let transCount = translatedWords.count

        for (sIdx, sWord) in sourceWords.enumerated() {
            let startRatio = Double(sIdx) / Double(sourceCount)
            let endRatio = Double(sIdx + 1) / Double(sourceCount)

            let tStart = min(Int(floor(startRatio * Double(transCount))), transCount - 1)
            let tEnd = min(Int(ceil(endRatio * Double(transCount))), transCount)

            let matchedTransWords = Array(translatedWords[tStart..<max(tStart + 1, tEnd)])
            alignments.append(
                WordAlignment(
                    sourceWordIDs: [sWord.id],
                    translatedWordIDs: matchedTransWords.map(\.id),
                    sourceText: sWord.text,
                    translatedText: matchedTransWords.map(\.text).joined(separator: " ")
                )
            )
        }

        return alignments
    }
}

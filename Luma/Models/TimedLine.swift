import Foundation

/// Represents a synchronized line of lyrics, dialogue, or subtitles.
public struct TimedLine: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public let startTime: Double
    public let endTime: Double
    public let originalText: String
    public let translatedText: String
    public let originalWords: [TimedWord]
    public let translatedWords: [TimedWord]
    public let chord: String?
    public let speaker: String?
    public let speakerAvatar: String?

    public init(
        id: UUID = UUID(),
        startTime: Double,
        endTime: Double,
        originalText: String,
        translatedText: String,
        originalWords: [TimedWord] = [],
        translatedWords: [TimedWord] = [],
        chord: String? = nil,
        speaker: String? = nil,
        speakerAvatar: String? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.originalText = originalText
        self.translatedText = translatedText
        self.originalWords = originalWords
        self.translatedWords = translatedWords
        self.chord = chord
        self.speaker = speaker
        self.speakerAvatar = speakerAvatar
    }

    /// Checks if this line is currently in the active playback window.
    public func isActive(at currentTime: Double) -> Bool {
        return currentTime >= startTime && currentTime <= endTime
    }

    /// Finds the currently active original word index, if any.
    public func activeOriginalWordIndex(at currentTime: Double) -> Int? {
        return originalWords.firstIndex(where: { $0.isActive(at: currentTime) })
    }

    /// Finds the aligned translated word index for the currently active original word.
    public func activeTranslatedWordIndex(at currentTime: Double) -> Int? {
        guard let activeOrigIdx = activeOriginalWordIndex(at: currentTime) else {
            return nil
        }
        let activeWord = originalWords[activeOrigIdx]
        if let targetIdx = activeWord.alignedTargetIndex, targetIdx < translatedWords.count {
            return targetIdx
        }
        // Fallback: estimate proportion if direct alignment is not mapped
        if !originalWords.isEmpty && !translatedWords.isEmpty {
            let ratio = Double(activeOrigIdx) / Double(originalWords.count)
            let estimatedIdx = Int(ratio * Double(translatedWords.count))
            return min(estimatedIdx, translatedWords.count - 1)
        }
        return nil
    }
}

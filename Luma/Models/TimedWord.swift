import Foundation

/// Represents a single word with precise timing for real-time karaoke fill and subtitle tracking.
public struct TimedWord: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public let text: String
    public let startTime: Double
    public let endTime: Double
    public let alignedTargetIndex: Int?

    public init(
        id: UUID = UUID(),
        text: String,
        startTime: Double,
        endTime: Double,
        alignedTargetIndex: Int? = nil
    ) {
        self.id = id
        self.text = text
        self.startTime = startTime
        self.endTime = endTime
        self.alignedTargetIndex = alignedTargetIndex
    }

    /// Calculates smooth completion percentage (0.0 to 1.0) of the word at the current playhead time.
    public func progress(at currentTime: Double) -> Double {
        let duration = endTime - startTime
        guard duration > 0 else {
            return currentTime >= endTime ? 1.0 : 0.0
        }
        if currentTime < startTime {
            return 0.0
        } else if currentTime >= endTime {
            return 1.0
        } else {
            return (currentTime - startTime) / duration
        }
    }

    /// Checks if this word is currently being sung or spoken.
    public func isActive(at currentTime: Double) -> Bool {
        return currentTime >= startTime && currentTime < endTime
    }

    /// Checks if this word has already finished.
    public func isPast(at currentTime: Double) -> Bool {
        return currentTime >= endTime
    }
}

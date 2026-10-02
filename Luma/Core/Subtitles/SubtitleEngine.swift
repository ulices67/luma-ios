import Foundation
import Combine
import SwiftUI

/// Standard subtitle cue delivered to SubtitleEngine
public struct SubtitleCue: Identifiable, Equatable {
    public let id = UUID()
    public let source: String
    public let translation: String
    public let words: [TimedWord]
    public let start: TimeInterval
    public let end: TimeInterval

    public init(
        source: String,
        translation: String,
        words: [TimedWord],
        start: TimeInterval,
        end: TimeInterval
    ) {
        self.source = source
        self.translation = translation
        self.words = words
        self.start = start
        self.end = end
    }

    public func isActive(at time: TimeInterval) -> Bool {
        return time >= start && time <= end
    }
}

/// SubtitleEngine decoupled from recognition/translation, driving 60 FPS word highlighting and cue scheduling
public final class SubtitleEngine: ObservableObject {
    public static let shared = SubtitleEngine()

    @Published public var cues: [SubtitleCue] = []
    @Published public var activeCue: SubtitleCue?
    @Published public var upcomingCue: SubtitleCue?
    @Published public var activeWordIndex: Int?
    @Published public var activeWordProgress: Double = 0.0
    @Published public var currentTime: TimeInterval = 0.0
    @Published public var isRunning: Bool = false

    private var displayTimer: AnyCancellable?

    private init() {}

    public func setCues(_ newCues: [SubtitleCue]) {
        self.cues = newCues.sorted { $0.start < $1.start }
        updateState()
    }

    public func appendCue(_ cue: SubtitleCue) {
        self.cues.append(cue)
        self.cues.sort { $0.start < $1.start }
        updateState()
    }

    public func start(startOffset: TimeInterval = 0.0) {
        self.currentTime = startOffset
        self.isRunning = true

        displayTimer?.cancel()
        // 60 FPS clock for ultra-smooth letter and word progress
        displayTimer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isRunning else { return }
                self.currentTime += (1.0 / 60.0)
                self.updateState()
            }
    }

    public func seek(to time: TimeInterval) {
        self.currentTime = time
        updateState()
    }

    public func stop() {
        isRunning = false
        displayTimer?.cancel()
        displayTimer = nil
    }

    private func updateState() {
        // Find active cue
        if let current = cues.first(where: { $0.isActive(at: currentTime) }) {
            self.activeCue = current

            // Find active word and calculate progress
            if let wIdx = current.words.firstIndex(where: { currentTime >= $0.startTime && currentTime < $0.endTime }) {
                self.activeWordIndex = wIdx
                let word = current.words[wIdx]
                let dur = word.endTime - word.startTime
                self.activeWordProgress = dur > 0 ? min(1.0, max(0.0, (currentTime - word.startTime) / dur)) : 1.0
            } else {
                self.activeWordIndex = nil
                self.activeWordProgress = 0.0
            }

            // Find upcoming cue
            if let nextIdx = cues.firstIndex(where: { $0.start > current.end }) {
                self.upcomingCue = cues[nextIdx]
            }
        } else {
            self.activeCue = nil
            self.activeWordIndex = nil
            self.activeWordProgress = 0.0
        }
    }
}

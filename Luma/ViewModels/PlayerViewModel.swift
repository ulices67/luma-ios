import Foundation
import SwiftUI
import Combine

public final class PlayerViewModel: ObservableObject {
    @Published public var track: MediaTrack
    @Published public var currentTime: Double = 84.0
    @Published public var isPlaying: Bool = true
    @Published public var displayMode: LyricsDisplayMode = .both
    @Published public var isFavorite: Bool = false
    @Published public var isShuffle: Bool = false
    @Published public var isRepeat: Bool = false
    @Published public var playbackRate: Double = 1.0
    @Published public var isDrawerExpanded: Bool = false
    @Published public var activeLineIndex: Int = 1

    private var playbackTimer: AnyCancellable?

    public init(track: MediaTrack = SampleData.blindingLights) {
        self.track = track
        self.isFavorite = track.isFavorite
        if let firstLine = track.lyricsLines.first {
            self.currentTime = firstLine.startTime
        }
        startTimer()
    }

    public func setTrack(_ newTrack: MediaTrack, startOffset: Double? = nil) {
        self.track = newTrack
        self.isFavorite = newTrack.isFavorite
        if let offset = startOffset {
            self.currentTime = offset
        } else if let firstLine = newTrack.lyricsLines.first {
            self.currentTime = firstLine.startTime
        } else {
            self.currentTime = 0
        }
        updateActiveLine()
    }

    public func togglePlayPause() {
        isPlaying.toggle()
        if isPlaying {
            startTimer()
        } else {
            playbackTimer?.cancel()
        }
    }

    public func seek(to time: Double) {
        currentTime = min(max(time, 0), track.duration)
        updateActiveLine()
    }

    public func skip(seconds: Double) {
        seek(to: currentTime + seconds)
    }

    private func startTimer() {
        playbackTimer?.cancel()
        playbackTimer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isPlaying else { return }
                if self.currentTime < self.track.duration {
                    self.currentTime += 0.05 * self.playbackRate
                    self.updateActiveLine()
                } else {
                    if self.isRepeat {
                        self.currentTime = 0
                    } else {
                        self.isPlaying = false
                    }
                }
            }
    }

    private func updateActiveLine() {
        guard !track.lyricsLines.isEmpty else { return }
        if let index = track.lyricsLines.firstIndex(where: { $0.isActive(at: currentTime) }) {
            if self.activeLineIndex != index {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.activeLineIndex = index
                }
            }
        } else if let lastPast = track.lyricsLines.lastIndex(where: { $0.endTime <= currentTime }) {
            self.activeLineIndex = min(lastPast + 1, track.lyricsLines.count - 1)
        }
    }

    public func formatTime(_ timeInSeconds: Double) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

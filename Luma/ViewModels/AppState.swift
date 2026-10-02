import Foundation
import SwiftUI
import Combine

public enum AppTab: Int, CaseIterable {
    case home = 0
    case explore = 1
    case listen = 2
    case library = 3
    case settings = 4
}

public final class AppState: ObservableObject {
    public static let shared = AppState()

    @Published public var selectedTab: AppTab = .home
    @Published public var currentTrack: MediaTrack = SampleData.blindingLights
    @Published public var isPlayerPresented: Bool = false
    @Published public var isListeningPresented: Bool = false
    @Published public var isFloatingOverlayActive: Bool = false
    @Published public var floatingWindowOffset: CGSize = .zero
    @Published public var isExpandedFloating: Bool = false
    @Published public var subtitleSettings: SubtitleSettings = SubtitleSettings()
    @Published public var recentTracks: [MediaTrack] = SampleData.sampleLibrary
    @Published public var isMediaEngineRunning: Bool = false

    private init() {}

    public func openTrack(_ track: MediaTrack) {
        self.currentTrack = track
        self.isPlayerPresented = true

        // Feed cues to SubtitleEngine
        let cues: [SubtitleCue] = track.lyricsLines.map { line in
            SubtitleCue(
                source: line.originalText,
                translation: line.translatedText,
                words: line.originalWords,
                start: line.startTime,
                end: line.endTime
            )
        }
        SubtitleEngine.shared.setCues(cues)
    }

    public func openListening() {
        self.isListeningPresented = true
        AudioRecognitionService.shared.startListening()
    }

    /// Starts universal real-time capture and translation across all apps
    public func startUniversalMediaTranslation(useMicrophone: Bool = true) {
        Task {
            do {
                try await MediaEngine.shared.start(useMicrophone: useMicrophone)
                await MainActor.run {
                    self.isMediaEngineRunning = true
                    self.isFloatingOverlayActive = true
                }
            } catch {
                print("Failed to start MediaEngine: \(error)")
            }
        }
    }

    public func stopUniversalMediaTranslation() {
        Task {
            await MediaEngine.shared.stop()
            await MainActor.run {
                self.isMediaEngineRunning = false
            }
        }
    }

    /// Triggers iOS system Picture-in-Picture window floating over Spotify, YouTube, Safari
    public func toggleSystemPiP() {
        if PiPSubtitleController.shared.isPiPActive {
            PiPSubtitleController.shared.stopPiP()
        } else {
            PiPSubtitleController.shared.startPiP()
        }
    }
}

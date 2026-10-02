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

    private init() {}

    public func openTrack(_ track: MediaTrack) {
        self.currentTrack = track
        self.isPlayerPresented = true
    }

    public func openListening() {
        self.isListeningPresented = true
        AudioRecognitionService.shared.startListening()
    }
}

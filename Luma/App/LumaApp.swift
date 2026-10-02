import SwiftUI
import AVFAudio

@main
struct LumaApp: App {
    @StateObject private var appState = AppState.shared

    init() {
        configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(appState.subtitleSettings.theme == .dark ? .dark : (appState.subtitleSettings.theme == .light ? .light : nil))
        }
    }

    private func configureAudioSession() {
        #if os(iOS)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetooth, .defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Failed to configure background audio session: \(error)")
        }
        #endif
    }
}

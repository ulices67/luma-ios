import SwiftUI

public struct MainTabView: View {
    @ObservedObject var appState: AppState = AppState.shared
    @StateObject private var floatingPlayerVM = PlayerViewModel(track: SampleData.blindingLights)

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Tab View Content
            TabView(selection: $appState.selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Inicio", systemImage: "house.fill")
                    }
                    .tag(AppTab.home)

                LibraryView()
                    .tabItem {
                        Label("Explorar", systemImage: "magnifyingglass")
                    }
                    .tag(AppTab.explore)

                // Dummy placeholder for center button spacing
                Color.clear
                    .tabItem {
                        Text("")
                    }
                    .tag(AppTab.listen)

                LibraryView()
                    .tabItem {
                        Label("Biblioteca", systemImage: "books.vertical.fill")
                    }
                    .tag(AppTab.library)

                OfflineLanguagesView()
                    .tabItem {
                        Label("Ajustes", systemImage: "gearshape.fill")
                    }
                    .tag(AppTab.settings)
            }

            // Prominent Center Listening Button matching Mockup
            VStack {
                Spacer()
                Button {
                    appState.openListening()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.primary)
                            .frame(width: 54, height: 54)
                            .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)

                        Image(systemName: "waveform.badge.mic")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(.systemBackground))
                    }
                }
                .offset(y: -14)
            }
            .ignoresSafeArea(.keyboard)

            // Picture-in-Picture Floating Subtitle Overlay (if active)
            if appState.isFloatingOverlayActive {
                VStack {
                    Spacer()
                    FloatingPipCapsuleView(playerVM: floatingPlayerVM)
                        .padding(.bottom, 90)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        // Listening Modal Sheet
        .fullScreenCover(isPresented: $appState.isListeningPresented) {
            ListeningView()
        }
        // Media Player Modal Sheet
        .fullScreenCover(isPresented: $appState.isPlayerPresented) {
            Group {
                switch appState.currentTrack.mediaType {
                case .music:
                    if appState.currentTrack.title == "Midnight Echo" {
                        AppleMusicStylePlayerView(track: appState.currentTrack)
                    } else {
                        MusicLyricsView(track: appState.currentTrack)
                    }
                case .video:
                    VideoPlayerView(track: appState.currentTrack)
                case .podcast:
                    PodcastPlayerView(track: appState.currentTrack)
                case .file:
                    MusicLyricsView(track: appState.currentTrack)
                }
            }
        }
    }
}

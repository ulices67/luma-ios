import SwiftUI

/// Video & Movie Player with Synchronized Subtitles matching Image 3 Screen 3 (Interstellar)
public struct VideoPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var playerVM: PlayerViewModel
    @ObservedObject var appState: AppState = AppState.shared
    @State private var showSettingsSheet: Bool = false

    public init(track: MediaTrack = SampleData.interstellar) {
        _playerVM = StateObject(wrappedValue: PlayerViewModel(track: track))
    }

    public var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Video Screen Simulation
                ZStack(alignment: .bottom) {
                    // Movie Screen Canvas
                    ZStack {
                        Color.black
                        // Cinematic gradient background simulation
                        LinearGradient(
                            colors: [Color(red: 0.1, green: 0.15, blue: 0.25), Color.black],
                            startPoint: .top,
                            endPoint: .bottom
                        )

                        VStack {
                            Image(systemName: "film.stack")
                                .font(.system(size: 44))
                                .foregroundColor(.white.opacity(0.3))
                            Text("Interstellar (2014)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                        }

                        // Floating subtitle overlay inside video frame if position is set to inside
                        if appState.subtitleSettings.position == .center,
                           let line = playerVM.track.lyricsLines[safe: playerVM.activeLineIndex] {
                            VStack(spacing: 4) {
                                Text(line.originalText)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                Text(line.translatedText)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.75))
                            .cornerRadius(10)
                        }
                    }
                    .frame(height: 220)

                    // Video Controls Overlay
                    VStack {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }

                            Spacer()

                            Button {
                                showSettingsSheet = true
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(12)

                        Spacer()

                        // Time bar and Fullscreen icon
                        HStack {
                            Text("\(playerVM.formatTime(playerVM.currentTime)) / \(playerVM.formatTime(playerVM.track.duration))")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.85))

                            Spacer()

                            Button {
                                // Fullscreen action
                            } label: {
                                Image(systemName: "viewfinder")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 8)
                    }
                    .frame(height: 220)
                }

                // Title & Year
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(playerVM.track.title)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        Text(playerVM.track.year)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button {
                        appState.isFloatingOverlayActive.toggle()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "pip.enter")
                            Text("Flotante")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.12))
                        .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)

                // Segmented Modes: [Original] [Español] [Ambos] [Ajustes]
                HStack(spacing: 8) {
                    ForEach([LyricsDisplayMode.original, .translated, .both], id: \.self) { mode in
                        Button {
                            withAnimation {
                                playerVM.displayMode = mode
                            }
                        } label: {
                            Text(mode.rawValue)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(playerVM.displayMode == mode ? .white : .secondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule()
                                        .fill(playerVM.displayMode == mode ? Color.blue : Color(.secondarySystemBackground))
                                )
                        }
                    }

                    Button {
                        showSettingsSheet = true
                    } label: {
                        Text("Ajustes")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(Color(.secondarySystemBackground)))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)

                // Subtitle Script Timeline
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(Array(playerVM.track.lyricsLines.enumerated()), id: \.element.id) { index, line in
                                let isCurrent = index == playerVM.activeLineIndex

                                HStack(alignment: .top, spacing: 14) {
                                    // Timestamp
                                    Text(playerVM.formatTime(line.startTime))
                                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                        .foregroundColor(isCurrent ? .blue : .secondary.opacity(0.7))
                                        .frame(width: 44, alignment: .leading)

                                    // Content
                                    VStack(alignment: .leading, spacing: 4) {
                                        // Original with active pill highlight
                                        if playerVM.displayMode != .translated {
                                            let activeWordIdx = line.activeOriginalWordIndex(at: playerVM.currentTime)

                                            HStack(spacing: 4) {
                                                ForEach(Array(line.originalWords.enumerated()), id: \.element.id) { wIdx, word in
                                                    KaraokeWordView(
                                                        word: word,
                                                        currentTime: playerVM.currentTime,
                                                        style: .pillBadge,
                                                        fontSize: 16,
                                                        fontWeight: .semibold,
                                                        isAlignedHighlight: isCurrent && (wIdx == activeWordIdx)
                                                    )
                                                }
                                            }
                                        }

                                        // Translation
                                        if playerVM.displayMode != .original {
                                            let activeTargetIdx = line.activeTranslatedWordIndex(at: playerVM.currentTime)

                                            HStack(spacing: 4) {
                                                ForEach(Array(line.translatedWords.enumerated()), id: \.element.id) { tIdx, word in
                                                    let isTargetActive = isCurrent && (tIdx == activeTargetIdx)

                                                    Text(word.text)
                                                        .font(.system(size: 14, weight: isTargetActive ? .bold : .regular))
                                                        .foregroundColor(isTargetActive ? .blue : .secondary)
                                                }
                                            }
                                        }
                                    }
                                }
                                .id(index)
                                .padding(.horizontal, 20)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    playerVM.seek(to: line.startTime)
                                }
                            }
                            Spacer(minLength: 40)
                        }
                        .padding(.top, 16)
                    }
                    .onChange(of: playerVM.activeLineIndex) { newIndex in
                        withAnimation {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }

                // Media Control Toolbar
                HStack(spacing: 40) {
                    Button {
                        playerVM.skip(seconds: -10)
                    } label: {
                        Image(systemName: "gobackward.10")
                            .font(.system(size: 22))
                            .foregroundColor(.primary)
                    }

                    Button {
                        playerVM.togglePlayPause()
                    } label: {
                        Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                            .frame(width: 58, height: 58)
                            .background(Color.primary)
                            .clipShape(Circle())
                    }

                    Button {
                        playerVM.skip(seconds: 15)
                    } label: {
                        Image(systemName: "goforward.15")
                            .font(.system(size: 22))
                            .foregroundColor(.primary)
                    }

                    Button {
                        showSettingsSheet = true
                    } label: {
                        Image(systemName: "captions.bubble.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.vertical, 14)
            }
        }
        .sheet(isPresented: $showSettingsSheet) {
            SubtitleSettingsView()
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

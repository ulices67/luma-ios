import SwiftUI

/// Full-screen Apple Music style lyrics view matching Image 1 ("Midnight Echo - Luna Rivera")
public struct AppleMusicStylePlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var playerVM: PlayerViewModel
    @State private var showAnalyzerSheet: Bool = false
    @ObservedObject var appState: AppState = AppState.shared

    public init(track: MediaTrack = SampleData.midnightEcho) {
        _playerVM = StateObject(wrappedValue: PlayerViewModel(track: track))
    }

    public var body: some View {
        ZStack {
            // Blurred Dynamic Atmospheric Background
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.12, blue: 0.20),
                    Color(red: 0.18, green: 0.14, blue: 0.24),
                    Color(red: 0.06, green: 0.07, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Navigation & Track Info Bar
                HStack(spacing: 12) {
                    // Album art thumbnail
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    .frame(width: 48, height: 48)
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(playerVM.track.title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(playerVM.track.artistOrCreator)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    // Favorite Button
                    Button {
                        playerVM.isFavorite.toggle()
                    } label: {
                        Image(systemName: playerVM.isFavorite ? "star.fill" : "star")
                            .font(.system(size: 15))
                            .foregroundColor(playerVM.isFavorite ? .yellow : .white)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }

                    // Options Button
                    Menu {
                        Button("Activar traducción flotante") {
                            appState.isFloatingOverlayActive = true
                        }
                        Button("Ver análisis musical") {
                            showAnalyzerSheet = true
                        }
                        Button("Cerrar") {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)

                // Segmented Pill: [Original] [Español] [Ambos]
                HStack(spacing: 8) {
                    ForEach([LyricsDisplayMode.original, .translated, .both], id: \.self) { mode in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                playerVM.displayMode = mode
                            }
                        } label: {
                            Text(mode.rawValue)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(playerVM.displayMode == mode ? .black : .white.opacity(0.85))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(playerVM.displayMode == mode ? Color.white : Color.white.opacity(0.12))
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)

                // Central Synchronized Lyrics Area
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 28) {
                            Spacer(minLength: 20)

                            ForEach(Array(playerVM.track.lyricsLines.enumerated()), id: \.element.id) { index, line in
                                let isCurrent = index == playerVM.activeLineIndex
                                let isPast = line.endTime < playerVM.currentTime

                                VStack(alignment: .leading, spacing: 8) {
                                    // Original Words with Apple Music Progressive Fill
                                    if playerVM.displayMode != .translated {
                                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                                            ForEach(line.originalWords) { word in
                                                KaraokeWordView(
                                                    word: word,
                                                    currentTime: playerVM.currentTime,
                                                    style: .appleMusicProgressive,
                                                    fontSize: isCurrent ? 28 : 22,
                                                    fontWeight: isCurrent ? .bold : .semibold
                                                )
                                            }
                                        }
                                    }

                                    // Translated line underneath
                                    if playerVM.displayMode != .original {
                                        let activeTargetIdx = line.activeTranslatedWordIndex(at: playerVM.currentTime)

                                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                                            ForEach(Array(line.translatedWords.enumerated()), id: \.element.id) { tIndex, tWord in
                                                let isTargetActive = (tIndex == activeTargetIdx) && isCurrent
                                                Text(tWord.text)
                                                    .font(.system(size: isCurrent ? 18 : 15, weight: isTargetActive ? .bold : .medium, design: .rounded))
                                                    .foregroundColor(
                                                        isCurrent
                                                        ? (isTargetActive ? Color(red: 0.4, green: 0.75, blue: 1.0) : Color.white.opacity(0.9))
                                                        : (isPast ? Color.white.opacity(0.4) : Color.white.opacity(0.25))
                                                    )
                                                    .shadow(color: isTargetActive ? Color.blue.opacity(0.5) : .clear, radius: 4)
                                                    .animation(.easeInOut(duration: 0.12), value: isTargetActive)
                                            }
                                        }
                                    }
                                }
                                .id(index)
                                .opacity(isCurrent ? 1.0 : (isPast ? 0.45 : 0.25))
                                .blur(radius: isCurrent ? 0 : 0.3)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isCurrent)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    playerVM.seek(to: line.startTime)
                                }
                            }

                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, 24)
                    }
                    .onChange(of: playerVM.activeLineIndex) { newIndex in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }

                // Scrubber Progress Bar
                CustomScrubberView(
                    currentTime: $playerVM.currentTime,
                    duration: playerVM.track.duration
                ) { newTime in
                    playerVM.seek(to: newTime)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                // Playback Control Buttons
                HStack {
                    Button {
                        playerVM.isShuffle.toggle()
                    } label: {
                        Image(systemName: "shuffle")
                            .font(.system(size: 18))
                            .foregroundColor(playerVM.isShuffle ? .blue : .white.opacity(0.7))
                    }

                    Spacer()

                    Button {
                        playerVM.skip(seconds: -10)
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button {
                        playerVM.togglePlayPause()
                    } label: {
                        Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .frame(width: 68, height: 68)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Button {
                        playerVM.skip(seconds: 10)
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button {
                        playerVM.isRepeat.toggle()
                    } label: {
                        Image(systemName: "repeat")
                            .font(.system(size: 18))
                            .foregroundColor(playerVM.isRepeat ? .blue : .white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 16)

                // Bottom Docked Drawer Pill (Acordes e Instrumentos)
                Button {
                    showAnalyzerSheet = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))

                        HStack(spacing: 16) {
                            // Chords
                            HStack(spacing: 8) {
                                Image(systemName: "guitars.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Acordes:")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text(playerVM.track.chords.map(\.name).joined(separator: " · "))
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            }

                            Divider()
                                .background(Color.white.opacity(0.2))
                                .frame(height: 24)

                            // Instruments
                            HStack(spacing: 8) {
                                Image(systemName: "waveform")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Instrumentos:")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text(playerVM.track.instruments.prefix(3).map(\.name).joined(separator: " · "))
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(red: 0.12, green: 0.15, blue: 0.22).opacity(0.85))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
        .sheet(isPresented: $showAnalyzerSheet) {
            MusicAnalyzerView(track: playerVM.track)
        }
    }
}

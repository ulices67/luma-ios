import SwiftUI

/// Music Player and Synchronized Lyrics view matching Image 3 Screen 2 (Blinding Lights)
public struct MusicLyricsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var playerVM: PlayerViewModel
    @ObservedObject var appState: AppState = AppState.shared
    @State private var showAnalyzer: Bool = false

    public init(track: MediaTrack = SampleData.blindingLights) {
        _playerVM = StateObject(wrappedValue: PlayerViewModel(track: track))
    }

    public var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Album Banner & Actions
                ZStack(alignment: .top) {
                    // Album art banner with gradient overlay
                    ZStack {
                        LinearGradient(
                            colors: playerVM.track.gradientColors.map { Color(hex: $0) },
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        Image(systemName: "music.note")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                    // Top Bar items
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.black.opacity(0.35))
                                .clipShape(Circle())
                        }

                        Spacer()

                        Button {
                            // Add to playlist
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.black.opacity(0.35))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                    // Track title overlay at bottom of banner
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer()
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(playerVM.track.title)
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text(playerVM.track.artistOrCreator)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }

                            Spacer()

                            HStack(spacing: 12) {
                                Button {
                                    playerVM.isFavorite.toggle()
                                } label: {
                                    Image(systemName: playerVM.isFavorite ? "heart.fill" : "heart")
                                        .font(.system(size: 18))
                                        .foregroundColor(playerVM.isFavorite ? .red : .white)
                                }

                                Button {
                                    showAnalyzer = true
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                    .frame(height: 180)
                }
                .padding(.horizontal, 12)
                .padding(.top, 6)

                // Scrubber Bar
                CustomScrubberView(
                    currentTime: $playerVM.currentTime,
                    duration: playerVM.track.duration
                ) { newTime in
                    playerVM.seek(to: newTime)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Segmented Modes: [Original] [Español] [Ambos] [Acordes]
                HStack(spacing: 6) {
                    ForEach(LyricsDisplayMode.allCases, id: \.self) { mode in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
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
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)

                // Lyrics Content Area
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 22) {
                            ForEach(Array(playerVM.track.lyricsLines.enumerated()), id: \.element.id) { index, line in
                                let isCurrent = index == playerVM.activeLineIndex
                                let isPast = line.endTime < playerVM.currentTime

                                VStack(alignment: .leading, spacing: 6) {
                                    // Optional Inline Chord Badge
                                    if playerVM.displayMode == .chords, let chord = line.chord {
                                        Text(chord)
                                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.blue.opacity(0.12))
                                            .cornerRadius(6)
                                    }

                                    // Original Words with Word-Level Active Pill Highlight
                                    if playerVM.displayMode != .translated {
                                        let activeWordIdx = line.activeOriginalWordIndex(at: playerVM.currentTime)

                                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                                            ForEach(Array(line.originalWords.enumerated()), id: \.element.id) { wIdx, word in
                                                KaraokeWordView(
                                                    word: word,
                                                    currentTime: playerVM.currentTime,
                                                    style: isCurrent ? .pillBadge : .appleMusicProgressive,
                                                    fontSize: isCurrent ? 24 : 18,
                                                    fontWeight: isCurrent ? .bold : .semibold,
                                                    isAlignedHighlight: isCurrent && (wIdx == activeWordIdx)
                                                )
                                            }
                                        }
                                    }

                                    // Translated line with Aligned Active Word Highlight
                                    if playerVM.displayMode != .original {
                                        let activeTargetIdx = line.activeTranslatedWordIndex(at: playerVM.currentTime)

                                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                                            ForEach(Array(line.translatedWords.enumerated()), id: \.element.id) { tIdx, tWord in
                                                let isTargetActive = isCurrent && (tIdx == activeTargetIdx)

                                                Text(tWord.text)
                                                    .font(.system(size: isCurrent ? 17 : 14, weight: isTargetActive ? .bold : .regular, design: .rounded))
                                                    .foregroundColor(
                                                        isTargetActive
                                                        ? .blue
                                                        : (isCurrent ? Color.primary.opacity(0.9) : Color.secondary.opacity(0.6))
                                                    )
                                                    .padding(.horizontal, isTargetActive ? 4 : 0)
                                                    .padding(.vertical, isTargetActive ? 2 : 0)
                                                    .background(
                                                        Group {
                                                            if isTargetActive {
                                                                RoundedRectangle(cornerRadius: 4)
                                                                    .fill(Color.blue.opacity(0.15))
                                                            }
                                                        }
                                                    )
                                            }
                                        }
                                    }
                                }
                                .id(index)
                                .opacity(isCurrent ? 1.0 : (isPast ? 0.6 : 0.35))
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

                // Bottom Playback Controls
                HStack(spacing: 36) {
                    Button {
                        playerVM.skip(seconds: -10)
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.primary)
                    }

                    Button {
                        playerVM.togglePlayPause()
                    } label: {
                        Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                            .frame(width: 62, height: 62)
                            .background(Color.primary)
                            .clipShape(Circle())
                    }

                    Button {
                        playerVM.skip(seconds: 10)
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.primary)
                    }

                    Button {
                        showAnalyzer = true
                    } label: {
                        Image(systemName: "waveform.badge.magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .sheet(isPresented: $showAnalyzer) {
            MusicAnalyzerView(track: playerVM.track)
        }
    }
}

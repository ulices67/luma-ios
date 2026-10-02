import SwiftUI

public enum PodcastTab: String, CaseIterable {
    case transcript = "Transcripción"
    case summary = "Resumen"
    case notes = "Notas"
}

/// Podcast Player & Speaker Diarization View matching Image 3 Screen 4 (Lex Fridman Podcast)
public struct PodcastPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var playerVM: PlayerViewModel
    @State private var selectedTab: PodcastTab = .transcript

    public init(track: MediaTrack = SampleData.lexFridmanPodcast) {
        _playerVM = StateObject(wrappedValue: PlayerViewModel(track: track))
    }

    public var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with Host Avatar and Details
                HStack(spacing: 14) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    // Avatar
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.black, .gray], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(playerVM.track.title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                        Text(playerVM.track.artistOrCreator + " · 2 h 18 min")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button {
                        // Options
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Sub-tabs: [Transcripción] [Resumen] [Notas]
                HStack(spacing: 12) {
                    ForEach(PodcastTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Text(tab.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedTab == tab ? .blue : .secondary)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(
                                    Capsule()
                                        .fill(selectedTab == tab ? Color.blue.opacity(0.12) : Color.clear)
                                )
                        }
                    }
                }
                .padding(.top, 14)

                // Transcript Dialogue Stream
                if selectedTab == .transcript {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 22) {
                                ForEach(Array(playerVM.track.lyricsLines.enumerated()), id: \.element.id) { index, line in
                                    let isCurrent = index == playerVM.activeLineIndex

                                    HStack(alignment: .top, spacing: 12) {
                                        // Timestamp
                                        Text(playerVM.formatTime(line.startTime))
                                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                                            .foregroundColor(.secondary.opacity(0.7))
                                            .frame(width: 44, alignment: .leading)

                                        // Speaker Avatar
                                        Circle()
                                            .fill(line.speaker == "Invitado" ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Image(systemName: line.speakerAvatar ?? "person.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.primary)
                                            )

                                        // Speaker Name & Bilingual Text
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(line.speaker ?? "Hablante")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(isCurrent ? .blue : .primary)

                                            // Original English
                                            Text(line.originalText)
                                                .font(.system(size: 15, weight: isCurrent ? .semibold : .regular))
                                                .foregroundColor(isCurrent ? .primary : .primary.opacity(0.75))

                                            // Spanish Translation
                                            Text(line.translatedText)
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(isCurrent ? Color.blue : .secondary)
                                        }
                                    }
                                    .id(index)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(isCurrent ? Color.blue.opacity(0.06) : Color.clear)
                                    )
                                    .onTapGesture {
                                        playerVM.seek(to: line.startTime)
                                    }
                                }
                                Spacer(minLength: 40)
                            }
                            .padding(.top, 14)
                        }
                        .onChange(of: playerVM.activeLineIndex) { newIndex in
                            withAnimation {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }
                } else if selectedTab == .summary {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Resumen de IA")
                            .font(.system(size: 18, weight: .bold))
                        Text("Conversación profunda sobre la aceleración de modelos neuronales, el futuro del trabajo y el impacto en el aprendizaje humano en la próxima década.")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notas del episodio")
                            .font(.system(size: 18, weight: .bold))
                        Text("• 00:00 - Introducción\n• 12:14 - Modelos generativos\n• 45:30 - Robótica autónoma")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding()
                }

                // Audio Scrubber Bar
                VStack(spacing: 6) {
                    CustomScrubberView(
                        currentTime: $playerVM.currentTime,
                        duration: playerVM.track.duration
                    ) { newTime in
                        playerVM.seek(to: newTime)
                    }
                    .padding(.horizontal, 20)

                    // Controls (1x, -15s, Play/Pause, +15s)
                    HStack(spacing: 34) {
                        Button {
                            if playerVM.playbackRate == 1.0 {
                                playerVM.playbackRate = 1.25
                            } else if playerVM.playbackRate == 1.25 {
                                playerVM.playbackRate = 1.5
                            } else if playerVM.playbackRate == 1.5 {
                                playerVM.playbackRate = 2.0
                            } else {
                                playerVM.playbackRate = 1.0
                            }
                        } label: {
                            Text(String(format: "%.1fx", playerVM.playbackRate).replacingOccurrences(of: ".0", with: ""))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .frame(width: 40)
                        }

                        Button {
                            playerVM.skip(seconds: -15)
                        } label: {
                            Image(systemName: "gobackward.15")
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
                    }
                    .padding(.vertical, 8)
                }
                .background(Color(.secondarySystemBackground))
            }
        }
    }
}

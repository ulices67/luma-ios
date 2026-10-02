import SwiftUI

/// Floating Picture-in-Picture style translation widget matching Image 2 & Image 3 Screen 7
public struct FloatingPipCapsuleView: View {
    @ObservedObject var appState: AppState = AppState.shared
    @ObservedObject var playerVM: PlayerViewModel
    @State private var dragOffset: CGSize = .zero
    @State private var accumulatedOffset: CGSize = .zero
    @State private var isExpanded: Bool = false

    public init(playerVM: PlayerViewModel) {
        self.playerVM = playerVM
    }

    private var activeLine: TimedLine? {
        if playerVM.track.lyricsLines.indices.contains(playerVM.activeLineIndex) {
            return playerVM.track.lyricsLines[playerVM.activeLineIndex]
        }
        return playerVM.track.lyricsLines.first
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "translate")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 1.0))

                Text("Traducción en vivo")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "ellipsis.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.6))
                }

                Button {
                    withAnimation {
                        appState.isFloatingOverlayActive = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            // Expanded Mode Segmented Switcher
            if isExpanded {
                HStack(spacing: 6) {
                    ForEach([LyricsDisplayMode.original, .translated, .both], id: \.self) { mode in
                        Button {
                            playerVM.displayMode = mode
                        } label: {
                            Text(mode.rawValue)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(playerVM.displayMode == mode ? .black : .white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(playerVM.displayMode == mode ? Color.white : Color.white.opacity(0.15))
                                )
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            // Subtitle Line Content
            if let line = activeLine {
                VStack(alignment: .leading, spacing: 6) {
                    // Original Words with Word-Level Active Pill Highlight
                    if playerVM.displayMode != .translated {
                        let activeWordIdx = line.activeOriginalWordIndex(at: playerVM.currentTime)

                        HStack(spacing: 4) {
                            ForEach(Array(line.originalWords.enumerated()), id: \.element.id) { index, word in
                                KaraokeWordView(
                                    word: word,
                                    currentTime: playerVM.currentTime,
                                    style: .pillBadge,
                                    fontSize: 15,
                                    fontWeight: .bold,
                                    isAlignedHighlight: index == activeWordIdx
                                )
                            }
                        }
                    }

                    // Translated Line with Aligned Word Highlight
                    if playerVM.displayMode != .original {
                        let activeTargetIdx = line.activeTranslatedWordIndex(at: playerVM.currentTime)

                        HStack(spacing: 4) {
                            ForEach(Array(line.translatedWords.enumerated()), id: \.element.id) { index, word in
                                Text(word.text)
                                    .font(.system(size: 14, weight: index == activeTargetIdx ? .bold : .regular, design: .rounded))
                                    .foregroundColor(index == activeTargetIdx ? Color(red: 0.35, green: 0.7, blue: 1.0) : .white.opacity(0.75))
                                    .scaleEffect(index == activeTargetIdx ? 1.05 : 1.0)
                                    .animation(.easeInOut(duration: 0.1), value: activeTargetIdx)
                            }
                        }
                    }
                }
            }

            // Expanded Quick Control Pills
            if isExpanded {
                Divider().background(Color.white.opacity(0.2))

                HStack(spacing: 12) {
                    quickButton(icon: "pip.enter", label: "PiP Sistema") {
                        appState.toggleSystemPiP()
                    }
                    quickButton(icon: "textformat.size", label: "Tamaño")
                    quickButton(icon: "rectangle.portrait", label: "Posición")
                    quickButton(icon: playerVM.isPlaying ? "pause.fill" : "play.fill", label: playerVM.isPlaying ? "Pausa" : "Play") {
                        playerVM.togglePlayPause()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
        }
        .padding(14)
        .frame(maxWidth: 340)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.12, green: 0.14, blue: 0.18).opacity(0.92))
                .shadow(color: Color.black.opacity(0.5), radius: 16, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
        .offset(x: accumulatedOffset.width + dragOffset.width, y: accumulatedOffset.height + dragOffset.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    accumulatedOffset.width += value.translation.width
                    accumulatedOffset.height += value.translation.height
                    dragOffset = .zero
                }
        )
    }

    private func quickButton(icon: String, label: String, action: (() -> Void)? = nil) -> some View {
        Button {
            action?()
        } label: {
            VStack(spacing: 3) {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .buttonStyle(.plain)
    }
}

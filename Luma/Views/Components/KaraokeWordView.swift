import SwiftUI

public enum WordHighlightStyle {
    case appleMusicProgressive // Smooth mask fill
    case pillBadge            // Blue rounded badge pill (as seen in floating/video subtitles)
}

/// Renders a single word with real-time karaoke synchronization and progressive fill
public struct KaraokeWordView: View {
    public let word: TimedWord
    public let currentTime: Double
    public let style: WordHighlightStyle
    public let fontSize: CGFloat
    public let fontWeight: Font.Weight
    public let isAlignedHighlight: Bool

    public init(
        word: TimedWord,
        currentTime: Double,
        style: WordHighlightStyle = .appleMusicProgressive,
        fontSize: CGFloat = 26,
        fontWeight: Font.Weight = .bold,
        isAlignedHighlight: Bool = false
    ) {
        self.word = word
        self.currentTime = currentTime
        self.style = style
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.isAlignedHighlight = isAlignedHighlight
    }

    private var progress: Double {
        word.progress(at: currentTime)
    }

    private var isActive: Bool {
        word.isActive(at: currentTime) || isAlignedHighlight
    }

    private var isPast: Bool {
        word.isPast(at: currentTime)
    }

    public var body: some View {
        switch style {
        case .appleMusicProgressive:
            progressiveFillView
        case .pillBadge:
            pillBadgeView
        }
    }

    // MARK: - Apple Music Progressive Letter Fill
    private var progressiveFillView: some View {
        ZStack(alignment: .leading) {
            // Inactive / Base dimmed layer
            Text(word.text)
                .font(.system(size: fontSize, weight: fontWeight, design: .rounded))
                .foregroundColor(.white.opacity(isPast ? 0.75 : 0.35))

            // Active smooth filling mask
            if isActive || isPast {
                GeometryReader { geo in
                    Text(word.text)
                        .font(.system(size: fontSize, weight: fontWeight, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(isActive ? 0.6 : 0.0), radius: 6, x: 0, y: 0)
                        .mask(
                            HStack(spacing: 0) {
                                Rectangle()
                                    .frame(width: geo.size.width * CGFloat(isPast ? 1.0 : progress))
                                Spacer(minLength: 0)
                            }
                        )
                }
            }
        }
        .fixedSize()
        .scaleEffect(isActive ? 1.04 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: isActive)
    }

    // MARK: - Pill Badge Highlight (Used in Video & Floating Subtitles)
    private var pillBadgeView: some View {
        Text(word.text)
            .font(.system(size: fontSize, weight: isActive ? .bold : .medium, design: .rounded))
            .foregroundColor(isActive ? .white : .white.opacity(isPast ? 0.85 : 0.45))
            .padding(.horizontal, isActive ? 6 : 2)
            .padding(.vertical, isActive ? 3 : 0)
            .background(
                Group {
                    if isActive {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color(red: 0.16, green: 0.48, blue: 0.95))
                            .shadow(color: Color(red: 0.16, green: 0.48, blue: 0.95).opacity(0.5), radius: 4, x: 0, y: 2)
                    }
                }
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isActive)
    }
}

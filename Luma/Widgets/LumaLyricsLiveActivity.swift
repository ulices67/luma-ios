import WidgetKit
import SwiftUI
#if canImport(ActivityKit)
import ActivityKit
#endif

public struct LumaLyricsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var trackTitle: String
        public var artistName: String
        public var originalLyricLine: String
        public var translatedLyricLine: String
        public var activeWord: String
        public var activeChord: String
        public var currentTimestamp: Double

        public init(
            trackTitle: String,
            artistName: String,
            originalLyricLine: String,
            translatedLyricLine: String,
            activeWord: String,
            activeChord: String = "Bm",
            currentTimestamp: Double = 0.0
        ) {
            self.trackTitle = trackTitle
            self.artistName = artistName
            self.originalLyricLine = originalLyricLine
            self.translatedLyricLine = translatedLyricLine
            self.activeWord = activeWord
            self.activeChord = activeChord
            self.currentTimestamp = currentTimestamp
        }
    }

    public var sessionId: String

    public init(sessionId: String = UUID().uuidString) {
        self.sessionId = sessionId
    }
}

/// Live Activity displaying real-time original lyrics & translation in Dynamic Island and Lock Screen
public struct LumaLyricsLiveActivity: Widget {
    public init() {}

    public var body: some WidgetConfiguration {
        ActivityConfiguration(for: LumaLyricsAttributes.self) { context in
            // Lock Screen / StandBy Banner
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    LumaLogoView(size: 20)
                    Text(context.state.trackTitle)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("• \(context.state.artistName)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(context.state.activeChord)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(6)
                }

                // Original Lyric Line
                Text(context.state.originalLyricLine)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Live Spanish Subtitle
                Text(context.state.translatedLyricLine)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.4, green: 0.75, blue: 1.0))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(red: 0.09, green: 0.11, blue: 0.15))
            )
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        LumaLogoView(size: 24)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(context.state.trackTitle)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text(context.state.artistName)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .padding(.leading, 4)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.activeChord)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(6)
                        .padding(.trailing, 4)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        // Original
                        Text(context.state.originalLyricLine)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(2)

                        // Subtitle
                        Text(context.state.translatedLyricLine)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.35, green: 0.7, blue: 1.0))
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                }
            } compactLeading: {
                LumaLogoView(size: 16)
            } compactTrailing: {
                Text(context.state.activeChord)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
            } minimal: {
                LumaLogoView(size: 14)
            }
        }
    }
}

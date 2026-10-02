import WidgetKit
import SwiftUI

public struct LumaWidgetEntry: TimelineEntry {
    public let date: Date
    public let trackTitle: String
    public let artistName: String
    public let originalLyricLine: String
    public let translatedLyricLine: String
    public let activeChord: String
}

public struct LumaTimelineProvider: TimelineProvider {
    public func placeholder(in context: Context) -> LumaWidgetEntry {
        LumaWidgetEntry(
            date: Date(),
            trackTitle: "Midnight Echo",
            artistName: "Luna Rivera",
            originalLyricLine: "I hear your voice across the dark",
            translatedLyricLine: "Escucho tu voz entre la oscuridad",
            activeChord: "Bm"
        )
    }

    public func getSnapshot(in context: Context, completion: @escaping (LumaWidgetEntry) -> Void) {
        let entry = LumaWidgetEntry(
            date: Date(),
            trackTitle: "Midnight Echo",
            artistName: "Luna Rivera",
            originalLyricLine: "I hear your voice across the dark",
            translatedLyricLine: "Escucho tu voz entre la oscuridad",
            activeChord: "Bm"
        )
        completion(entry)
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<LumaWidgetEntry>) -> Void) {
        let entry = LumaWidgetEntry(
            date: Date(),
            trackTitle: "Blinding Lights",
            artistName: "The Weeknd",
            originalLyricLine: "I've been tryna call",
            translatedLyricLine: "He estado intentando llamar",
            activeChord: "Ab"
        )
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

public struct LumaHomeWidget: Widget {
    public static let kind: String = "LumaHomeWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: LumaTimelineProvider()) { entry in
            LumaWidgetEntryView(entry: entry)
                .containerBackground(Color(red: 0.08, green: 0.10, blue: 0.14), for: .widget)
        }
        .configurationDisplayName("Luma Subtítulos")
        .description("Muestra en tiempo real la canción que suena con su letra original y traducción.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

public struct LumaWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    public var entry: LumaWidgetEntry

    public var body: some View {
        switch family {
        case .systemSmall:
            smallView
        default:
            mediumView
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                LumaLogoView(size: 24)
                Spacer()
                Text(entry.activeChord)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
            }
            Spacer()
            Text(entry.trackTitle)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            Text(entry.translatedLyricLine)
                .font(.system(size: 11))
                .foregroundColor(Color(red: 0.4, green: 0.75, blue: 1.0))
                .lineLimit(2)
        }
        .padding(4)
    }

    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                LumaLogoView(size: 24)
                VStack(alignment: .leading, spacing: 1) {
                    Text(entry.trackTitle)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text(entry.artistName)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Text("ACORDE: \(entry.activeChord)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(6)
            }

            Divider().background(Color.white.opacity(0.15))

            // Original Line
            Text(entry.originalLyricLine)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)

            // Translated Subtitle
            Text(entry.translatedLyricLine)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.75, blue: 1.0))
                .lineLimit(1)
        }
        .padding(4)
    }
}

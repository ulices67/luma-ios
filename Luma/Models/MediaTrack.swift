import Foundation

public enum MediaType: String, Codable, CaseIterable {
    case music = "Música"
    case video = "Video"
    case podcast = "Podcast"
    case file = "Archivo"

    public var systemIcon: String {
        switch self {
        case .music: return "music.note"
        case .video: return "play.rectangle.fill"
        case .podcast: return "mic.fill"
        case .file: return "folder.fill"
        }
    }
}

/// Represents a multimedia track (song, video clip, movie scene, or podcast interview) with full sync data.
public struct MediaTrack: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public let title: String
    public let artistOrCreator: String
    public let albumOrShow: String
    public let year: String
    public let duration: Double
    public let mediaType: MediaType
    public var lyricsLines: [TimedLine]
    public let keySignature: String
    public let bpm: Int
    public let timeSignature: String
    public var chords: [ChordData]
    public var instruments: [InstrumentData]
    public let isOfficialLyrics: Bool
    public let aiConfidence: Double
    public let relativeTimeString: String
    public let gradientColors: [String]
    public let isFavorite: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        artistOrCreator: String,
        albumOrShow: String = "",
        year: String = "2024",
        duration: Double = 200.0,
        mediaType: MediaType = .music,
        lyricsLines: [TimedLine] = [],
        keySignature: String = "C Major",
        bpm: Int = 120,
        timeSignature: String = "4/4",
        chords: [ChordData] = [],
        instruments: [InstrumentData] = [],
        isOfficialLyrics: Bool = true,
        aiConfidence: Double = 0.95,
        relativeTimeString: String = "Hace un momento",
        gradientColors: [String] = ["#1A102F", "#3B1B4F", "#0A0B1A"],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.artistOrCreator = artistOrCreator
        self.albumOrShow = albumOrShow
        self.year = year
        self.duration = duration
        self.mediaType = mediaType
        self.lyricsLines = lyricsLines
        self.keySignature = keySignature
        self.bpm = bpm
        self.timeSignature = timeSignature
        self.chords = chords
        self.instruments = instruments
        self.isOfficialLyrics = isOfficialLyrics
        self.aiConfidence = aiConfidence
        self.relativeTimeString = relativeTimeString
        self.gradientColors = gradientColors
        self.isFavorite = isFavorite
    }
}

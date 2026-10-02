import Foundation
import CoreMedia
import AVFAudio
import Combine
#if canImport(ShazamKit)
import ShazamKit
#endif

/// Result emitted when ShazamKit identifies a song and matched playback timecode
public struct MusicMatchEvent: Identifiable, Equatable {
    public let id = UUID()
    public let song: String
    public let artist: String
    public let matchedPosition: TimeInterval
    public let confidence: Double
    public let genres: [String]

    public init(
        song: String,
        artist: String,
        matchedPosition: TimeInterval,
        confidence: Double = 0.98,
        genres: [String] = []
    ) {
        self.song = song
        self.artist = artist
        self.matchedPosition = matchedPosition
        self.confidence = confidence
        self.genres = genres
    }
}

/// MusicRecognitionEngine managing online ShazamKit signature matching and SHCustomCatalog offline catalog
public final class MusicRecognitionEngine: NSObject, ObservableObject {
    public static let shared = MusicRecognitionEngine()

    @Published public var isRecognizing: Bool = false
    @Published public var lastMatch: MusicMatchEvent?
    @Published public var recognitionError: String?

    #if canImport(ShazamKit)
    private var session: SHSession?
    private var customCatalog: SHCustomCatalog?
    #endif

    public var onMatchFound: ((MusicMatchEvent) -> Void)?

    override private init() {
        super.init()
        #if canImport(ShazamKit)
        self.session = SHSession()
        self.session?.delegate = self
        self.customCatalog = SHCustomCatalog()
        #endif
    }

    /// Feeds PCM buffer from AudioRouter.musicBuffer to ShazamKit
    public func matchBuffer(_ buffer: AVAudioPCMBuffer, at time: AVAudioTime) {
        #if canImport(ShazamKit)
        self.session?.matchStreamingBuffer(buffer, at: time)
        #endif
    }

    public func loadCustomOfflineCatalog(url: URL) throws {
        #if canImport(ShazamKit)
        let catalog = SHCustomCatalog()
        try catalog.add(from: url)
        self.customCatalog = catalog
        self.session = SHSession(catalog: catalog)
        self.session?.delegate = self
        #endif
    }
}

#if canImport(ShazamKit)
extension MusicRecognitionEngine: SHSessionDelegate {
    public func session(_ session: SHSession, didFind match: SHMatch) {
        guard let item = match.mediaItems.first else { return }
        let song = item.title ?? "Canción desconocida"
        let artist = item.artist ?? "Artista desconocido"
        let position = item.predictedCurrentMatchOffset

        let event = MusicMatchEvent(
            song: song,
            artist: artist,
            matchedPosition: position,
            confidence: 0.98,
            genres: item.genres
        )

        DispatchQueue.main.async {
            self.lastMatch = event
            self.onMatchFound?(event)
        }
    }

    public func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        DispatchQueue.main.async {
            self.recognitionError = error?.localizedDescription
        }
    }
}
#endif

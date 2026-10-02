import Foundation

/// Decoupled protocol for lyric providers (LRCLIB, licensed catalog, local cache)
public protocol LyricsProvider {
    func fetchLyrics(songTitle: String, artistName: String, duration: Double?) async throws -> [TimedLine]
}

/// LyricsEngine fetching, caching, and serving synchronized lyrics lines
public final class LyricsEngine: ObservableObject {
    public static let shared = LyricsEngine()

    @Published public var currentLyrics: [TimedLine] = []
    @Published public var isLoading: Bool = false
    @Published public var lyricsError: String?

    private var cache: [String: [TimedLine]] = [:]
    private let primaryProvider: LyricsProvider

    public init(provider: LyricsProvider = LRCLIBLyricsProvider()) {
        self.primaryProvider = provider
    }

    /// Fetches lyrics for identified track and returns synchronized lines
    public func getLyrics(for songTitle: String, artistName: String, duration: Double? = nil) async -> [TimedLine] {
        let cacheKey = "\(songTitle.lowercased())_\(artistName.lowercased())"
        if let cached = cache[cacheKey] {
            await MainActor.run {
                self.currentLyrics = cached
            }
            return cached
        }

        await MainActor.run {
            self.isLoading = true
            self.lyricsError = nil
        }

        defer {
            Task { @MainActor in
                self.isLoading = false
            }
        }

        do {
            let lines = try await primaryProvider.fetchLyrics(songTitle: songTitle, artistName: artistName, duration: duration)
            self.cache[cacheKey] = lines
            await MainActor.run {
                self.currentLyrics = lines
            }
            return lines
        } catch {
            await MainActor.run {
                self.lyricsError = error.localizedDescription
                // Fallback to sample lines
                self.currentLyrics = SampleData.blindingLights.lyricsLines
            }
            return SampleData.blindingLights.lyricsLines
        }
    }
}

/// LRCLIB implementation of LyricsProvider
public struct LRCLIBLyricsProvider: LyricsProvider {
    public init() {}

    public func fetchLyrics(songTitle: String, artistName: String, duration: Double?) async throws -> [TimedLine] {
        if let lines = await RealLyricsService.shared.fetchSyncedLyrics(trackName: songTitle, artistName: artistName, duration: duration), !lines.isEmpty {
            return lines
        }
        throw NSError(domain: "LyricsEngine", code: 404, userInfo: [NSLocalizedDescriptionKey: "Letra sincronizada no encontrada"])
    }
}

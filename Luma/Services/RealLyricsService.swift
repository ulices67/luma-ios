import Foundation

/// Real LRC-format lyrics fetcher and parser using the open LRCLIB database (used by open Spotify & Apple Music clients)
public final class RealLyricsService {
    public static let shared = RealLyricsService()

    private let session = URLSession.shared

    private init() {}

    /// Fetches real synchronized lyrics from LRCLIB API
    public func fetchSyncedLyrics(trackName: String, artistName: String, duration: Double? = nil) async -> [TimedLine]? {
        guard let encodedTrack = trackName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedArtist = artistName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }

        var urlString = "https://lrclib.net/api/get?track_name=\(encodedTrack)&artist_name=\(encodedArtist)"
        if let dur = duration, dur > 0 {
            urlString += "&duration=\(Int(dur))"
        }

        guard let url = URL(string: urlString) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("LumaMusicTranslator/1.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return await searchFallback(trackName: trackName, artistName: artistName)
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let syncedLyrics = json["syncedLyrics"] as? String, !syncedLyrics.isEmpty {
                return parseLRC(syncedLyrics)
            }
        } catch {
            print("Error fetching real lyrics: \(error.localizedDescription)")
        }

        return await searchFallback(trackName: trackName, artistName: artistName)
    }

    private func searchFallback(trackName: String, artistName: String) async -> [TimedLine]? {
        guard let query = "\(trackName) \(artistName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://lrclib.net/api/search?q=\(query)") else {
            return nil
        }

        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return nil }
            if let results = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let firstSynced = results.first(where: { ($0["syncedLyrics"] as? String)?.isEmpty == false }),
               let syncedLrc = firstSynced["syncedLyrics"] as? String {
                return parseLRC(syncedLrc)
            }
        } catch {
            print("Search fallback error: \(error)")
        }

        return nil
    }

    /// Parses standard LRC timed string: [01:23.45] lyric line text
    public func parseLRC(_ lrcContent: String) -> [TimedLine] {
        var lines: [TimedLine] = []
        let rawLines = lrcContent.components(separatedBy: .newlines)

        var parsedEntries: [(time: Double, text: String)] = []

        // Regex for [mm:ss.xx]
        let pattern = "\\[(\\d{2}):(\\d{2})\\.(\\d{2,3})\\](.*)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }

        for rawLine in rawLines {
            let nsString = rawLine as NSString
            let matches = regex.matches(in: rawLine, range: NSRange(location: 0, length: nsString.length))

            for match in matches where match.numberOfRanges >= 5 {
                let minStr = nsString.substring(with: match.range(at: 1))
                let secStr = nsString.substring(with: match.range(at: 2))
                let msStr = nsString.substring(with: match.range(at: 3))
                let text = nsString.substring(with: match.range(at: 4)).trimmingCharacters(in: .whitespaces)

                if let mins = Double(minStr), let secs = Double(secStr), let ms = Double(msStr) {
                    let totalSecs = (mins * 60.0) + secs + (ms / (msStr.count == 3 ? 1000.0 : 100.0))
                    if !text.isEmpty {
                        parsedEntries.append((totalSecs, text))
                    }
                }
            }
        }

        parsedEntries.sort { $0.time < $1.time }

        for i in 0..<parsedEntries.count {
            let current = parsedEntries[i]
            let nextTime = (i + 1 < parsedEntries.count) ? parsedEntries[i + 1].time : (current.time + 4.5)
            let duration = max(1.5, nextTime - current.time)

            // Segment words
            let words = current.text.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            var timedWords: [TimedWord] = []

            let wordDuration = duration / Double(max(1, words.count))
            for (wIdx, wText) in words.enumerated() {
                let wStart = current.time + (Double(wIdx) * wordDuration)
                let wEnd = wStart + (wordDuration * 0.95)
                timedWords.append(
                    TimedWord(
                        text: wText,
                        startTime: wStart,
                        endTime: wEnd,
                        alignedTargetIndex: wIdx
                    )
                )
            }

            lines.append(
                TimedLine(
                    startTime: current.time,
                    endTime: nextTime,
                    originalText: current.text,
                    translatedText: current.text, // Translated in real-time by RealTranslationService
                    originalWords: timedWords,
                    translatedWords: timedWords
                )
            )
        }

        return lines
    }
}

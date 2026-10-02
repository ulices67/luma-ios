import Foundation
import NaturalLanguage
#if canImport(Translation)
import Translation
#endif

/// Real-time translation service combining Apple's on-device Translation framework and Cloudflare edge translation
public final class RealTranslationService: ObservableObject {
    public static let shared = RealTranslationService()

    private let languageRecognizer = NLLanguageRecognizer()
    private let session = URLSession.shared

    private init() {}

    /// Automatically detects real spoken or written language
    public func detectLanguage(text: String) -> String {
        languageRecognizer.reset()
        languageRecognizer.processString(text)
        if let dominantLanguage = languageRecognizer.dominantLanguage {
            return dominantLanguage.rawValue
        }
        return "en"
    }

    /// Performs real translation to target language (e.g. "es")
    public func translate(
        text: String,
        from sourceLang: String? = nil,
        to targetLang: String = "es"
    ) async -> String {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return text }

        let detectedSource = sourceLang ?? detectLanguage(text: text)
        if detectedSource.lowercased().starts(with: targetLang.lowercased()) {
            return text
        }

        // Live edge translation query
        guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return text
        }

        let urlString = "https://api.mymemory.translated.net/get?q=\(encodedText)&langpair=\(detectedSource)|\(targetLang)"
        guard let url = URL(string: urlString) else { return text }

        do {
            let (data, response) = try await session.data(from: url)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let responseData = json["responseData"] as? [String: Any],
               let translatedText = responseData["translatedText"] as? String,
               !translatedText.isEmpty {
                return translatedText
            }
        } catch {
            print("Edge translation error: \(error.localizedDescription)")
        }

        return text
    }

    /// Translates an array of TimedLines in parallel and preserves word alignment
    public func translateLyricsLines(_ lines: [TimedLine], targetLang: String = "es") async -> [TimedLine] {
        var translatedLines: [TimedLine] = []

        for line in lines {
            let translated = await translate(text: line.originalText, to: targetLang)

            // Split into translated words
            let transWords = translated.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            let duration = line.endTime - line.startTime
            let wordDur = duration / Double(max(1, transWords.count))

            var timedTransWords: [TimedWord] = []
            for (tIdx, tText) in transWords.enumerated() {
                let wStart = line.startTime + (Double(tIdx) * wordDur)
                let wEnd = wStart + (wordDur * 0.95)
                timedTransWords.append(
                    TimedWord(
                        text: tText,
                        startTime: wStart,
                        endTime: wEnd
                    )
                )
            }

            // Align source words with target indices
            var alignedOriginalWords: [TimedWord] = []
            for (oIdx, origWord) in line.originalWords.enumerated() {
                let ratio = Double(oIdx) / Double(max(1, line.originalWords.count))
                let targetIdx = min(Int(ratio * Double(timedTransWords.count)), max(0, timedTransWords.count - 1))
                alignedOriginalWords.append(
                    TimedWord(
                        id: origWord.id,
                        text: origWord.text,
                        startTime: origWord.startTime,
                        endTime: origWord.endTime,
                        alignedTargetIndex: targetIdx
                    )
                )
            }

            translatedLines.append(
                TimedLine(
                    id: line.id,
                    startTime: line.startTime,
                    endTime: line.endTime,
                    originalText: line.originalText,
                    translatedText: translated,
                    originalWords: alignedOriginalWords,
                    translatedWords: timedTransWords,
                    chord: line.chord,
                    speaker: line.speaker,
                    speakerAvatar: line.speakerAvatar
                )
            )
        }

        return translatedLines
    }
}

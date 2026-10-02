import Foundation
import Combine
import CoreMedia

/// Master Orchestrator Actor coordinating decoupled capture, routing, speech, translation, music, and subtitles
public actor MediaEngine {
    public static let shared = MediaEngine()

    public let capture = CaptureEngine.shared
    public let router = AudioRouter.shared
    public let detector = ContentDetector.shared
    public let speech = SpeechEngine.shared
    public let translation = TranslationEngine.shared
    public let alignment = WordAlignmentEngine.shared
    public let musicRecognition = MusicRecognitionEngine.shared
    public let lyrics = LyricsEngine.shared
    public let chords = ChordEngine.shared
    public let rhythm = RhythmEngine.shared
    public let instruments = InstrumentEngine.shared
    public let pitch = PitchEngine.shared
    public let subtitles = SubtitleEngine.shared
    public let pip = PiPSubtitleController.shared

    private var isRunning: Bool = false
    private var speechCancellable: AnyCancellable?
    private var musicCancellable: AnyCancellable?

    private init() {
        Task {
            await bindEngines()
        }
    }

    /// Connects outputs from Speech and Music into Translation, Alignment, and Subtitle Engine
    private func bindEngines() {
        // 1. Speech Transcription pipeline
        speech.onTranscriptionUpdate = { [weak self] event in
            guard let self = self else { return }
            Task {
                await self.handleSpeechTranscription(event)
            }
        }

        // 2. Music Match pipeline
        musicRecognition.onMatchFound = { [weak self] match in
            guard let self = self else { return }
            Task {
                await self.handleMusicMatch(match)
            }
        }
    }

    /// Handles real-time speech event: translates text and feeds SubtitleEngine
    private func handleSpeechTranscription(_ event: SpeechTranscriptionEvent) async {
        do {
            let translated = try await translation.translate(event.text, from: "en", to: "es")

            // Split into translated tokens
            let transWords = translated.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            let duration = (event.words.last?.endTime ?? 2.0) - (event.words.first?.startTime ?? 0.0)
            let wordDur = duration / Double(max(1, transWords.count))

            var timedTransWords: [TimedWord] = []
            let baseStart = event.words.first?.startTime ?? 0.0
            for (idx, wText) in transWords.enumerated() {
                let s = baseStart + (Double(idx) * wordDur)
                let e = s + (wordDur * 0.95)
                timedTransWords.append(TimedWord(text: wText, startTime: s, endTime: e))
            }

            // Word alignment
            _ = alignment.align(sourceWords: event.words, translatedWords: timedTransWords)

            let cue = SubtitleCue(
                source: event.text,
                translation: translated,
                words: event.words,
                start: event.words.first?.startTime ?? 0.0,
                end: event.words.last?.endTime ?? 3.0
            )

            await MainActor.run {
                self.subtitles.appendCue(cue)
                if !self.subtitles.isRunning {
                    self.subtitles.start()
                }
            }
        } catch {
            print("MediaEngine translation error: \(error)")
        }
    }

    /// Handles music match from ShazamKit: retrieves lyrics, chords, and seeks SubtitleEngine to exact point
    private func handleMusicMatch(_ match: MusicMatchEvent) async {
        let lines = await lyrics.getLyrics(for: match.song, artistName: match.artist)

        let cues: [SubtitleCue] = lines.map { line in
            SubtitleCue(
                source: line.originalText,
                translation: line.translatedText,
                words: line.originalWords,
                start: line.startTime,
                end: line.endTime
            )
        }

        await MainActor.run {
            self.subtitles.setCues(cues)
            // Immediately jump to Shazam timecode
            self.subtitles.seek(to: match.matchedPosition)
            if !self.subtitles.isRunning {
                self.subtitles.start(startOffset: match.matchedPosition)
            }
        }
    }

    /// Starts system audio capture and launches processing pipelines
    public func start(useMicrophone: Bool = false) async throws {
        guard !isRunning else { return }
        isRunning = true

        if useMicrophone {
            try await MainActor.run {
                try self.capture.startMicrophoneCapture()
            }
        }

        try await MainActor.run {
            try self.speech.start()
        }
    }

    /// Stops all audio capture, speech, and subtitle rendering
    public func stop() async {
        isRunning = false
        await MainActor.run {
            self.capture.stop()
            self.speech.stop()
            self.subtitles.stop()
            self.pip.stopPiP()
        }
        await router.clearBuffers()
    }
}

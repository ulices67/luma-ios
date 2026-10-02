import Foundation
import Speech
import AVFAudio
import Combine

/// Output event from SpeechEngine containing real transcribed segments with word-level timestamps
public struct SpeechTranscriptionEvent {
    public let text: String
    public let words: [TimedWord]
    public let isFinal: Bool
    public let localeIdentifier: String

    public init(text: String, words: [TimedWord], isFinal: Bool = false, localeIdentifier: String = "en-US") {
        self.text = text
        self.words = words
        self.isFinal = isFinal
        self.localeIdentifier = localeIdentifier
    }
}

/// Independent Speech Engine consuming 16kHz mono audio from AudioRouter.speechBuffer
public final class SpeechEngine: ObservableObject {
    public static let shared = SpeechEngine()

    @Published public var isRunning: Bool = false
    @Published public var currentLocale: String = "en-US"
    @Published public var latestTranscription: SpeechTranscriptionEvent?

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var processingTimer: AnyCancellable?

    public var onTranscriptionUpdate: ((SpeechTranscriptionEvent) -> Void)?

    private init() {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: currentLocale))
    }

    public func setLocale(_ localeIdentifier: String) {
        self.currentLocale = localeIdentifier
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
    }

    /// Starts streaming speech transcription
    public func start() throws {
        stop()

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            throw NSError(domain: "SpeechEngine", code: -1, userInfo: [NSLocalizedDescriptionKey: "Reconocedor de voz no disponible"])
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        self.recognitionRequest = request
        request.shouldReportPartialResults = true

        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }

        self.isRunning = true

        // Launch recognition task
        self.recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                let transcription = result.bestTranscription

                // Extract exact real word timestamps from Apple's neural segments
                let words: [TimedWord] = transcription.segments.map { segment in
                    TimedWord(
                        text: segment.substring,
                        startTime: segment.timestamp,
                        endTime: segment.timestamp + segment.duration
                    )
                }

                let event = SpeechTranscriptionEvent(
                    text: transcription.formattedString,
                    words: words,
                    isFinal: result.isFinal,
                    localeIdentifier: self.currentLocale
                )

                DispatchQueue.main.async {
                    self.latestTranscription = event
                    self.onTranscriptionUpdate?(event)
                }
            }

            if error != nil || result?.isFinal == true {
                self.stop()
            }
        }

        // Pump 16kHz audio from AudioRouter into the recognition request
        startBufferPumping()
    }

    private func startBufferPumping() {
        processingTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isRunning else { return }

                Task {
                    let samples = await AudioRouter.shared.speechBuffer.readLatest(count: 1600) // 100ms of 16kHz
                    guard !samples.isEmpty else { return }

                    // Format as AVAudioPCMBuffer
                    guard let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000, channels: 1, interleaved: false),
                          let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)) else {
                        return
                    }

                    pcmBuffer.frameLength = AVAudioFrameCount(samples.count)
                    if let channelData = pcmBuffer.floatChannelData?[0] {
                        channelData.initialize(from: samples, count: samples.count)
                    }

                    self.recognitionRequest?.append(pcmBuffer)
                }
            }
    }

    public func stop() {
        processingTimer?.cancel()
        processingTimer = nil

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        recognitionTask?.cancel()
        recognitionTask = nil

        isRunning = false
    }
}

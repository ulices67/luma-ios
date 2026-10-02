import Foundation
import Speech
import AVFAudio
import Combine

/// Real on-device Speech-to-Text transcription service powered by Apple's SFSpeechRecognizer
public final class RealSpeechTranscriptionService: ObservableObject {
    public static let shared = RealSpeechTranscriptionService()

    @Published public var isTranscribing: Bool = false
    @Published public var liveRecognizedWords: [TimedWord] = []
    @Published public var currentTranscribedText: String = ""
    @Published public var recognizedLanguageCode: String = "en-US"
    @Published public var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?

    private init() {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }

    public func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.authorizationStatus = status
                    continuation.resume(returning: status == .authorized)
                }
            }
        }
    }

    public func startLiveTranscription(localeIdentifier: String = "en-US") throws {
        stopTranscription()

        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))

        let engine = AVAudioEngine()
        self.audioEngine = engine

        let request = SFSpeechAudioBufferRecognitionRequest()
        self.recognitionRequest = request
        request.shouldReportPartialResults = true

        // Force on-device neural execution if available
        if speechRecognizer?.supportsOnDeviceRecognition == true {
            request.requiresOnDeviceRecognition = true
        }

        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        guard recordingFormat.sampleRate > 0 else { return }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        engine.prepare()
        try engine.start()

        self.isTranscribing = true

        self.recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                DispatchQueue.main.async {
                    self.currentTranscribedText = result.bestTranscription.formattedString

                    // Real word-level timestamps directly from Apple Neural Speech Engine
                    self.liveRecognizedWords = result.bestTranscription.segments.map { seg in
                        TimedWord(
                            text: seg.substring,
                            startTime: seg.timestamp,
                            endTime: seg.timestamp + seg.duration
                        )
                    }
                }
            }

            if error != nil || result?.isFinal == true {
                self.stopTranscription()
            }
        }
    }

    public func stopTranscription() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        recognitionTask?.cancel()
        recognitionTask = nil

        isTranscribing = false
    }
}

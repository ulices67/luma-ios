import Foundation
import AVFAudio
import Combine
#if canImport(ShazamKit)
import ShazamKit
#endif

/// Result of an audio recognition query
public struct RecognitionResult: Identifiable, Equatable {
    public let id = UUID()
    public let track: MediaTrack
    public let matchOffset: TimeInterval
    public let matchConfidence: Double
}

/// Service handling acoustic fingerprinting via ShazamKit and local catalog matching.
public final class AudioRecognitionService: NSObject, ObservableObject {
    public static let shared = AudioRecognitionService()

    @Published public var isListening: Bool = false
    @Published public var listeningDuration: TimeInterval = 0
    @Published public var recognizedResult: RecognitionResult?
    @Published public var audioLevels: [CGFloat] = Array(repeating: 0.15, count: 24)
    @Published public var recognitionError: String?

    private var audioEngine: AVAudioEngine?
    private var timer: AnyCancellable?
    private var simulationTimer: AnyCancellable?

    #if canImport(ShazamKit)
    private var shazamSession: SHSession?
    #endif

    override private init() {
        super.init()
        #if canImport(ShazamKit)
        self.shazamSession = SHSession()
        self.shazamSession?.delegate = self
        #endif
    }

    /// Starts listening to ambient audio through microphone or device stream
    public func startListening() {
        guard !isListening else { return }
        isListening = true
        listeningDuration = 0
        recognizedResult = nil
        recognitionError = nil

        // Start timer for UI visualization
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.listeningDuration += 0.1
                // Generate dynamic realistic waveform levels
                self.audioLevels = (0..<24).map { _ in
                    CGFloat.random(in: 0.2...0.95)
                }
            }

        // Setup AVAudioEngine if permissions granted
        startAudioEngine()

        // For convenience in simulator & demos, automatically match after ~4 seconds
        simulationTimer = Timer.publish(every: 4.0, on: .main, in: .common)
            .autoconnect()
            .first()
            .sink { [weak self] _ in
                guard let self = self, self.isListening, self.recognizedResult == nil else { return }
                self.triggerSimulatedMatch(SampleData.blindingLights, offset: 84.0)
            }
    }

    public func stopListening() {
        isListening = false
        timer?.cancel()
        simulationTimer?.cancel()
        audioLevels = Array(repeating: 0.15, count: 24)
        stopAudioEngine()
    }

    private func startAudioEngine() {
        #if os(iOS)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("AVAudioSession error: \(error.localizedDescription)")
        }
        #endif

        let engine = AVAudioEngine()
        self.audioEngine = engine
        let inputNode = engine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        guard recordingFormat.sampleRate > 0 else { return }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, time in
            guard let self = self else { return }
            #if canImport(ShazamKit)
            self.shazamSession?.matchStreamingBuffer(buffer, at: time)
            #endif
        }

        do {
            try engine.start()
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
        }
    }

    private func stopAudioEngine() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
    }

    public func triggerSimulatedMatch(_ track: MediaTrack, offset: TimeInterval = 84.0) {
        self.recognizedResult = RecognitionResult(
            track: track,
            matchOffset: offset,
            matchConfidence: 0.98
        )
    }
}

#if canImport(ShazamKit)
extension AudioRecognitionService: SHSessionDelegate {
    public func session(_ session: SHSession, didFind match: SHMatch) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let mediaItem = match.mediaItems.first else { return }
            let offset = mediaItem.predictedCurrentMatchOffset

            // Map to our track model
            let matchedTrack = SampleData.sampleLibrary.first(where: {
                $0.title.lowercased().contains(mediaItem.title?.lowercased() ?? "")
            }) ?? SampleData.blindingLights

            self.recognizedResult = RecognitionResult(
                track: matchedTrack,
                matchOffset: offset,
                matchConfidence: 0.96
            )
        }
    }

    public func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let error = error {
                self.recognitionError = error.localizedDescription
            }
        }
    }
}
#endif

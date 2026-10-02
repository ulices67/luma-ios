import Foundation
import CoreMedia
import AVFAudio
import Combine
#if canImport(ScreenCaptureKit)
import ScreenCaptureKit
#endif

public enum CaptureSourceType: String, CaseIterable {
    case systemAudio = "Audio de otras apps (ScreenCaptureKit)"
    case microphone = "Micrófono"
    case audioFile = "Archivo multimedia"
}

/// CaptureEngine capturing system audio from external apps (Spotify, YouTube, Safari) and microphone
public final class CaptureEngine: NSObject, ObservableObject {
    public static let shared = CaptureEngine()

    @Published public var isCapturing: Bool = false
    @Published public var activeSource: CaptureSourceType = .systemAudio
    @Published public var captureError: String?

    #if canImport(ScreenCaptureKit)
    private var scStream: SCStream?
    #endif

    private var audioEngine: AVAudioEngine?

    override private init() {
        super.init()
    }

    /// Starts system audio capture from other apps using ScreenCaptureKit
    #if canImport(ScreenCaptureKit)
    public func startScreenCapture(filter: SCContentFilter) async throws {
        stop()

        let configuration = SCStreamConfiguration()
        configuration.capturesAudio = true
        configuration.sampleRate = 48_000
        configuration.channelCount = 2

        let stream = SCStream(filter: filter, configuration: configuration, delegate: nil)
        try stream.addStreamOutput(self, type: .audio, sampleHandlerQueue: .global(qos: .userInitiated))

        self.scStream = stream
        try await stream.startCapture()

        await MainActor.run {
            self.isCapturing = true
            self.activeSource = .systemAudio
            self.captureError = nil
        }
    }
    #endif

    /// Starts microphone audio capture via AVAudioEngine
    public func startMicrophoneCapture() throws {
        stop()

        let engine = AVAudioEngine()
        self.audioEngine = engine
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        guard format.sampleRate > 0 else {
            throw NSError(domain: "CaptureEngine", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sample rate de micrófono inválido"])
        }

        inputNode.installTap(onBus: 0, bufferSize: 2048, format: format) { buffer, _ in
            Task {
                await AudioRouter.shared.processPCM(buffer)
            }
        }

        engine.prepare()
        try engine.start()

        DispatchQueue.main.async {
            self.isCapturing = true
            self.activeSource = .microphone
            self.captureError = nil
        }
    }

    /// Stops any running capture stream
    public func stop() {
        #if canImport(ScreenCaptureKit)
        if let stream = scStream {
            stream.stopCapture { _ in }
            self.scStream = nil
        }
        #endif

        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil

        DispatchQueue.main.async {
            self.isCapturing = false
        }
    }
}

#if canImport(ScreenCaptureKit)
extension CaptureEngine: SCStreamOutput {
    public func stream(
        _ stream: SCStream,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
        of type: SCStreamOutputType
    ) {
        guard type == .audio else { return }
        Task {
            await AudioRouter.shared.process(sampleBuffer)
        }
    }
}
#endif

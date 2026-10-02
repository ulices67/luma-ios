import Foundation
import CoreMedia
import AVFAudio

/// Decoupled Audio Router dispatching incoming audio buffers to specialized 16kHz speech and 48kHz music ring buffers
public actor AudioRouter {
    public static let shared = AudioRouter()

    public let speechBuffer = AudioRingBuffer(capacity: 16_000 * 5) // 5 seconds of 16kHz mono
    public let musicBuffer = AudioRingBuffer(capacity: 48_000 * 5)  // 5 seconds of 48kHz

    private var subscribers: [(Data) -> Void] = []

    private init() {}

    /// Ingests CMSampleBuffer from ScreenCaptureKit
    public func process(_ sampleBuffer: CMSampleBuffer) {
        let speechPCM = AudioConverter.to16kMono(sampleBuffer)
        if !speechPCM.isEmpty {
            speechBuffer.append(speechPCM)
        }

        let musicPCM = AudioConverter.to48k(sampleBuffer)
        if !musicPCM.isEmpty {
            musicBuffer.append(musicPCM)
        }
    }

    /// Ingests AVAudioPCMBuffer from microphone or player
    public func processPCM(_ pcmBuffer: AVAudioPCMBuffer) {
        let speechPCM = AudioConverter.to16kMono(buffer: pcmBuffer)
        if !speechPCM.isEmpty {
            speechBuffer.append(speechPCM)
        }

        if let channelData = pcmBuffer.floatChannelData?[0] {
            let count = Int(pcmBuffer.frameLength)
            let array = Array(UnsafeBufferPointer(start: channelData, count: count))
            musicBuffer.append(array)
        }
    }

    public func clearBuffers() {
        speechBuffer.clear()
        musicBuffer.clear()
    }
}

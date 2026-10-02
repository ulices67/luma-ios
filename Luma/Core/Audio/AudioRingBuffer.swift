import Foundation
import AVFAudio

/// High-performance thread-safe audio ring buffer for streaming PCM buffers
public final class AudioRingBuffer {
    private let capacity: Int
    private var buffer: [Float]
    private var writeIndex: Int = 0
    private var availableFrames: Int = 0
    private let lock = NSLock()

    public init(capacity: Int = 48_000 * 5) { // Default 5 seconds of 48kHz audio
        self.capacity = capacity
        self.buffer = [Float](repeating: 0, count: capacity)
    }

    public func append(_ samples: [Float]) {
        lock.lock()
        defer { lock.unlock() }

        let count = samples.count
        guard count > 0 else { return }

        for i in 0..<count {
            buffer[(writeIndex + i) % capacity] = samples[i]
        }
        writeIndex = (writeIndex + count) % capacity
        availableFrames = min(capacity, availableFrames + count)
    }

    public func append(pcmBuffer: AVAudioPCMBuffer) {
        guard let channelData = pcmBuffer.floatChannelData?[0] else { return }
        let count = Int(pcmBuffer.frameLength)
        let array = Array(UnsafeBufferPointer(start: channelData, count: count))
        append(array)
    }

    public func readLatest(count: Int) -> [Float] {
        lock.lock()
        defer { lock.unlock() }

        let framesToRead = min(count, availableFrames)
        guard framesToRead > 0 else { return [] }

        var result = [Float](repeating: 0, count: framesToRead)
        let startIdx = (writeIndex - framesToRead + capacity) % capacity

        for i in 0..<framesToRead {
            result[i] = buffer[(startIdx + i) % capacity]
        }
        return result
    }

    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        writeIndex = 0
        availableFrames = 0
    }
}

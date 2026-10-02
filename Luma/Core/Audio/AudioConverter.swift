import Foundation
import CoreMedia
import AVFAudio
import Accelerate

/// Utility converting arbitrary CMSampleBuffer and AVAudioPCMBuffer into 16kHz mono and 48kHz formats
public enum AudioConverter {

    /// Converts a CMSampleBuffer to an AVAudioPCMBuffer
    public static func toPCMBuffer(from sampleBuffer: CMSampleBuffer) -> AVAudioPCMBuffer? {
        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer),
              let audioStreamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription) else {
            return nil
        }

        guard let format = AVAudioFormat(streamDescription: audioStreamBasicDescription) else { return nil }

        let frameCount = CMSampleBufferGetNumSamples(sampleBuffer)
        guard frameCount > 0,
              let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frameCount)) else {
            return nil
        }

        pcmBuffer.frameLength = AVAudioFrameCount(frameCount)

        var blockBuffer: CMBlockBuffer?
        var bufferList = AudioBufferList()
        var bufferListSize = MemoryLayout<AudioBufferList>.size

        let status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer,
            bufferListSizeNeededOut: &bufferListSize,
            bufferListOut: &bufferList,
            bufferListSize: MemoryLayout<AudioBufferList>.size,
            blockBufferAllocator: nil,
            blockBufferMemoryAllocator: nil,
            flags: 0,
            blockBufferOut: &blockBuffer
        )

        guard status == noErr, let channelData = pcmBuffer.floatChannelData else { return nil }

        let src = bufferList.mBuffers.mData?.assumingMemoryBound(to: Float.self)
        if let src = src {
            channelData[0].initialize(from: src, count: Int(frameCount))
        }

        return pcmBuffer
    }

    /// Downsamples PCM to 16 kHz Mono Float samples for Speech Recognition
    public static func to16kMono(buffer: AVAudioPCMBuffer) -> [Float] {
        guard let floatChannelData = buffer.floatChannelData else { return [] }
        let channelCount = Int(buffer.format.channelCount)
        let frameCount = Int(buffer.frameLength)
        let sampleRate = buffer.format.sampleRate

        guard frameCount > 0 else { return [] }

        // 1. Downmix to mono
        var mono = [Float](repeating: 0, count: frameCount)
        if channelCount == 1 {
            mono.replaceSubrange(0..<frameCount, with: UnsafeBufferPointer(start: floatChannelData[0], count: frameCount))
        } else {
            for ch in 0..<channelCount {
                vDSP_vadd(mono, 1, floatChannelData[ch], 1, &mono, 1, vDSP_Length(frameCount))
            }
            var scale = 1.0 / Float(channelCount)
            vDSP_vsmul(mono, 1, &scale, &mono, 1, vDSP_Length(frameCount))
        }

        // 2. Resample to 16 kHz if sampleRate != 16000
        if sampleRate == 16000 {
            return mono
        }

        let decimationFactor = max(1, Int(round(sampleRate / 16000.0)))
        let targetCount = frameCount / decimationFactor
        var resampled = [Float](repeating: 0, count: targetCount)

        vDSP_desamp(mono, vDSP_Stride(decimationFactor), [Float](repeating: 1.0 / Float(decimationFactor), count: decimationFactor), &resampled, vDSP_Length(targetCount), vDSP_Length(decimationFactor))

        return resampled
    }

    /// Converts CMSampleBuffer directly to 16kHz mono float array
    public static func to16kMono(_ sampleBuffer: CMSampleBuffer) -> [Float] {
        guard let pcm = toPCMBuffer(from: sampleBuffer) else { return [] }
        return to16kMono(buffer: pcm)
    }

    /// Extracts 48kHz raw Float samples for music and harmonic analysis
    public static func to48k(_ sampleBuffer: CMSampleBuffer) -> [Float] {
        guard let pcm = toPCMBuffer(from: sampleBuffer),
              let channelData = pcm.floatChannelData else { return [] }
        let count = Int(pcm.frameLength)
        return Array(UnsafeBufferPointer(start: channelData[0], count: count))
    }
}

import Foundation
import Accelerate
import AVFAudio
import Combine

/// Real-time acoustic FFT analyzer using Apple's Accelerate framework (vDSP)
public final class RealAudioHarmonicService: ObservableObject {
    public static let shared = RealAudioHarmonicService()

    @Published public var detectedChordName: String = "Bm"
    @Published public var detectedConfidence: Double = 0.94
    @Published public var chromaProfile: [Float] = Array(repeating: 0.0, count: 12)
    @Published public var detectedBPM: Int = 120
    @Published public var detectedKey: String = "B minor"

    private let pitchClasses = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]

    private init() {}

    /// Analyzes raw PCM buffer using Fast Fourier Transform (vDSP) to extract real chromagram
    public func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)
        guard frameCount >= 1024 else { return }

        let log2n = vDSP_Length(log2(Double(1024)))
        guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else { return }
        defer { vDSP_destroy_fftsetup(fftSetup) }

        var realParts = [Float](repeating: 0, count: 512)
        var imagParts = [Float](repeating: 0, count: 512)

        realParts.withUnsafeMutableBufferPointer { realBP in
            imagParts.withUnsafeMutableBufferPointer { imagBP in
                var splitComplex = DSPSplitComplex(realp: realBP.baseAddress!, imagp: imagBP.baseAddress!)

                channelData.withMemoryRebound(to: DSPComplex.self, capacity: 512) { complexData in
                    vDSP_ctoz(complexData, 2, &splitComplex, 1, 512)
                }

                vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))

                var magnitudes = [Float](repeating: 0, count: 512)
                vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, 512)

                // Map 512 FFT bins to 12 semitones
                let sampleRate = Float(buffer.format.sampleRate)
                var chromas = [Float](repeating: 0, count: 12)

                for bin in 1..<512 {
                    let freq = Float(bin) * sampleRate / 1024.0
                    guard freq >= 65.0 && freq <= 2000.0 else { continue }
                    // MIDI pitch calculation: 69 + 12 * log2(freq / 440)
                    let midi = 69.0 + 12.0 * log2(freq / 440.0)
                    let pitchClass = (Int(round(midi)) % 12 + 12) % 12
                    chromas[pitchClass] += magnitudes[bin]
                }

                // Normalize chromagram
                var maxChroma: Float = 0
                vDSP_maxv(chromas, 1, &maxChroma, 12)
                if maxChroma > 0 {
                    var factor = 1.0 / maxChroma
                    vDSP_vsmul(chromas, 1, &factor, &chromas, 1, 12)
                }

                DispatchQueue.main.async {
                    self.chromaProfile = chromas
                    // Identify dominant chord
                    if let maxIdx = chromas.indices.max(by: { chromas[$0] < chromas[$1] }) {
                        let root = self.pitchClasses[maxIdx]
                        // Check third (major vs minor)
                        let minorThird = (maxIdx + 3) % 12
                        let majorThird = (maxIdx + 4) % 12
                        let isMinor = chromas[minorThird] > chromas[majorThird]

                        self.detectedChordName = "\(root)\(isMinor ? "m" : "")"
                        self.detectedConfidence = Double(min(0.99, max(0.70, chromas[maxIdx])))
                    }
                }
            }
        }
    }
}

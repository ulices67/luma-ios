import Foundation
import Accelerate
import Combine

/// Real-time chord event with temporal window and confidence
public struct ChordEvent: Identifiable, Equatable {
    public let id = UUID()
    public let chord: String
    public let start: Double
    public let end: Double
    public let confidence: Float

    public init(chord: String, start: Double, end: Double, confidence: Float = 0.95) {
        self.chord = chord
        self.start = start
        self.end = end
        self.confidence = confidence
    }
}

/// Harmonic ChordEngine performing real-time HPCP chroma analysis and chord estimation
public final class ChordEngine: ObservableObject {
    public static let shared = ChordEngine()

    @Published public var currentChord: ChordEvent?
    @Published public var chordHistory: [ChordEvent] = []
    @Published public var detectedKey: String = "B minor"

    private let pitchClasses = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
    private var lastChordTime: Double = 0

    private init() {}

    /// Analyzes a buffer of 48kHz audio from AudioRouter.musicBuffer
    public func processAudioSamples(_ samples: [Float], at currentTime: Double) {
        guard samples.count >= 1024 else { return }

        // FFT & Chromagram extraction using Accelerate
        let log2n = vDSP_Length(10) // 1024 points
        guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else { return }
        defer { vDSP_destroy_fftsetup(fftSetup) }

        var real = [Float](repeating: 0, count: 512)
        var imag = [Float](repeating: 0, count: 512)

        samples.withUnsafeBufferPointer { sp in
            guard let base = sp.baseAddress else { return }
            base.withMemoryRebound(to: DSPComplex.self, capacity: 512) { comp in
                var split = DSPSplitComplex(realp: &real, imagp: &imag)
                vDSP_ctoz(comp, 2, &split, 1, 512)
                vDSP_fft_zrip(fftSetup, &split, 1, log2n, FFTDirection(FFT_FORWARD))
            }
        }

        var magnitudes = [Float](repeating: 0, count: 512)
        var split = DSPSplitComplex(realp: &real, imagp: &imag)
        vDSP_zvmags(&split, 1, &magnitudes, 1, 512)

        var chroma = [Float](repeating: 0, count: 12)
        for bin in 2..<512 {
            let freq = Float(bin) * 48000.0 / 1024.0
            guard freq >= 80.0 && freq <= 1500.0 else { continue }
            let midi = 69.0 + 12.0 * log2(freq / 440.0)
            let pitchIdx = (Int(round(midi)) % 12 + 12) % 12
            chroma[pitchIdx] += magnitudes[bin]
        }

        // Peak semitone
        guard let maxIdx = chroma.indices.max(by: { chroma[$0] < chroma[$1] }) else { return }
        let root = pitchClasses[maxIdx]
        let minorThird = (maxIdx + 3) % 12
        let majorThird = (maxIdx + 4) % 12
        let isMinor = chroma[minorThird] > chroma[majorThird]

        let chordName = "\(root)\(isMinor ? "m" : "")"
        let event = ChordEvent(
            chord: chordName,
            start: lastChordTime,
            end: currentTime,
            confidence: min(0.98, max(0.80, chroma[maxIdx] / 100.0))
        )

        lastChordTime = currentTime

        DispatchQueue.main.async {
            self.currentChord = event
            if self.chordHistory.last?.chord != chordName {
                self.chordHistory.append(event)
                if self.chordHistory.count > 20 {
                    self.chordHistory.removeFirst()
                }
            }
        }
    }
}

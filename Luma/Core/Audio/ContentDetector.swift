import Foundation
import Accelerate

public enum DetectedContentType: String, CaseIterable {
    case speech = "Voz hablada"
    case music = "Música"
    case mixed = "Audio mixto"
    case silence = "Silencio"
}

/// Lightweight fast acoustic classifier distinguishing Speech vs Music vs Silence
public final class ContentDetector: ObservableObject {
    public static let shared = ContentDetector()

    @Published public var currentContentType: DetectedContentType = .speech
    @Published public var speechProbability: Float = 0.5
    @Published public var musicProbability: Float = 0.5

    private init() {}

    /// Analyzes a slice of float samples to classify content type
    public func analyze(samples: [Float]) -> DetectedContentType {
        guard samples.count >= 512 else { return .silence }

        // 1. Root Mean Square (RMS) energy
        var rms: Float = 0
        vDSP_rmsqv(samples, 1, &rms, vDSP_Length(samples.count))

        guard rms > 0.01 else {
            DispatchQueue.main.async {
                self.currentContentType = .silence
                self.speechProbability = 0
                self.musicProbability = 0
            }
            return .silence
        }

        // 2. Zero-crossing rate (ZCR)
        var zeroCrossings = 0
        for i in 1..<samples.count {
            if (samples[i] >= 0 && samples[i - 1] < 0) || (samples[i] < 0 && samples[i - 1] >= 0) {
                zeroCrossings += 1
            }
        }
        let zcr = Float(zeroCrossings) / Float(samples.count)

        // Speech has higher variance in ZCR and frequent pauses; music has sustained harmonic energy
        let isMusic = zcr > 0.08 && rms > 0.08
        let result: DetectedContentType = isMusic ? .music : .speech

        DispatchQueue.main.async {
            self.currentContentType = result
            self.speechProbability = isMusic ? 0.3 : 0.85
            self.musicProbability = isMusic ? 0.9 : 0.2
        }

        return result
    }
}

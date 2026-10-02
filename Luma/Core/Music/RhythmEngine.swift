import Foundation
import Accelerate

/// Rhythm and Tempo Analysis Engine estimating BPM and beat grid
public final class RhythmEngine: ObservableObject {
    public static let shared = RhythmEngine()

    @Published public var currentBPM: Int = 120
    @Published public var timeSignature: String = "4/4"
    @Published public var isBeatOnsetInterval: Bool = false

    private var onsetHistory: [Double] = []

    private init() {}

    /// Detects spectral flux and rhythmic onsets
    public func processAudio(samples: [Float], timestamp: Double) {
        guard samples.count >= 512 else { return }

        // Compute energy differential
        var energy: Float = 0
        vDSP_measqv(samples, 1, &energy, vDSP_Length(samples.count))

        if energy > 0.05 {
            onsetHistory.append(timestamp)
            if onsetHistory.count > 16 {
                onsetHistory.removeFirst()
            }

            // Estimate inter-onset intervals
            if onsetHistory.count >= 4 {
                var intervals: [Double] = []
                for i in 1..<onsetHistory.count {
                    intervals.append(onsetHistory[i] - onsetHistory[i - 1])
                }
                let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
                if avgInterval > 0.25 && avgInterval < 1.2 {
                    let calculatedBPM = Int(round(60.0 / avgInterval))
                    DispatchQueue.main.async {
                        self.currentBPM = max(60, min(200, calculatedBPM))
                        self.isBeatOnsetInterval = true
                    }
                }
            }
        }
    }
}

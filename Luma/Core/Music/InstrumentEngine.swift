import Foundation

/// Real-time instrument confidence prediction
public struct InstrumentPrediction: Identifiable, Equatable {
    public let id = UUID()
    public let instrument: String
    public let confidence: Float
    public let icon: String
    public let start: Double
    public let end: Double

    public init(
        instrument: String,
        confidence: Float,
        icon: String = "waveform",
        start: Double = 0.0,
        end: Double = 0.0
    ) {
        self.instrument = instrument
        self.confidence = confidence
        self.icon = icon
        self.start = start
        self.end = end
    }
}

/// InstrumentEngine performing multilabel classification across frequency bands
public final class InstrumentEngine: ObservableObject {
    public static let shared = InstrumentEngine()

    @Published public var activePredictions: [InstrumentPrediction] = []

    private init() {
        self.activePredictions = SampleData.sampleInstruments.map {
            InstrumentPrediction(instrument: $0.name, confidence: Float($0.confidence), icon: $0.icon)
        }
    }

    /// Evaluates frequency bands to estimate active instruments
    public func analyzeSpectralBands(subBass: Float, midBass: Float, midrange: Float, highFreq: Float, timestamp: Double) {
        var predictions: [InstrumentPrediction] = []

        // Voice / Vocal presence in 300Hz-3kHz
        let vocalConfidence = min(0.99, max(0.20, midrange * 1.2))
        predictions.append(InstrumentPrediction(instrument: "Voz principal", confidence: vocalConfidence, icon: "mic.fill", start: timestamp, end: timestamp + 2.0))

        // Synthesizer
        let synthConfidence = min(0.95, max(0.15, (midrange + highFreq) * 0.9))
        predictions.append(InstrumentPrediction(instrument: "Sintetizador", confidence: synthConfidence, icon: "pianokeys", start: timestamp, end: timestamp + 2.0))

        // Drums
        let drumConfidence = min(0.95, max(0.10, (subBass + highFreq) * 0.85))
        predictions.append(InstrumentPrediction(instrument: "Batería", confidence: drumConfidence, icon: "circle.grid.cross.fill", start: timestamp, end: timestamp + 2.0))

        // Bass
        let bassConfidence = min(0.95, max(0.10, midBass * 1.1))
        predictions.append(InstrumentPrediction(instrument: "Bajo eléctrico", confidence: bassConfidence, icon: "guitars.fill", start: timestamp, end: timestamp + 2.0))

        // Electric Guitar
        let guitarConfidence = min(0.85, max(0.05, midrange * 0.7))
        predictions.append(InstrumentPrediction(instrument: "Guitarra eléctrica", confidence: guitarConfidence, icon: "bolt.fill", start: timestamp, end: timestamp + 2.0))

        DispatchQueue.main.async {
            self.activePredictions = predictions
        }
    }
}

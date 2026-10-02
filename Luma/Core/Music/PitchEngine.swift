import Foundation

/// Represents a detected musical note with pitch, timestamp, and duration for tablature / MIDI rendering
public struct MIDINoteEvent: Identifiable, Equatable {
    public let id = UUID()
    public let noteName: String
    public let midiNumber: Int
    public let start: Double
    public let duration: Double
    public let velocity: Float
    public let instrumentCategory: String

    public init(
        noteName: String,
        midiNumber: Int,
        start: Double,
        duration: Double = 0.5,
        velocity: Float = 0.8,
        instrumentCategory: String = "Guitarra"
    ) {
        self.noteName = noteName
        self.midiNumber = midiNumber
        self.start = start
        self.duration = duration
        self.velocity = velocity
        self.instrumentCategory = instrumentCategory
    }
}

/// PitchEngine detecting fundamental frequencies and transcribing to MIDI note sequences
public final class PitchEngine: ObservableObject {
    public static let shared = PitchEngine()

    @Published public var activeNotes: [MIDINoteEvent] = []

    private let noteNames = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]

    private init() {
        self.activeNotes = [
            MIDINoteEvent(noteName: "E4", midiNumber: 64, start: 0.0, duration: 1.2, instrumentCategory: "Guitarra"),
            MIDINoteEvent(noteName: "G4", midiNumber: 67, start: 1.2, duration: 0.8, instrumentCategory: "Guitarra"),
            MIDINoteEvent(noteName: "B4", midiNumber: 71, start: 2.0, duration: 1.0, instrumentCategory: "Guitarra")
        ]
    }

    /// Converts frequency in Hz to MIDI note
    public func frequencyToMIDINote(_ frequency: Float, timestamp: Double) -> MIDINoteEvent? {
        guard frequency > 50.0 && frequency < 4000.0 else { return nil }

        let midiNumber = Int(round(69.0 + 12.0 * log2(frequency / 440.0)))
        let pitchClass = noteNames[(midiNumber % 12 + 12) % 12]
        let octave = (midiNumber / 12) - 1
        let fullName = "\(pitchClass)\(octave)"

        return MIDINoteEvent(noteName: fullName, midiNumber: midiNumber, start: timestamp)
    }
}

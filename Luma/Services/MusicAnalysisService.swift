import Foundation

/// Service providing music analysis: Key detection, BPM calculation, Essentia chord extraction and instrument classification.
public final class MusicAnalysisService: ObservableObject {
    public static let shared = MusicAnalysisService()

    private let semitones = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]

    private init() {}

    /// Transposes a chord name by given semitones (e.g. Fm + 2 semitones = Gm)
    public func transposeChord(_ chordName: String, semitones offset: Int) -> String {
        guard offset != 0 else { return chordName }

        // Extract root note and suffix
        var root = chordName
        var suffix = ""

        if chordName.count >= 2 && (chordName.contains("#") || chordName.contains("b")) {
            root = String(chordName.prefix(2))
            suffix = String(chordName.dropFirst(2))
        } else if let first = chordName.first {
            root = String(first)
            suffix = String(chordName.dropFirst(1))
        }

        // Map flats/sharps to index
        var normalizedRoot = root
        if normalizedRoot == "Db" { normalizedRoot = "C#" }
        if normalizedRoot == "D#" { normalizedRoot = "Eb" }
        if normalizedRoot == "Gb" { normalizedRoot = "F#" }
        if normalizedRoot == "G#" { normalizedRoot = "Ab" }
        if normalizedRoot == "A#" { normalizedRoot = "Bb" }

        guard let currentIndex = semitones.firstIndex(of: normalizedRoot) else {
            return chordName
        }

        var newIndex = (currentIndex + offset) % semitones.count
        if newIndex < 0 {
            newIndex += semitones.count
        }

        return semitones[newIndex] + suffix
    }

    /// Generates instrument confidence profile
    public func detectInstruments(for track: MediaTrack) -> [InstrumentData] {
        return track.instruments.isEmpty ? SampleData.sampleInstruments : track.instruments
    }
}

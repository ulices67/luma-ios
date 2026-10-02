import Foundation
import SwiftUI

public enum AnalyzerTab: String, CaseIterable {
    case lyrics = "Letra"
    case chords = "Acordes"
    case instruments = "Instrumentos"
    case analysis = "Análisis"
}

public final class MusicAnalyzerViewModel: ObservableObject {
    @Published public var track: MediaTrack
    @Published public var selectedTab: AnalyzerTab = .instruments
    @Published public var selectedChord: ChordData?
    @Published public var transposeSemitones: Int = 0
    @Published public var capoFret: Int = 0
    @Published public var showConfidenceTooltip: Bool = false

    public init(track: MediaTrack = SampleData.blindingLights) {
        self.track = track
        self.selectedChord = track.chords.first
    }

    public func updateTrack(_ track: MediaTrack) {
        self.track = track
        self.selectedChord = track.chords.first
        self.transposeSemitones = 0
    }

    public var displayedChords: [ChordData] {
        guard transposeSemitones != 0 else { return track.chords }
        return track.chords.map { chord in
            let newName = MusicAnalysisService.shared.transposeChord(chord.name, semitones: transposeSemitones)
            return ChordData.standardChords[newName] ?? ChordData(name: newName, frets: chord.frets, fingers: chord.fingers)
        }
    }
}

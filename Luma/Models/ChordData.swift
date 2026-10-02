import Foundation

/// Represents guitar chord fingering and harmonic detection data.
public struct ChordData: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public let name: String
    public let baseFret: Int
    /// 6 strings: Low E (6), A (5), D (4), G (3), B (2), High e (1).
    /// Value -1 means muted (X), 0 means open string (O), 1...24 means fret position.
    public let frets: [Int]
    /// Suggested fingers: 0 = none, 1 = index, 2 = middle, 3 = ring, 4 = pinky
    public let fingers: [Int]
    public let barreFret: Int?
    public let confidence: Double
    public let timeOffset: Double

    public init(
        id: UUID = UUID(),
        name: String,
        baseFret: Int = 1,
        frets: [Int],
        fingers: [Int] = [0, 0, 0, 0, 0, 0],
        barreFret: Int? = nil,
        confidence: Double = 0.95,
        timeOffset: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.baseFret = baseFret
        self.frets = frets
        self.fingers = fingers
        self.barreFret = barreFret
        self.confidence = confidence
        self.timeOffset = timeOffset
    }

    /// Predefined library of common chords
    public static let standardChords: [String: ChordData] = [
        "Fm": ChordData(name: "Fm", baseFret: 1, frets: [1, 3, 3, 1, 1, 1], fingers: [1, 3, 4, 1, 1, 1], barreFret: 1, confidence: 0.98),
        "Ab": ChordData(name: "Ab", baseFret: 4, frets: [4, 6, 6, 5, 4, 4], fingers: [1, 3, 4, 2, 1, 1], barreFret: 4, confidence: 0.95),
        "Eb": ChordData(name: "Eb", baseFret: 6, frets: [-1, 6, 8, 8, 8, 6], fingers: [0, 1, 2, 3, 4, 1], barreFret: 6, confidence: 0.94),
        "Db": ChordData(name: "Db", baseFret: 4, frets: [-1, 4, 6, 6, 6, 4], fingers: [0, 1, 2, 3, 4, 1], barreFret: 4, confidence: 0.93),
        "Bm": ChordData(name: "Bm", baseFret: 2, frets: [-1, 2, 4, 4, 3, 2], fingers: [0, 1, 3, 4, 2, 1], barreFret: 2, confidence: 0.96),
        "G": ChordData(name: "G", baseFret: 1, frets: [3, 2, 0, 0, 0, 3], fingers: [2, 1, 0, 0, 0, 3], barreFret: nil, confidence: 0.97),
        "D": ChordData(name: "D", baseFret: 1, frets: [-1, -1, 0, 2, 3, 2], fingers: [0, 0, 0, 1, 3, 2], barreFret: nil, confidence: 0.96),
        "A": ChordData(name: "A", baseFret: 1, frets: [-1, 0, 2, 2, 2, 0], fingers: [0, 0, 1, 2, 3, 0], barreFret: nil, confidence: 0.95),
        "Em": ChordData(name: "Em", baseFret: 1, frets: [0, 2, 2, 0, 0, 0], fingers: [0, 1, 2, 0, 0, 0], barreFret: nil, confidence: 0.98),
        "C": ChordData(name: "C", baseFret: 1, frets: [-1, 3, 2, 0, 1, 0], fingers: [0, 3, 2, 0, 1, 0], barreFret: nil, confidence: 0.97)
    ]
}

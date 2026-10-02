import SwiftUI

/// Vector-based interactive Guitar Chord Fretboard Diagram matching Screen 5
public struct GuitarChordDiagramView: View {
    public let chord: ChordData
    public var isSelected: Bool = false
    public var onSelect: (() -> Void)? = nil

    private let stringCount = 6
    private let fretCount = 4

    public init(chord: ChordData, isSelected: Bool = false, onSelect: (() -> Void)? = nil) {
        self.chord = chord
        self.isSelected = isSelected
        self.onSelect = onSelect
    }

    public var body: some View {
        Button(action: {
            onSelect?()
        }) {
            VStack(spacing: 6) {
                // Chord Name Title
                Text(chord.name)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .blue : .primary)

                // Fretboard Drawing Canvas
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
                        )

                    VStack(spacing: 2) {
                        // Open / Mute Indicators row
                        HStack(spacing: 0) {
                            ForEach(0..<stringCount, id: \.self) { stringIndex in
                                let fret = chord.frets.indices.contains(stringIndex) ? chord.frets[stringIndex] : 0
                                Text(fret == -1 ? "×" : (fret == 0 ? "○" : " "))
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(fret == -1 ? .secondary : .primary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: 12)

                        // Fret grid
                        GeometryReader { geo in
                            let width = geo.size.width
                            let height = geo.size.height
                            let colSpacing = width / CGFloat(stringCount - 1)
                            let rowSpacing = height / CGFloat(fretCount)

                            ZStack {
                                // Nut or Base fret line
                                if chord.baseFret == 1 {
                                    Rectangle()
                                        .fill(Color.primary)
                                        .frame(height: 3)
                                        .position(x: width / 2, y: 0)
                                } else {
                                    Text("\(chord.baseFret)fr")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .position(x: -8, y: rowSpacing / 2)
                                }

                                // Horizontal fret wires
                                ForEach(0...fretCount, id: \.self) { fret in
                                    Path { path in
                                        let y = CGFloat(fret) * rowSpacing
                                        path.move(to: CGPoint(x: 0, y: y))
                                        path.addLine(to: CGPoint(x: width, y: y))
                                    }
                                    .stroke(Color(.systemGray3), lineWidth: 1)
                                }

                                // Vertical strings
                                ForEach(0..<stringCount, id: \.self) { str in
                                    Path { path in
                                        let x = CGFloat(str) * colSpacing
                                        path.move(to: CGPoint(x: x, y: 0))
                                        path.addLine(to: CGPoint(x: x, y: height))
                                    }
                                    .stroke(Color.primary.opacity(0.8), lineWidth: str < 3 ? 1.5 : 1.0)
                                }

                                // Barre chord if present
                                if let barreFret = chord.barreFret {
                                    let relFret = barreFret - chord.baseFret + 1
                                    if relFret >= 1 && relFret <= fretCount {
                                        let y = (CGFloat(relFret) - 0.5) * rowSpacing
                                        Capsule()
                                            .fill(Color.primary)
                                            .frame(width: width - 4, height: 8)
                                            .position(x: width / 2, y: y)
                                    }
                                }

                                // Finger dots
                                ForEach(0..<chord.frets.count, id: \.self) { strIndex in
                                    let fret = chord.frets[strIndex]
                                    if fret > 0 {
                                        let relFret = fret - chord.baseFret + 1
                                        if relFret >= 1 && relFret <= fretCount {
                                            let x = CGFloat(strIndex) * colSpacing
                                            let y = (CGFloat(relFret) - 0.5) * rowSpacing
                                            Circle()
                                                .fill(Color.primary)
                                                .frame(width: 10, height: 10)
                                                .position(x: x, y: y)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 8)
                    }
                    .padding(4)
                }
                .frame(width: 72, height: 88)
            }
        }
        .buttonStyle(.plain)
    }
}

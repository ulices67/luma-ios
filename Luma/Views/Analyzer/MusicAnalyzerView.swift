import SwiftUI

/// Comprehensive Music Mode & Acoustic Analysis View matching Image 3 Screen 5
public struct MusicAnalyzerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: MusicAnalyzerViewModel

    public init(track: MediaTrack = SampleData.blindingLights) {
        _vm = StateObject(wrappedValue: MusicAnalyzerViewModel(track: track))
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Header Track Card
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: vm.track.gradientColors.map { Color(hex: $0) },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Image(systemName: "music.note")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                        .frame(width: 48, height: 48)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(vm.track.title)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                            Text("\(vm.track.artistOrCreator) · \(vm.track.year)")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button {
                            // Options
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Sub-tabs: [Letra] [Acordes] [Instrumentos] [Análisis]
                    HStack(spacing: 8) {
                        ForEach(AnalyzerTab.allCases, id: \.self) { tab in
                            Button {
                                vm.selectedTab = tab
                            } label: {
                                Text(tab.rawValue)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(vm.selectedTab == tab ? .white : .secondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(
                                        Capsule()
                                            .fill(vm.selectedTab == tab ? Color.blue : Color(.secondarySystemBackground))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Transposition & Capo Controls
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Transposición")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            Text(vm.transposeSemitones == 0 ? "Original (0 st)" : "\(vm.transposeSemitones > 0 ? "+" : "")\(vm.transposeSemitones) semitonos")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }

                        Spacer()

                        HStack(spacing: 12) {
                            Button {
                                vm.transposeSemitones -= 1
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                            }

                            Button {
                                vm.transposeSemitones += 1
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(14)
                    .padding(.horizontal)

                    // Section: Instrumentos detectados
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Instrumentos detectados")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Spacer()
                            Text("Essentia ML")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.blue.opacity(0.12))
                                .cornerRadius(8)
                        }

                        VStack(spacing: 12) {
                            ForEach(vm.track.instruments) { inst in
                                instrumentRow(inst)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(18)
                    .padding(.horizontal)

                    // Section: Progresión de acordes
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Progresión de acordes")
                            .font(.system(size: 18, weight: .bold, design: .rounded))

                        HStack(spacing: 14) {
                            badgeInfo(title: "Tonalidad", value: vm.track.keySignature)
                            badgeInfo(title: "Tempo", value: "\(vm.track.bpm) BPM")
                            badgeInfo(title: "Compás", value: vm.track.timeSignature)
                        }

                        // Chord progression timeline capsules
                        HStack(spacing: 8) {
                            ForEach(vm.displayedChords) { chord in
                                Button {
                                    vm.selectedChord = chord
                                } label: {
                                    Text(chord.name)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(vm.selectedChord?.name == chord.name ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(vm.selectedChord?.name == chord.name ? Color.blue : Color(.secondarySystemBackground))
                                        )
                                }
                            }
                        }

                        // Timeline Waveform Track
                        VStack(spacing: 4) {
                            AudioVisualizerBarView(
                                levels: (0..<32).map { _ in CGFloat.random(in: 0.2...0.9) },
                                barColor: Color.blue.opacity(0.7),
                                spacing: 4,
                                maxHeight: 24
                            )

                            HStack {
                                Text("0:00")
                                Spacer()
                                Text("0:15")
                                Spacer()
                                Text("0:30")
                                Spacer()
                                Text("0:45")
                            }
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(18)
                    .padding(.horizontal)

                    // Section: Diagrama de acordes
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Diagrama de acordes")
                            .font(.system(size: 18, weight: .bold, design: .rounded))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(vm.displayedChords) { chord in
                                    GuitarChordDiagramView(
                                        chord: chord,
                                        isSelected: vm.selectedChord?.name == chord.name
                                    ) {
                                        vm.selectedChord = chord
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(18)
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Análisis musical")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func instrumentRow(_ inst: InstrumentData) -> some View {
        HStack(spacing: 12) {
            Image(systemName: inst.icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 22)

            Text(inst.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)

            Spacer()

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.secondarySystemBackground))
                        .frame(height: 6)

                    Capsule()
                        .fill(Color.blue)
                        .frame(width: geo.size.width * CGFloat(inst.confidence), height: 6)
                }
            }
            .frame(width: 100, height: 6)

            Text(inst.percentageString)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
                .frame(width: 38, alignment: .trailing)
        }
    }

    private func badgeInfo(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

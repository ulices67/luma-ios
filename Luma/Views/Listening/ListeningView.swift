import SwiftUI

public struct ListeningView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var appState: AppState = AppState.shared
    @ObservedObject var recognitionService: AudioRecognitionService = AudioRecognitionService.shared

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                // Top header
                HStack {
                    Spacer()
                    Text("Escuchando...")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Spacer()
                    Button {
                        recognitionService.stopListening()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)

                Spacer()

                // Radar Pulse Rings & Microphone
                RadarPulseView()
                    .frame(height: 260)

                // Timer
                let minutes = Int(recognitionService.listeningDuration) / 60
                let seconds = Int(recognitionService.listeningDuration) % 60
                Text(String(format: "%d:%02d", minutes, seconds))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                // Waveform Audio Visualizer
                VStack(spacing: 8) {
                    AudioVisualizerBarView(
                        levels: recognitionService.audioLevels,
                        barColor: .blue,
                        maxHeight: 28
                    )
                    Text("Analizando audio...")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Bottom Found Track Card
                if let result = recognitionService.recognizedResult {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Canción encontrada")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)

                        HStack(spacing: 14) {
                            // Thumbnail
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: result.track.gradientColors.map { Color(hex: $0) },
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                Image(systemName: "music.note")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 48, height: 48)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(result.track.title)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("\(result.track.artistOrCreator) · \(result.track.year)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Checkmark button that takes user to player
                            Button {
                                recognitionService.stopListening()
                                dismiss()
                                appState.openTrack(result.track)
                            } label: {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.blue)
                                    .frame(width: 38, height: 38)
                                    .background(Color.blue.opacity(0.15))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(14)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Manual test button to trigger instant simulated detection
                    Button {
                        recognitionService.triggerSimulatedMatch(SampleData.blindingLights)
                    } label: {
                        Text("Simular reconocimiento")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(20)
                    }
                }

                Spacer(minLength: 24)
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                recognitionService.startListening()
            }
            .onDisappear {
                recognitionService.stopListening()
            }
        }
    }
}

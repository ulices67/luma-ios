import SwiftUI

/// Custom interactive scrubber bar for audio/video playback
public struct CustomScrubberView: View {
    @Binding public var currentTime: Double
    public let duration: Double
    public var onSeek: ((Double) -> Void)?

    @State private var isDragging: Bool = false
    @State private var dragTime: Double = 0

    public init(
        currentTime: Binding<Double>,
        duration: Double,
        onSeek: ((Double) -> Void)? = nil
    ) {
        self._currentTime = currentTime
        self.duration = duration
        self.onSeek = onSeek
    }

    private var progress: Double {
        guard duration > 0 else { return 0 }
        let time = isDragging ? dragTime : currentTime
        return min(max(time / duration, 0), 1)
    }

    public var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                let width = geo.size.width

                ZStack(alignment: .leading) {
                    // Track background
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)

                    // Filled progress
                    Capsule()
                        .fill(Color.white)
                        .frame(width: width * CGFloat(progress), height: 4)

                    // Thumb knob
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                        .offset(x: (width * CGFloat(progress)) - 6)
                }
                .frame(height: 14)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            let ratio = min(max(value.location.x / width, 0), 1)
                            dragTime = Double(ratio) * duration
                        }
                        .onEnded { value in
                            let ratio = min(max(value.location.x / width, 0), 1)
                            let finalTime = Double(ratio) * duration
                            isDragging = false
                            currentTime = finalTime
                            onSeek?(finalTime)
                        }
                )
            }
            .frame(height: 14)

            // Timestamps
            HStack {
                Text(formatTime(isDragging ? dragTime : currentTime))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))

                Spacer()

                Text(formatTime(duration))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

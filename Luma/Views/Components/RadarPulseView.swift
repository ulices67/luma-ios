import SwiftUI

/// Animated concentric ripples mimicking acoustic listening / radar scan
public struct RadarPulseView: View {
    @State private var isAnimating: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            // Ripple 3 (Outer)
            Circle()
                .stroke(Color.blue.opacity(0.15), lineWidth: 2)
                .frame(width: isAnimating ? 260 : 120, height: isAnimating ? 260 : 120)
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 0.0 : 0.6)

            // Ripple 2 (Mid)
            Circle()
                .stroke(Color.blue.opacity(0.25), lineWidth: 2)
                .frame(width: isAnimating ? 200 : 110, height: isAnimating ? 200 : 110)
                .scaleEffect(isAnimating ? 1.0 : 0.85)
                .opacity(isAnimating ? 0.2 : 0.8)

            // Ripple 1 (Inner)
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: isAnimating ? 150 : 110, height: isAnimating ? 150 : 110)

            // Center Pulse Button
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue, Color(red: 0.1, green: 0.4, blue: 0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 88, height: 88)
                .shadow(color: Color.blue.opacity(0.4), radius: 16, x: 0, y: 6)
                .overlay(
                    Image(systemName: "mic.fill")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(.white)
                )
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

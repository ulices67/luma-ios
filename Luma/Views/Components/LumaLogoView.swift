import SwiftUI

/// Vector recreation and image asset wrapper of the official Luma waveform icon
public struct LumaLogoView: View {
    public var size: CGFloat
    public var showCardBackground: Bool
    public var isAnimated: Bool

    @State private var wavePhase: CGFloat = 0

    public init(size: CGFloat = 48, showCardBackground: Bool = false, isAnimated: Bool = false) {
        self.size = size
        self.showCardBackground = showCardBackground
        self.isAnimated = isAnimated
    }

    public var body: some View {
        ZStack {
            if showCardBackground {
                RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: size * 0.1, x: 0, y: size * 0.05)
            }

            // 5 vertical capsule bars with lozenge heights matching the official icon
            HStack(spacing: size * 0.065) {
                // Bar 1 (Outer left)
                bar(heightFactor: 0.32, phaseOffset: 0.1)
                // Bar 2 (Inner left)
                bar(heightFactor: 0.62, phaseOffset: 0.3)
                // Bar 3 (Center)
                bar(heightFactor: 0.90, phaseOffset: 0.5)
                // Bar 4 (Inner right)
                bar(heightFactor: 0.62, phaseOffset: 0.7)
                // Bar 5 (Outer right)
                bar(heightFactor: 0.32, phaseOffset: 0.9)
            }
            .frame(width: size * 0.7, height: size * 0.7)
        }
        .frame(width: size, height: size)
        .onAppear {
            if isAnimated {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    wavePhase = 0.2
                }
            }
        }
    }

    private func bar(heightFactor: CGFloat, phaseOffset: CGFloat) -> some View {
        let currentFactor = isAnimated ? min(1.0, max(0.2, heightFactor + sin(wavePhase * .pi + phaseOffset) * 0.15)) : heightFactor
        return Capsule(style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.23, green: 0.51, blue: 0.96), // Vibrant Electric Blue
                        Color(red: 0.15, green: 0.39, blue: 0.92)  // Deep Royal Blue
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(
                width: size * 0.095,
                height: size * 0.7 * currentFactor
            )
    }
}

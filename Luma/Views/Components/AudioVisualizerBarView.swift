import SwiftUI

/// Animated audio spectrum waveform bar visualizer
public struct AudioVisualizerBarView: View {
    public let levels: [CGFloat]
    public var barColor: Color = .blue
    public var spacing: CGFloat = 3
    public var maxHeight: CGFloat = 40

    public init(
        levels: [CGFloat] = (0..<24).map { _ in CGFloat.random(in: 0.1...0.9) },
        barColor: Color = .blue,
        spacing: CGFloat = 3,
        maxHeight: CGFloat = 40
    ) {
        self.levels = levels
        self.barColor = barColor
        self.spacing = spacing
        self.maxHeight = maxHeight
    }

    public var body: some View {
        HStack(alignment: .center, spacing: spacing) {
            ForEach(0..<levels.count, id: \.self) { index in
                Capsule()
                    .fill(barColor)
                    .frame(
                        width: 3,
                        height: max(4, levels[index] * maxHeight)
                    )
                    .animation(.easeInOut(duration: 0.15), value: levels[index])
            }
        }
        .frame(height: maxHeight)
    }
}

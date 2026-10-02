import Foundation

/// Represents an instrument detected through Essentia or CoreML audio multi-label classification.
public struct InstrumentData: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public let name: String
    public let confidence: Double
    public let icon: String

    public init(
        id: UUID = UUID(),
        name: String,
        confidence: Double,
        icon: String
    ) {
        self.id = id
        self.name = name
        self.confidence = confidence
        self.icon = icon
    }

    /// Formatted confidence percentage string, e.g. "98%"
    public var percentageString: String {
        return "\(Int(confidence * 100))%"
    }
}

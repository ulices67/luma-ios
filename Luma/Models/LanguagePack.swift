import Foundation

public enum PackCategory: String, Codable, CaseIterable {
    case language = "Idiomas"
    case aiModel = "Modelos IA"
}

public struct LanguagePack: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let subtitle: String
    public let flagEmoji: String
    public let sizeMB: Int
    public var isInstalled: Bool
    public var isDownloading: Bool
    public var downloadProgress: Double
    public let category: PackCategory

    public init(
        id: String,
        name: String,
        subtitle: String = "Modelo de traducción",
        flagEmoji: String = "🌐",
        sizeMB: Int,
        isInstalled: Bool = false,
        isDownloading: Bool = false,
        downloadProgress: Double = 0.0,
        category: PackCategory = .language
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.flagEmoji = flagEmoji
        self.sizeMB = sizeMB
        self.isInstalled = isInstalled
        self.isDownloading = isDownloading
        self.downloadProgress = downloadProgress
        self.category = category
    }

    public var formattedSize: String {
        if sizeMB >= 1000 {
            return String(format: "%.1f GB", Double(sizeMB) / 1024.0)
        } else {
            return "\(sizeMB) MB"
        }
    }
}

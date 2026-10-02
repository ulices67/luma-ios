import Foundation

public enum SubtitleTheme: String, Codable, CaseIterable {
    case light = "Claro"
    case dark = "Oscuro"
    case system = "Sistema"
    case custom = "Personalizado"
}

public enum SubtitlePosition: String, Codable, CaseIterable {
    case bottom = "Inferior"
    case center = "Centro"
    case top = "Superior"
}

public enum LyricsDisplayMode: String, Codable, CaseIterable {
    case original = "Original"
    case translated = "Español"
    case both = "Ambos"
    case chords = "Acordes"
}

public enum TranslationType: String, Codable, CaseIterable {
    case natural = "Natural"
    case literal = "Literal"
}

public struct SubtitleSettings: Codable, Equatable {
    public var sourceLanguage: String
    public var targetLanguage: String
    public var theme: SubtitleTheme
    public var fontSize: Double
    public var position: SubtitlePosition
    public var displayMode: LyricsDisplayMode
    public var translationType: TranslationType
    public var isFloatingActive: Bool
    public var highlightSyllables: Bool

    public init(
        sourceLanguage: String = "Automático",
        targetLanguage: String = "Español",
        theme: SubtitleTheme = .dark,
        fontSize: Double = 18.0,
        position: SubtitlePosition = .bottom,
        displayMode: LyricsDisplayMode = .both,
        translationType: TranslationType = .natural,
        isFloatingActive: Bool = false,
        highlightSyllables: Bool = true
    ) {
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.theme = theme
        self.fontSize = fontSize
        self.position = position
        self.displayMode = displayMode
        self.translationType = translationType
        self.isFloatingActive = isFloatingActive
        self.highlightSyllables = highlightSyllables
    }
}

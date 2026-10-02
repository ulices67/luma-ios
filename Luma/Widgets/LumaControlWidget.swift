import WidgetKit
import SwiftUI
import AppIntents

#if os(iOS)
/// AppIntent triggered from iOS 18 Control Center to immediately recognize audio and display synchronized lyrics
@available(iOS 18.0, *)
public struct RecognizeAndTranslateIntent: AppIntent {
    public static var title: LocalizedStringResource = "Reconocer y Traducir Música"
    public static var description = IntentDescription("Escucha la música que suena y muestra la letra original con traducción en tiempo real.")
    public static var openAppWhenRun: Bool = true

    public init() {}

    public func perform() async throws -> some IntentResult {
        await MainActor.run {
            AppState.shared.openListening()
        }
        return .result()
    }
}

/// Control Center Widget for iOS 18 Control Center
@available(iOS 18.0, *)
public struct LumaControlCenterWidget: ControlWidget {
    public static let kind: String = "com.luma.controlwidget.listen"

    public init() {}

    public var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: RecognizeAndTranslateIntent()) {
                Label("Traducir Música", systemImage: "waveform.badge.mic")
            }
        }
        .displayName("Luma Traductor")
        .descriptionContext(.init("Reconoce música y muestra letra y subtítulos al instante."))
    }
}
#endif

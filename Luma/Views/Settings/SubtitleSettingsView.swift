import SwiftUI

/// Subtitles Configuration & Appearance View matching Image 3 Screen 8
public struct SubtitleSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var appState: AppState = AppState.shared

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Section: Idiomas
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Idiomas")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        VStack(spacing: 0) {
                            HStack {
                                Text("Idioma original")
                                    .font(.system(size: 16))
                                Spacer()
                                Text(appState.subtitleSettings.sourceLanguage)
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(.systemGray3))
                            }
                            .padding(14)

                            Divider().padding(.leading, 14)

                            HStack {
                                Text("Traducir a")
                                    .font(.system(size: 16))
                                Spacer()
                                Text(appState.subtitleSettings.targetLanguage)
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(.systemGray3))
                            }
                            .padding(14)
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .padding(.horizontal)
                    }

                    // Section: Estilo
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Estilo")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        HStack(spacing: 12) {
                            ForEach(SubtitleTheme.allCases, id: \.self) { theme in
                                Button {
                                    appState.subtitleSettings.theme = theme
                                } label: {
                                    VStack(spacing: 6) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(theme == .dark ? Color.black : (theme == .light ? Color.white : Color(.systemGray5)))
                                                .frame(height: 56)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(appState.subtitleSettings.theme == theme ? Color.blue : Color(.systemGray4), lineWidth: appState.subtitleSettings.theme == theme ? 2 : 1)
                                                )

                                            Text("Aa")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(theme == .dark ? .white : .black)
                                        }

                                        Text(theme.rawValue)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.primary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Section: Tamaño del texto
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tamaño del texto")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        VStack(spacing: 8) {
                            HStack {
                                Text("A")
                                    .font(.system(size: 13, weight: .medium))
                                Slider(value: $appState.subtitleSettings.fontSize, in: 14...28, step: 2)
                                Text("A")
                                    .font(.system(size: 22, weight: .bold))
                            }
                            .padding(14)
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .padding(.horizontal)
                    }

                    // Section: Posición
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Posición")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        HStack(spacing: 10) {
                            ForEach(SubtitlePosition.allCases, id: \.self) { pos in
                                Button {
                                    appState.subtitleSettings.position = pos
                                } label: {
                                    VStack(spacing: 6) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(.systemBackground))
                                                .frame(height: 48)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(appState.subtitleSettings.position == pos ? Color.blue : Color(.systemGray4), lineWidth: appState.subtitleSettings.position == pos ? 2 : 1)
                                                )

                                            // Miniature preview bar
                                            VStack {
                                                if pos == .top {
                                                    Capsule().fill(Color.blue).frame(width: 24, height: 4)
                                                    Spacer()
                                                } else if pos == .center {
                                                    Spacer()
                                                    Capsule().fill(Color.blue).frame(width: 24, height: 4)
                                                    Spacer()
                                                } else {
                                                    Spacer()
                                                    Capsule().fill(Color.blue).frame(width: 24, height: 4)
                                                }
                                            }
                                            .padding(6)
                                        }

                                        Text(pos.rawValue)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.primary)
                                    }
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Section: Translation Fidelity
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tipo de traducción")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)

                        Picker("Traducción", selection: $appState.subtitleSettings.translationType) {
                            ForEach(TranslationType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 10)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Subtítulos")
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
}

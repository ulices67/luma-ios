import SwiftUI

/// Offline Languages & AI Models Downloader View matching Image 3 Screen 9
public struct OfflineLanguagesView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var offlineManager: OfflineManager = OfflineManager.shared
    @ObservedObject var cloudflareService: CloudflareService = CloudflareService.shared
    @State private var updateAlert: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                // Section Cloudflare Edge OTA
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "cloud.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cloudflare Edge CDN")
                                .font(.system(size: 15, weight: .bold))
                            Text(cloudflareService.syncStatusMessage)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            Task {
                                _ = await cloudflareService.checkForUpdates()
                                updateAlert = true
                            }
                        } label: {
                            if cloudflareService.isCheckingUpdates {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Text("Comprobar")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.blue.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }

                // Section Storage Status
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Almacenamiento ocupado")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(offlineManager.totalInstalledStorageMB) MB")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        ProgressView(value: Double(offlineManager.totalInstalledStorageMB), total: 4000)
                            .tint(.blue)
                    }
                    .padding(.vertical, 4)
                }

                // Section Idiomas sin conexión
                Section(header: Text("Idiomas").font(.system(size: 13, weight: .bold, design: .rounded))) {
                    ForEach(offlineManager.languagePacks) { pack in
                        packRow(pack: pack)
                    }
                }

                // Section Modelos de Inteligencia Artificial
                Section(header: Text("Modelos neuronales en dispositivo").font(.system(size: 13, weight: .bold, design: .rounded))) {
                    ForEach(offlineManager.aiModels) { pack in
                        packRow(pack: pack)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Idiomas sin conexión")
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

    private func packRow(pack: LanguagePack) -> some View {
        HStack(spacing: 14) {
            Text(pack.flagEmoji)
                .font(.system(size: 26))

            VStack(alignment: .leading, spacing: 2) {
                Text(pack.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Text("\(pack.subtitle) · \(pack.formattedSize)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                if pack.isDownloading {
                    ProgressView(value: pack.downloadProgress, total: 1.0)
                        .tint(.blue)
                        .padding(.top, 2)
                }
            }

            Spacer()

            if pack.isInstalled {
                Text("Instalado")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(Capsule())
            } else if pack.isDownloading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Button {
                    offlineManager.startDownload(for: pack.id)
                } label: {
                    Text("Descargar")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

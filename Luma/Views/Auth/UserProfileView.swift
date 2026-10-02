import SwiftUI

public struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authService: AuthService = AuthService.shared
    @ObservedObject var cloudflareService: CloudflareService = CloudflareService.shared
    @State private var showUpdateAlert: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                // User Details Card
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 60, height: 60)
                            Text(String(authService.currentUser?.fullName.prefix(1) ?? "U"))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(authService.currentUser?.fullName ?? "Usuario")
                                    .font(.system(size: 18, weight: .bold))
                                if authService.currentUser?.isPro == true {
                                    Text("PRO")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue)
                                        .cornerRadius(6)
                                }
                            }

                            Text(authService.currentUser?.email ?? "")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)

                            Text("Autenticado con \(authService.currentUser?.authProvider.rawValue ?? "Apple")")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }

                // Cloudflare Edge & Updates Section
                Section(header: Text("Cloudflare Edge & Actualizaciones").font(.system(size: 12, weight: .bold))) {
                    HStack {
                        Image(systemName: "server.rack")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Servidor Edge")
                                .font(.system(size: 15))
                            Text(cloudflareService.syncStatusMessage)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if cloudflareService.isCheckingUpdates {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }

                    Button {
                        Task {
                            _ = await cloudflareService.checkForUpdates()
                            showUpdateAlert = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.blue)
                            Text("Buscar actualizaciones OTA")
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Image(systemName: "icloud.and.arrow.up")
                            .foregroundColor(.blue)
                        Text("Última sincronización")
                            .font(.system(size: 15))
                        Spacer()
                        Text(cloudflareService.lastSyncDate != nil ? "Reciente" : "Activa")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }

                // Session Actions
                Section {
                    Button(role: .destructive) {
                        authService.logout()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Cerrar Sesión")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Cuenta Luma")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
            .alert("Actualizaciones de Luma", isPresented: $showUpdateAlert) {
                Button("Entendido", role: .cancel) {}
            } message: {
                if let manifest = cloudflareService.lastUpdateManifest {
                    Text(manifest.updateAvailable
                         ? "Hay una nueva versión disponible (v\(manifest.latestAppVersion)).\n\(manifest.releaseNotes)"
                         : "Tu aplicación y modelos neuronales están actualizados en Cloudflare.")
                } else {
                    Text("Conectado con éxito a Cloudflare Edge.")
                }
            }
        }
    }
}

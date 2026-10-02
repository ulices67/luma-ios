import SwiftUI

public struct HomeView: View {
    @ObservedObject var appState: AppState = AppState.shared
    @ObservedObject var authService: AuthService = AuthService.shared
    @State private var searchText: String = ""
    @State private var showAuthSheet: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Header
                    HStack(alignment: .top) {
                        HStack(alignment: .center, spacing: 12) {
                            LumaLogoView(size: 40, showCardBackground: true, isAnimated: true)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Luma")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)

                                Text("Traducción & Detección en vivo")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        // User profile / Login button
                        Button {
                            showAuthSheet = true
                        } label: {
                            if let user = authService.currentUser {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 38, height: 38)
                                    Text(String(user.fullName.prefix(1)))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Search / Paste Link Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Buscar o pegar enlace...", text: $searchText)
                            .font(.system(size: 15))
                        Button {
                            // Paste link action
                        } label: {
                            Image(systemName: "link")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // 4 Quick Action Cards (2x2 Grid)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        // Música
                        actionCard(
                            title: "Música",
                            subtitle: "Reconoce canciones\ny muestra la letra",
                            icon: "music.note",
                            iconColor: .blue,
                            bgColor: Color.blue.opacity(0.12)
                        ) {
                            appState.openTrack(SampleData.blindingLights)
                        }

                        // Video
                        actionCard(
                            title: "Video",
                            subtitle: "Subtítulos en\ntiempo real",
                            icon: "play.rectangle.fill",
                            iconColor: .purple,
                            bgColor: Color.purple.opacity(0.12)
                        ) {
                            appState.openTrack(SampleData.interstellar)
                        }

                        // Micrófono
                        actionCard(
                            title: "Micrófono",
                            subtitle: "Traduce audio\nen vivo",
                            icon: "mic.fill",
                            iconColor: .green,
                            bgColor: Color.green.opacity(0.12)
                        ) {
                            appState.openListening()
                        }

                        // Archivo
                        actionCard(
                            title: "Archivo",
                            subtitle: "Abre un audio\no video",
                            icon: "folder.fill",
                            iconColor: .orange,
                            bgColor: Color.orange.opacity(0.12)
                        ) {
                            appState.selectedTab = .library
                        }
                    }
                    .padding(.horizontal)

                    // Recientes Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recientes")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            Spacer()
                            Button("Ver todo") {
                                appState.selectedTab = .library
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)

                        VStack(spacing: 8) {
                            ForEach(appState.recentTracks.prefix(3)) { track in
                                recentRow(track: track)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showAuthSheet) {
                if authService.isAuthenticated {
                    UserProfileView()
                } else {
                    LoginView()
                }
            }
        }
    }

    private func actionCard(
        title: String,
        subtitle: String,
        icon: String,
        iconColor: Color,
        bgColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(bgColor)
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func recentRow(track: MediaTrack) -> some View {
        Button {
            appState.openTrack(track)
        } label: {
            HStack(spacing: 14) {
                // Cover Art Thumbnail with gradient
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: track.gradientColors.map { Color(hex: $0) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: track.mediaType.systemIcon)
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 3) {
                    Text(track.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Text("\(track.artistOrCreator) · \(track.year)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color(.systemGray3))
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}

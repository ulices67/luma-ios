import SwiftUI

public enum LibraryFilter: String, CaseIterable {
    case all = "Todo"
    case music = "Música"
    case videos = "Videos"
    case podcasts = "Podcasts"
    case files = "Archivos"
}

/// Library and History View matching Image 3 Screen 10
public struct LibraryView: View {
    @ObservedObject var appState: AppState = AppState.shared
    @State private var selectedFilter: LibraryFilter = .all

    public init() {}

    private var filteredTracks: [MediaTrack] {
        switch selectedFilter {
        case .all:
            return SampleData.sampleLibrary
        case .music:
            return SampleData.sampleLibrary.filter { $0.mediaType == .music }
        case .videos:
            return SampleData.sampleLibrary.filter { $0.mediaType == .video }
        case .podcasts:
            return SampleData.sampleLibrary.filter { $0.mediaType == .podcast }
        case .files:
            return SampleData.sampleLibrary.filter { $0.mediaType == .file }
        }
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Capsule Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(LibraryFilter.allCases, id: \.self) { filter in
                            Button {
                                selectedFilter = filter
                            } label: {
                                Text(filter.rawValue)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(selectedFilter == filter ? .white : .secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(selectedFilter == filter ? Color.blue : Color(.secondarySystemBackground))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }

                // Track List
                List {
                    ForEach(filteredTracks) { track in
                        Button {
                            appState.openTrack(track)
                        } label: {
                            HStack(spacing: 14) {
                                // Thumbnail
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
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.85))
                                }
                                .frame(width: 46, height: 46)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(track.title)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text("\(track.artistOrCreator) · \(track.year)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                HStack(spacing: 6) {
                                    Image(systemName: track.mediaType == .music ? "music.note" : (track.mediaType == .video ? "video.fill" : "mic.fill"))
                                        .font(.system(size: 11))
                                    Text(track.relativeTimeString)
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(.secondary)

                                Image(systemName: "ellipsis")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.systemGray3))
                                    .padding(.leading, 6)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Biblioteca")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Options
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
    }
}

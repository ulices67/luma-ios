import Foundation
import Combine

public final class OfflineManager: ObservableObject {
    public static let shared = OfflineManager()

    @Published public var languagePacks: [LanguagePack] = SampleData.sampleLanguagePacks
    @Published public var aiModels: [LanguagePack] = SampleData.sampleAIModels

    private var cancellables = Set<AnyCancellable>()

    private init() {}

    /// Simulates download of an offline pack with progressive updates
    public func startDownload(for packId: String) {
        if let idx = languagePacks.firstIndex(where: { $0.id == packId }) {
            guard !languagePacks[idx].isInstalled, !languagePacks[idx].isDownloading else { return }
            languagePacks[idx].isDownloading = true
            languagePacks[idx].downloadProgress = 0.0

            Timer.publish(every: 0.2, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] timer in
                    guard let self = self, let currentIndex = self.languagePacks.firstIndex(where: { $0.id == packId }) else {
                        timer.upstream.connect().cancel()
                        return
                    }

                    if self.languagePacks[currentIndex].downloadProgress < 1.0 {
                        self.languagePacks[currentIndex].downloadProgress += 0.1
                    } else {
                        self.languagePacks[currentIndex].isDownloading = false
                        self.languagePacks[currentIndex].isInstalled = true
                        self.languagePacks[currentIndex].downloadProgress = 1.0
                        timer.upstream.connect().cancel()
                    }
                }
                .store(in: &cancellables)
        } else if let idx = aiModels.firstIndex(where: { $0.id == packId }) {
            guard !aiModels[idx].isInstalled, !aiModels[idx].isDownloading else { return }
            aiModels[idx].isDownloading = true
            aiModels[idx].downloadProgress = 0.0

            Timer.publish(every: 0.25, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] timer in
                    guard let self = self, let currentIndex = self.aiModels.firstIndex(where: { $0.id == packId }) else {
                        timer.upstream.connect().cancel()
                        return
                    }

                    if self.aiModels[currentIndex].downloadProgress < 1.0 {
                        self.aiModels[currentIndex].downloadProgress += 0.08
                    } else {
                        self.aiModels[currentIndex].isDownloading = false
                        self.aiModels[currentIndex].isInstalled = true
                        self.aiModels[currentIndex].downloadProgress = 1.0
                        timer.upstream.connect().cancel()
                    }
                }
                .store(in: &cancellables)
        }
    }

    public func removePack(id: String) {
        if let idx = languagePacks.firstIndex(where: { $0.id == id }) {
            languagePacks[idx].isInstalled = false
            languagePacks[idx].downloadProgress = 0.0
        } else if let idx = aiModels.firstIndex(where: { $0.id == id }) {
            aiModels[idx].isInstalled = false
            aiModels[idx].downloadProgress = 0.0
        }
    }

    public var totalInstalledStorageMB: Int {
        let langSize = languagePacks.filter { $0.isInstalled }.reduce(0) { $0 + $1.sizeMB }
        let modelSize = aiModels.filter { $0.isInstalled }.reduce(0) { $0 + $1.sizeMB }
        return langSize + modelSize
    }
}

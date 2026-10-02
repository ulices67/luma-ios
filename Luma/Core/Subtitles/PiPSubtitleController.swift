import Foundation
import AVKit
import CoreMedia
import Combine

/// Controller managing the iOS system Picture-in-Picture window floating over Spotify, YouTube, etc.
public final class PiPSubtitleController: NSObject, ObservableObject {
    public static let shared = PiPSubtitleController()

    @Published public var isPiPActive: Bool = false
    @Published public var isPiPSupported: Bool = AVPictureInPictureController.isPictureInPictureSupported()

    public let displayLayer = AVSampleBufferDisplayLayer()
    private var pipController: AVPictureInPictureController?
    private var cancellables = Set<AnyCancellable>()
    private var frameCount: Int64 = 0

    override private init() {
        super.init()
        setupDisplayLayer()
        setupPiPController()
        bindSubtitleEngine()
    }

    private func setupDisplayLayer() {
        displayLayer.videoGravity = .resizeAspect
    }

    private func setupPiPController() {
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return }

        let contentSource = AVPictureInPictureController.ContentSource(
            sampleBufferDisplayLayer: displayLayer,
            playbackDelegate: self
        )

        let controller = AVPictureInPictureController(contentSource: contentSource)
        controller.delegate = self
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        self.pipController = controller
    }

    private func bindSubtitleEngine() {
        SubtitleEngine.shared.$activeCue
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cue in
                guard let self = self, self.isPiPActive else { return }
                let original = cue?.source ?? "Escuchando audio..."
                let translated = cue?.translation ?? "Traducción sincronizada"
                let activeWord: String? = nil

                self.pushSubtitleFrame(originalText: original, activeWord: activeWord, translatedText: translated)
            }
            .store(in: &cancellables)
    }

    public func startPiP() {
        guard let controller = pipController, !controller.isPictureInPictureActive else { return }
        controller.startPictureInPicture()
    }

    public func stopPiP() {
        guard let controller = pipController, controller.isPictureInPictureActive else { return }
        controller.stopPictureInPicture()
    }

    public func pushSubtitleFrame(originalText: String, activeWord: String?, translatedText: String) {
        frameCount += 1
        let pts = CMTime(value: frameCount, timescale: 30)

        guard let sampleBuffer = SubtitleRenderer.shared.renderSampleBuffer(
            originalText: originalText,
            activeWord: activeWord,
            translatedText: translatedText,
            timestamp: pts
        ) else {
            return
        }

        displayLayer.enqueue(sampleBuffer)
    }
}

extension PiPSubtitleController: AVPictureInPictureSampleBufferPlaybackDelegate {
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {
        if playing {
            SubtitleEngine.shared.start()
        } else {
            SubtitleEngine.shared.stop()
        }
    }

    public func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
        return CMTimeRange(start: .zero, duration: CMTime(value: 3600, timescale: 1))
    }

    public func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
        return !SubtitleEngine.shared.isRunning
    }

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {}

    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, skipByInterval skipInterval: CMTime, completion: @escaping () -> Void) {
        SubtitleEngine.shared.seek(to: SubtitleEngine.shared.currentTime + skipInterval.seconds)
        completion()
    }
}

extension PiPSubtitleController: AVPictureInPictureControllerDelegate {
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        DispatchQueue.main.async {
            self.isPiPActive = true
        }
    }

    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        DispatchQueue.main.async {
            self.isPiPActive = false
        }
    }
}

import Foundation
import CoreMedia
import CoreGraphics
import CoreVideo
import UIKit

/// Renders subtitle cues into CVPixelBuffers and CMSampleBuffers for AVSampleBufferDisplayLayer PiP
public final class SubtitleRenderer {
    public static let shared = SubtitleRenderer()

    private let width: Int = 720
    private let height: Int = 240

    private init() {}

    /// Renders a subtitle frame into a CMSampleBuffer ready for PiP display
    public func renderSampleBuffer(
        originalText: String,
        activeWord: String?,
        translatedText: String,
        timestamp: CMTime
    ) -> CMSampleBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            attrs as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            return nil
        }

        // Draw dark translucent background
        context.setFillColor(UIColor(red: 0.08, green: 0.10, blue: 0.14, alpha: 1.0).cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Draw rounded banner box
        let boxRect = CGRect(x: 20, y: 20, width: width - 40, height: height - 40)
        let path = UIBezierPath(roundedRect: boxRect, cornerRadius: 20)
        context.setFillColor(UIColor(red: 0.12, green: 0.15, blue: 0.22, alpha: 1.0).cgColor)
        context.addPath(path.cgPath)
        context.fillPath()

        // Push UIKit context for text rendering
        UIGraphicsPushContext(context)

        // Header: "Luma Traducción en vivo"
        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor(red: 0.25, green: 0.55, blue: 1.0, alpha: 1.0)
        ]
        "● Traducción en vivo".draw(at: CGPoint(x: 40, y: 40), withAttributes: headerAttrs)

        // Line 1: Original text
        let origAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        originalText.draw(in: CGRect(x: 40, y: 80, width: width - 80, height: 60), withAttributes: origAttrs)

        // Line 2: Spanish translated text
        let transAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor(red: 0.45, green: 0.75, blue: 1.0, alpha: 1.0)
        ]
        translatedText.draw(in: CGRect(x: 40, y: 140, width: width - 80, height: 60), withAttributes: transAttrs)

        UIGraphicsPopContext()

        // Wrap into CMSampleBuffer
        var timingInfo = CMSampleTimingInfo(
            duration: CMTime(value: 1, timescale: 30),
            presentationTimeStamp: timestamp,
            decodeTimeStamp: .invalid
        )

        var formatDesc: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: buffer, formatDescriptionOut: &formatDesc)

        guard let format = formatDesc else { return nil }

        var sampleBuffer: CMSampleBuffer?
        CMSampleBufferCreateReadyWithImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: buffer,
            formatDescription: format,
            sampleTiming: &timingInfo,
            sampleBufferOut: &sampleBuffer
        )

        return sampleBuffer
    }
}

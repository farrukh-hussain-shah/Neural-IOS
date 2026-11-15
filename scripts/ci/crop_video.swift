// Keeps only the bottom part of a screen recording (height = width x ratio) and only the moments
// where the keyboard panel is on screen: crop_video.swift <input> <output> <height/width ratio>
import AVFoundation
import CoreGraphics
import Foundation

enum KeyboardVideoCropper {
    static let step = 0.25

    static func run(arguments: [String]) -> Int32 {
        guard arguments.count == 4, let ratio = Double(arguments[3]), ratio > 0 else {
            return fail("usage: crop_video.swift <input> <output> <height/width ratio>")
        }
        let input = URL(fileURLWithPath: arguments[1])
        let output = URL(fileURLWithPath: arguments[2])
        try? FileManager.default.removeItem(at: output)

        let asset = AVURLAsset(url: input)
        guard let sourceTrack = asset.tracks(withMediaType: .video).first else {
            return fail("no video track")
        }
        let size = sourceTrack.naturalSize.applying(sourceTrack.preferredTransform)
        let width = abs(size.width)
        let height = abs(size.height)
        let cropHeight = min(height, (width * CGFloat(ratio) / 2).rounded() * 2)

        let ranges = visibleRanges(of: asset, width: width, cropHeight: cropHeight)
        print("Keyboard visible in \(ranges.count) segments")
        guard !ranges.isEmpty else {
            return fail("keyboard never visible in the recording")
        }

        let composition = AVMutableComposition()
        guard let track = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            return fail("cannot create composition track")
        }
        var cursor = CMTime.zero
        for range in ranges {
            try? track.insertTimeRange(range, of: sourceTrack, at: cursor)
            cursor = CMTimeAdd(cursor, range.duration)
        }

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
        let layer = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        layer.setTransform(sourceTrack.preferredTransform.translatedBy(x: 0, y: -(height - cropHeight)), at: .zero)
        instruction.layerInstructions = [layer]

        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: width, height: cropHeight)
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.instructions = [instruction]

        guard let export = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHEVCHighestQuality) else {
            return fail("cannot create export session")
        }
        export.videoComposition = videoComposition
        export.outputURL = output
        export.outputFileType = .mp4

        let done = DispatchSemaphore(value: 0)
        export.exportAsynchronously { done.signal() }
        done.wait()

        guard export.status == .completed else {
            return fail("export failed: \(String(describing: export.error))")
        }
        print("Keyboard video: \(Int(width))x\(Int(cropHeight)), \(String(format: "%.1f", CMTimeGetSeconds(cursor))) s")
        return 0
    }

    static func visibleRanges(of asset: AVAsset, width: CGFloat, cropHeight: CGFloat) -> [CMTimeRange] {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 330, height: 1000)
        generator.requestedTimeToleranceBefore = CMTime(value: 1, timescale: 10)
        generator.requestedTimeToleranceAfter = CMTime(value: 1, timescale: 10)

        let duration = CMTimeGetSeconds(asset.duration)
        var ranges: [CMTimeRange] = []
        var rangeStart: Double?
        var time = 0.0
        while time < duration {
            var visible = false
            if let image = try? generator.copyCGImage(at: CMTime(seconds: time, preferredTimescale: 600), actualTime: nil) {
                visible = panelVisible(in: image, sourceWidth: width, cropHeight: cropHeight)
            }
            if visible, rangeStart == nil {
                rangeStart = time
            } else if !visible, let start = rangeStart {
                ranges.append(range(from: start, to: time))
                rangeStart = nil
            }
            time += step
        }
        if let start = rangeStart {
            ranges.append(range(from: start, to: duration))
        }
        return ranges
    }

    static func range(from start: Double, to end: Double) -> CMTimeRange {
        CMTimeRange(
            start: CMTime(seconds: start, preferredTimescale: 600),
            end: CMTime(seconds: end, preferredTimescale: 600)
        )
    }

    static func panelVisible(in image: CGImage, sourceWidth: CGFloat, cropHeight: CGFloat) -> Bool {
        let imageWidth = CGFloat(image.width)
        let imageHeight = CGFloat(image.height)
        let sampleY = imageHeight - cropHeight * (imageWidth / sourceWidth) * 0.2
        for sampleX in [CGFloat(1), imageWidth - 2] {
            guard let rgb = pixel(of: image, x: sampleX, y: sampleY) else { return false }
            let low = min(rgb.0, rgb.1, rgb.2)
            let high = max(rgb.0, rgb.1, rgb.2)
            guard low >= 185, high <= 250, high - low <= 16 else { return false }
        }
        return true
    }

    static func pixel(of image: CGImage, x: CGFloat, y: CGFloat) -> (Int, Int, Int)? {
        var bytes = [UInt8](repeating: 0, count: 4)
        let imageHeight = CGFloat(image.height)
        let drawn = bytes.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: 1,
                height: 1,
                bitsPerComponent: 8,
                bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            context.draw(image, in: CGRect(x: -x, y: -(imageHeight - y - 1), width: CGFloat(image.width), height: imageHeight))
            return true
        }
        guard drawn else { return nil }
        return (Int(bytes[0]), Int(bytes[1]), Int(bytes[2]))
    }

    static func fail(_ message: String) -> Int32 {
        FileHandle.standardError.write(Data((message + "\n").utf8))
        return 1
    }
}

exit(KeyboardVideoCropper.run(arguments: CommandLine.arguments))

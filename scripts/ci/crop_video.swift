// Keeps only the bottom part of a screen recording (height = width x ratio) and only the moments
// where the keyboard panel is on screen: crop_video.swift <input> <output> <height/width ratio>
import AVFoundation
import CoreGraphics
import Foundation

func fail(_ message: String) -> Never {
    FileHandle.standardError.write((message + "\n").data(using: .utf8)!)
    exit(1)
}

let arguments = CommandLine.arguments
guard arguments.count == 4, let ratio = Double(arguments[3]), ratio > 0 else {
    fail("usage: crop_video.swift <input> <output> <height/width ratio>")
}

let input = URL(fileURLWithPath: arguments[1])
let output = URL(fileURLWithPath: arguments[2])
try? FileManager.default.removeItem(at: output)

let asset = AVURLAsset(url: input)
guard let sourceTrack = asset.tracks(withMediaType: .video).first else { fail("no video track") }

let size = sourceTrack.naturalSize.applying(sourceTrack.preferredTransform)
let width = abs(size.width)
let height = abs(size.height)
let cropHeight = min(height, (width * ratio / 2).rounded() * 2)

func panelVisible(in image: CGImage) -> Bool {
    let imageHeight = CGFloat(image.height)
    let scale = CGFloat(image.width) / width
    let samples = [
        CGPoint(x: 1, y: imageHeight - cropHeight * scale * 0.2),
        CGPoint(x: CGFloat(image.width) - 2, y: imageHeight - cropHeight * scale * 0.2)
    ]
    for point in samples {
        var pixel = [UInt8](repeating: 0, count: 4)
        let drawn = pixel.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            context.draw(image, in: CGRect(
                x: -point.x, y: -(imageHeight - point.y - 1),
                width: CGFloat(image.width), height: imageHeight
            ))
            return true
        }
        guard drawn else { return false }
        let channels = pixel[0..<3].map(Int.init)
        guard let low = channels.min(), let high = channels.max(), low >= 185, high <= 250, high - low <= 16 else {
            return false
        }
    }
    return true
}

let generator = AVAssetImageGenerator(asset: asset)
generator.appliesPreferredTrackTransform = true
generator.maximumSize = CGSize(width: 330, height: 330 * height / width)
generator.requestedTimeToleranceBefore = CMTime(value: 1, timescale: 10)
generator.requestedTimeToleranceAfter = CMTime(value: 1, timescale: 10)

let step = 0.25
let duration = asset.duration.seconds
var ranges: [CMTimeRange] = []
var rangeStart: Double?
var time = 0.0
while time < duration {
    let visible = (try? generator.copyCGImage(at: CMTime(seconds: time, preferredTimescale: 600), actualTime: nil))
        .map(panelVisible(in:)) ?? false
    if visible, rangeStart == nil {
        rangeStart = time
    } else if !visible, let start = rangeStart {
        ranges.append(CMTimeRange(start: CMTime(seconds: start, preferredTimescale: 600), end: CMTime(seconds: time, preferredTimescale: 600)))
        rangeStart = nil
    }
    time += step
}
if let start = rangeStart {
    ranges.append(CMTimeRange(start: CMTime(seconds: start, preferredTimescale: 600), end: asset.duration))
}
print("Sampled \(Int(duration / step)) frames, keyboard visible in \(ranges.count) segments")
guard !ranges.isEmpty else { fail("keyboard never visible in the recording") }

let composition = AVMutableComposition()
guard let track = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    fail("cannot create composition track")
}
var cursor = CMTime.zero
for range in ranges {
    try? track.insertTimeRange(range, of: sourceTrack, at: cursor)
    cursor = cursor + range.duration
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
    fail("cannot create export session")
}
export.videoComposition = videoComposition
export.outputURL = output
export.outputFileType = .mp4

let done = DispatchSemaphore(value: 0)
export.exportAsynchronously { done.signal() }
done.wait()

guard export.status == .completed else { fail("export failed: \(String(describing: export.error))") }
print("Keyboard video: \(Int(width))x\(Int(cropHeight)), \(ranges.count) segments, \(String(format: "%.1f", cursor.seconds)) s")

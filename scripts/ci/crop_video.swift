// Crops the bottom part of a screen recording: crop_video.swift <input> <output> <height/width ratio>
import AVFoundation
import Foundation

let arguments = CommandLine.arguments
guard arguments.count == 4, let ratio = Double(arguments[3]), ratio > 0 else {
    FileHandle.standardError.write("usage: crop_video.swift <input> <output> <height/width ratio>\n".data(using: .utf8)!)
    exit(2)
}

let input = URL(fileURLWithPath: arguments[1])
let output = URL(fileURLWithPath: arguments[2])
try? FileManager.default.removeItem(at: output)

let asset = AVURLAsset(url: input)
guard let track = asset.tracks(withMediaType: .video).first else {
    FileHandle.standardError.write("no video track\n".data(using: .utf8)!)
    exit(1)
}

let size = track.naturalSize.applying(track.preferredTransform)
let width = abs(size.width)
let height = abs(size.height)
let cropHeight = min(height, (width * ratio / 2).rounded() * 2)

let instruction = AVMutableVideoCompositionInstruction()
instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
let layer = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
layer.setTransform(track.preferredTransform.translatedBy(x: 0, y: -(height - cropHeight)), at: .zero)
instruction.layerInstructions = [layer]

let composition = AVMutableVideoComposition()
composition.renderSize = CGSize(width: width, height: cropHeight)
composition.frameDuration = CMTime(value: 1, timescale: 30)
composition.instructions = [instruction]

guard let export = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHEVCHighestQuality) else {
    FileHandle.standardError.write("cannot create export session\n".data(using: .utf8)!)
    exit(1)
}
export.videoComposition = composition
export.outputURL = output
export.outputFileType = .mp4

let done = DispatchSemaphore(value: 0)
export.exportAsynchronously { done.signal() }
done.wait()

guard export.status == .completed else {
    FileHandle.standardError.write("export failed: \(String(describing: export.error))\n".data(using: .utf8)!)
    exit(1)
}
print("Cropped video: \(Int(width))x\(Int(cropHeight))")

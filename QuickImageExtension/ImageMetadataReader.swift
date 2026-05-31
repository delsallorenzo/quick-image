import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

struct ImageMetadata {
    let width: Int
    let height: Int
    let fileSize: Int64
    let dpiWidth: Double
    let dpiHeight: Double
    let colorProfile: String
    let colorSpace: String
    let bitDepth: Int
    let format: String
    let hasAlpha: Bool
    let captureDate: String?
    let camera: String?
    let lens: String?
}

enum ImageMetadataReader {

    static func read(from url: URL) -> ImageMetadata? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        guard let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else { return nil }

        let width  = (props[kCGImagePropertyPixelWidth]  as? Int) ?? 0
        let height = (props[kCGImagePropertyPixelHeight] as? Int) ?? 0

        let dpiW = (props[kCGImagePropertyDPIWidth]  as? Double) ?? 72.0
        let dpiH = (props[kCGImagePropertyDPIHeight] as? Double) ?? 72.0

        let depth = (props[kCGImagePropertyDepth] as? Int) ?? 8

        let hasAlpha = (props[kCGImagePropertyHasAlpha] as? Bool) ?? false

        let colorModel = (props[kCGImagePropertyColorModel] as? String) ?? "Unknown"
        let profileName = (props[kCGImagePropertyProfileName] as? String) ?? colorModel

        let colorSpace = resolveColorSpace(from: props)

        let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64) ?? 0

        let format = resolveFormat(from: source, url: url)

        let exif = props[kCGImagePropertyExifDictionary] as? [CFString: Any]
        let tiff = props[kCGImagePropertyTIFFDictionary] as? [CFString: Any]

        let captureDate = exif?[kCGImagePropertyExifDateTimeOriginal] as? String
        let make  = tiff?[kCGImagePropertyTIFFMake]  as? String
        let model = tiff?[kCGImagePropertyTIFFModel] as? String
        let camera: String? = [make, model].compactMap { $0 }.joined(separator: " ").nilIfEmpty

        let lensModel = exif?[kCGImagePropertyExifLensModel] as? String

        return ImageMetadata(
            width: width,
            height: height,
            fileSize: fileSize,
            dpiWidth: dpiW,
            dpiHeight: dpiH,
            colorProfile: profileName,
            colorSpace: colorSpace,
            bitDepth: depth,
            format: format,
            hasAlpha: hasAlpha,
            captureDate: captureDate,
            camera: camera,
            lens: lensModel
        )
    }

    private static func resolveColorSpace(from props: [CFString: Any]) -> String {
        if let name = props[kCGImagePropertyProfileName] as? String {
            let lower = name.lowercased()
            if lower.contains("display p3")   { return "Display P3" }
            if lower.contains("p3")           { return "P3" }
            if lower.contains("prophoto")     { return "ProPhoto RGB" }
            if lower.contains("adobe rgb")    { return "Adobe RGB" }
            if lower.contains("srgb") || lower.contains("sRGB") { return "sRGB" }
            if lower.contains("cmyk")         { return "CMYK" }
            if lower.contains("gray")         { return "Grayscale" }
            return name
        }
        if let model = props[kCGImagePropertyColorModel] as? String {
            switch model {
            case "RGB":  return "sRGB"
            case "CMYK": return "CMYK"
            case "Gray": return "Grayscale"
            case "Lab":  return "L*a*b*"
            default:     return model
            }
        }
        return "Unknown"
    }

    private static func resolveFormat(from source: CGImageSource, url: URL) -> String {
        if let uti = CGImageSourceGetType(source) as String? {
            if let type = UTType(uti) {
                if type.conforms(to: .jpeg)       { return "JPEG" }
                if type.conforms(to: .png)        { return "PNG" }
                if type.conforms(to: .tiff)       { return "TIFF" }
                if type.conforms(to: .gif)        { return "GIF" }
                if type.conforms(to: .heic)       { return "HEIC" }
                if type.conforms(to: .webP)       { return "WebP" }
                if type.identifier == "com.adobe.raw-image" { return "RAW" }
                return type.localizedDescription ?? uti
            }
        }
        return url.pathExtension.uppercased()
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}

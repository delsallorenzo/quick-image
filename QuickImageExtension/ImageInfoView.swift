import SwiftUI

struct ImageInfoView: View {

    let metadata: ImageMetadata
    let filename: String

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            infoBar
        }
    }

    private var infoBar: some View {
        HStack(alignment: .center, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 1) {
                    pill(label: "Size", value: "\(metadata.width) × \(metadata.height) px")
                    divider
                    pill(label: "File", value: formattedFileSize)
                    divider
                    pill(label: "DPI", value: formattedDPI)
                    divider
                    pill(label: "Format", value: formatValue)
                    divider
                    pill(label: "Color", value: metadata.colorSpace)
                    divider
                    pill(label: "Profile", value: metadata.colorProfile)
                    divider
                    pill(label: "Depth", value: "\(metadata.bitDepth)-bit\(metadata.hasAlpha ? " + α" : "")")
                    if let date = metadata.captureDate {
                        divider
                        pill(label: "Captured", value: formattedDate(date))
                    }
                    if let camera = metadata.camera {
                        divider
                        pill(label: "Camera", value: camera)
                    }
                    if let lens = metadata.lens {
                        divider
                        pill(label: "Lens", value: lens)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Divider().opacity(0.3)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.15))
            .frame(width: 1, height: 28)
            .padding(.horizontal, 8)
    }

    private func pill(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
    }

    private var formattedFileSize: String {
        let kb = Double(metadata.fileSize) / 1024
        if kb < 1024 {
            return String(format: "%.0f KB", kb)
        }
        return String(format: "%.2f MB", kb / 1024)
    }

    private var formattedDPI: String {
        if metadata.dpiWidth == metadata.dpiHeight {
            return "\(Int(metadata.dpiWidth)) dpi"
        }
        return "\(Int(metadata.dpiWidth)) × \(Int(metadata.dpiHeight)) dpi"
    }

    private var formatValue: String {
        metadata.format
    }

    private func formattedDate(_ raw: String) -> String {
        // EXIF format: "2024:05:12 14:30:00"
        let parts = raw.components(separatedBy: " ")
        guard let datePart = parts.first else { return raw }
        let components = datePart.components(separatedBy: ":")
        guard components.count == 3 else { return raw }
        return "\(components[2])/\(components[1])/\(components[0])"
    }
}

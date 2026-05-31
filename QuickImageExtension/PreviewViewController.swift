import Cocoa
import Quartz
import SwiftUI

class PreviewViewController: NSViewController, QLPreviewingController {

    override func loadView() {
        let v = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.black.cgColor
        self.view = v
    }

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }

        guard let image = NSImage(contentsOf: url) else {
            handler(nil)
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { handler(nil); return }

            let iv = NSImageView()
            iv.image = image
            iv.imageScaling = .scaleProportionallyUpOrDown
            iv.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(iv)
            NSLayoutConstraint.activate([
                iv.topAnchor.constraint(equalTo: self.view.topAnchor),
                iv.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                iv.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                iv.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            ])

            if let metadata = ImageMetadataReader.read(from: url) {
                let infoView = ImageInfoView(metadata: metadata, filename: url.lastPathComponent)
                let hosting = NSHostingView(rootView: infoView)
                hosting.translatesAutoresizingMaskIntoConstraints = false
                hosting.layer?.isOpaque = false
                self.view.addSubview(hosting)
                NSLayoutConstraint.activate([
                    hosting.topAnchor.constraint(equalTo: self.view.topAnchor),
                    hosting.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    hosting.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                    hosting.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                ])
            }

            handler(nil)
        }
    }
}

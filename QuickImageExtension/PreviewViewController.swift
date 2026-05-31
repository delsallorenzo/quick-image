import Cocoa
import Quartz
import SwiftUI

class PreviewViewController: NSViewController, QLPreviewingController {

    private var imageView: NSImageView?
    private var infoHostingView: NSHostingView<ImageInfoView>?

    override func loadView() {
        self.view = NSView()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.black.cgColor
    }

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        guard let image = NSImage(contentsOf: url) else {
            handler(nil)
            return
        }

        // Image view — fills the whole preview
        let iv = NSImageView(frame: view.bounds)
        iv.image = image
        iv.imageScaling = .scaleProportionallyUpOrDown
        iv.autoresizingMask = [.width, .height]
        view.addSubview(iv)
        self.imageView = iv

        // Metadata overlay
        if let metadata = ImageMetadataReader.read(from: url) {
            let infoView = ImageInfoView(metadata: metadata, filename: url.lastPathComponent)
            let hosting = NSHostingView(rootView: infoView)
            hosting.frame = view.bounds
            hosting.autoresizingMask = [.width, .height]
            hosting.layer?.isOpaque = false
            view.addSubview(hosting)
            self.infoHostingView = hosting
        }

        handler(nil)
    }
}

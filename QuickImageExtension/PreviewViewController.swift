import Cocoa
import Quartz
import SwiftUI

class PreviewViewController: NSViewController, QLPreviewingController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
    }

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        guard let image = NSImage(contentsOf: url) else {
            handler(nil)
            return
        }

        // Image view — fills the whole preview using Auto Layout
        let iv = NSImageView()
        iv.image = image
        iv.imageScaling = .scaleProportionallyUpOrDown
        iv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iv)
        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: view.topAnchor),
            iv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            iv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Metadata overlay
        if let metadata = ImageMetadataReader.read(from: url) {
            let infoView = ImageInfoView(metadata: metadata, filename: url.lastPathComponent)
            let hosting = NSHostingView(rootView: infoView)
            hosting.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(hosting)
            NSLayoutConstraint.activate([
                hosting.topAnchor.constraint(equalTo: view.topAnchor),
                hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                hosting.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }

        handler(nil)
    }
}

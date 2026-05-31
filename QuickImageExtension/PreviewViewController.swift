import Cocoa
import Quartz
import SwiftUI

class PreviewViewController: NSViewController, QLPreviewingController {

    private var imageView: NSImageView?
    private var hostingView: NSHostingView<ImageInfoView>?

    override func viewDidLoad() {
        super.viewDidLoad()

        let iv = NSImageView()
        iv.imageScaling = .scaleProportionallyUpOrDown
        iv.imageAlignment = .alignCenter
        iv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iv)
        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: view.topAnchor),
            iv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            iv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        imageView = iv
    }

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        let accessed = url.startAccessingSecurityScopedResource()
        defer { if accessed { url.stopAccessingSecurityScopedResource() } }

        guard let image = NSImage(contentsOf: url) else {
            handler(nil)
            return
        }
        imageView?.image = image

        if let metadata = ImageMetadataReader.read(from: url) {
            let filename = url.lastPathComponent
            let infoView = ImageInfoView(metadata: metadata, filename: filename)
            let hosting = NSHostingView(rootView: infoView)
            hosting.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(hosting)
            NSLayoutConstraint.activate([
                hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                hosting.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
            hostingView = hosting
        }

        handler(nil)
    }
}

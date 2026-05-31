import Cocoa
import Quartz
import SwiftUI

class PreviewViewController: NSViewController, QLPreviewingController {

    override func loadView() {
        let v = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.red.cgColor  // diagnostic: should appear red
        self.view = v
    }

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        handler(nil)
    }
}

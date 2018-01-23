//
//  DownloadingViewItem.swift
//  BandcampWeekly
//
//  Created by Kin on 1/18/18.
//  Copyright © 2018 Muo.io. All rights reserved.
//

import Cocoa

protocol DownloadingViewDelegate: class {
    func delete(item: DownloadingViewItem);
}

class DownloadingViewItem: NSCollectionViewItem {


    @IBOutlet weak var image: NSImageView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var nameLabel: NSTextFieldCell!
    @IBOutlet weak var progressLabel: NSTextFieldCell!
    @IBOutlet weak var folderButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!

    weak var delegate: DownloadingViewDelegate?

    var model: DownloadingModel?
    var index: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        progressIndicator.usesThreadedAnimation = true
        progressIndicator.increment(by: 0.01)
        progressIndicator.minValue = 0
        progressIndicator.maxValue = 100
        folderButton.isEnabled = false
        render()
    }

    func render() {
        if nil == model {
            return
        }

        let track = model?.track

        nameLabel.title = (track?.title)! + " / " + (track?.albumTitle)!

        model?.image {
            imagePath in
            let image = NSImage(contentsOfFile: imagePath)
            image?.size = NSSize(width: 40, height: 40)
            self.image.image = NSImage(contentsOfFile: imagePath)
        }.progress {
            percent in
            self.progressIndicator.doubleValue = percent
            self.progressIndicator.startAnimation(self)
            self.progressLabel.title = "\(percent) %"
        }.completed {
            fileURL in
            if nil != fileURL {
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    self.folderButton.isEnabled = true
                }
            }
        }
    }

    @IBAction func removeDownloading(_ sender: Any) {
        delegate?.delete(item: self)
    }

    @IBAction func openFolder(_ sender: Any) {
        if nil != model?.fileURL {
            NSWorkspace.shared.activateFileViewerSelecting([model!.fileURL!])
        }
    }

    override func viewDidAppear() {
        render()
    }

}

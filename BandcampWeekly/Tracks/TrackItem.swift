//
//  TrackItem.swift
//  BandcampWeekly
//
//  Created by Kin on 1/23/18.
//  Copyright © 2018 Muo.io. All rights reserved.
//

import Cocoa
import Foundation
import AppKit

class TrackItem: NSCollectionViewItem {

    @IBOutlet weak var image: NSImageView!
    @IBOutlet weak var trackName: NSTextFieldCell!
    @IBOutlet weak var byName: NSTextFieldCell!
    var model: TrackModel?
    var index: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        let border = CALayer()
        border.backgroundColor = BCColor.border?.cgColor
        border.frame = NSMakeRect(
                0,
                0,
                (self.view.layer?.frame.width)!,
                1
        )
        self.view.layer?.addSublayer(border)
        trackName.backgroundColor = NSColor.clear
        byName.backgroundColor = NSColor.clear
        render()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        render()
    }

    func render() {
        if nil == model {
            return
        }
        DispatchQueue.main.async {
            ImageCache.image(url: self.model!.trackArtImageUrl) {
                image in
                self.image.image = image
            }
        }
        trackName.title = "\(model!.title) / \(model!.albumTitle)"
        byName.title = "By \(model!.artist)"
    }

    func hover() {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = BCColor.hover?.cgColor
    }

    func normal() {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = BCColor.white?.cgColor
    }
}

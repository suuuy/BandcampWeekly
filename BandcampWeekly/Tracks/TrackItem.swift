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
            self.image.image = NSImage(contentsOf: URL(string: self.model!.imageUrl100)!)
        }
        trackName.title = "\(model!.title) / \(model!.albumTitle)"
        byName.title = "By \(model!.artist)"
    }

}

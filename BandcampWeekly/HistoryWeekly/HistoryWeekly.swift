//
//  HistoryWeekly.swift
//  BandcampWeekly
//
//  Created by Kin on 1/25/18.
//  Copyright © 2018 Muo.io. All rights reserved.
//

import Cocoa

class HistoryWeekly: NSCollectionViewItem {
    @IBOutlet weak var image: NSButton!
    @IBOutlet weak var label: NSTextFieldCell!
    @IBOutlet weak var numButton: NSButton!
    var model: HistoryModel?
    var index: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
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
            ImageCache.image(url: self.model!.imageUrl) {
                image in
                self.image.image = image
            }
        }
        label.title = (model?.desc)!
        numButton.isBordered = false //Important
        numButton.wantsLayer = true
        numButton.layer?.backgroundColor = NSColor((model?.buttonColor)!)?.cgColor

        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center

        numButton.attributedTitle = NSAttributedString(
                string: (model?.id)!,
                attributes: [
                    NSAttributedStringKey.foregroundColor: BCColor.white,
                    NSAttributedStringKey.paragraphStyle: pstyle
                ]
        )
    }

    @IBAction func openWeekly(_ sender: Any) {
    }
}

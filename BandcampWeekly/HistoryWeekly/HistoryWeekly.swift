//
//  HistoryWeekly.swift
//  BandcampWeekly
//
//  Created by Kin on 1/25/18.
//  Copyright © 2018 Muo.io. All rights reserved.
//

import Cocoa
import Kingfisher


class HistoryWeekly: NSCollectionViewItem {
    @IBOutlet weak var image: NSButton!
    @IBOutlet weak var label: NSTextFieldCell!
    @IBOutlet weak var numButton: NSButton!
    @IBOutlet weak var indicator: NSProgressIndicator!
    let bcRequest = BandcampRequest()
    let pstyle = NSMutableParagraphStyle()
    var model: HistoryModel? {
        didSet {
            if let model = model {

                image.kf.setImage(with: URL(string: model.imageUrl))
                label.title = model.desc

                numButton.isBordered = false //Important
                numButton.wantsLayer = true
                numButton.layer?.backgroundColor = NSColor(model.buttonColor)?.cgColor

                pstyle.alignment = .center
                numButton.attributedTitle = NSAttributedString(
                        string: "\(model.episodeNumber)",
                        attributes: [
                            NSAttributedStringKey.foregroundColor: BCColor.white,
                            NSAttributedStringKey.paragraphStyle: pstyle
                        ]
                )
            }
        }
    }
    var index: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true;
        indicator.usesThreadedAnimation = true
        indicator.increment(by: 0.01)
        indicator.startAnimation(self)
        indicator.isBezeled = true
        indicator.style = NSProgressIndicator.Style.spinning
        indicator.controlSize = NSControl.ControlSize.small
        indicator.sizeToFit()
    }

    @IBAction func openWeekly(_ sender: Any) {
        indicator.isHidden = false
        if nil != model!.episodeNumber {
            self.bcRequest.getWeekly(
                    number: self.model!.id,
                    progress: { progress in

                    },
                    closure: { weekly, history in
                        self.indicator.isHidden = true
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(
                                    name: NSNotification.Name.BCWeeklyLoaded,
                                    object: ["weekly": weekly, "history": history]
                            )
                        }
                    }
            );
        }
    }
}

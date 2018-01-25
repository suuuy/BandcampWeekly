//
// Created by Kin on 1/10/18.
// Copyright (c) 2018 Muo.io. All rights reserved.
//

import Cocoa
import Foundation

class AboutController: NSViewController {

    @IBOutlet weak var aboutLabel: NSTextFieldCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let info = Bundle.main.infoDictionary {
            if let version = info["CFBundleVersion"] as? String,
               let shortVersion = info["CFBundleShortVersionString"] as? String {
                aboutLabel.title = version + " (" + shortVersion + ")"
            }
        }
    }
}

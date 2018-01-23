//
//  PreferenceViewController.swift
//  BandcampWeekly
//
//  Created by Kin on 1/18/18.
//  Copyright © 2018 Muo.io. All rights reserved.
//

import Cocoa

class PreferenceViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.preferredContentSize = NSMakeSize(
                480, self.view.frame.size.height
        )
    }

    override func viewDidAppear() {
        self.parent?.view.window?.title = self.title!
    }

}

//
// Created by Kin on 1/5/18.
// Copyright (c) 2018 Muo.io. All rights reserved.
//

import Foundation
import Cocoa

class EventMonitor {
    var monitor: Any?
    let mask: NSEvent.EventTypeMask?
    let handler: (NSEvent?) -> Void

    init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    public func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask!, handler: handler)
    }

    public func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}

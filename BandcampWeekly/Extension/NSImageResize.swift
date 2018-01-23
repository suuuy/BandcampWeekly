//
// Created by Kin on 1/22/18.
// Copyright (c) 2018 Muo.io. All rights reserved.
//

import Foundation
import AppKit

extension NSImage {

    func resize(to size: NSSize) -> NSImage? {
        let img = NSImage(size: CGSize(width: size.width, height: size.height))

        img.lockFocus()
        let ctx = NSGraphicsContext.current
        ctx?.imageInterpolation = .high
        self.draw(in: NSMakeRect(0, 0, size.width, size.height),
                from: NSMakeRect(0, 0, size.width, size.height),
                operation: .copy,
                fraction: 1)
        img.unlockFocus()

        return img
    }

}
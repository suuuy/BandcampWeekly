//
//  AppDelegate.swift
//  BandcampWeekly
//
//  Created by Kin on 12/29/17.
//  Copyright © 2017 Muo.io. All rights reserved.
//

import Cocoa
import SwiftyJSON

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let indicatorHolder: NSView = NSView()
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var indicator: NSProgressIndicator?
    let popover = NSPopover()
    let player = AudioPlayer()
    let bcRequest = BandcampRequest()
    var eventMonitor: EventMonitor?


    func applicationDidFinishLaunching(_ aNotification: Notification) {

        if statusItem.button != nil {
            statusItem.button?.addSubview(getProgressIndicator(
                    frame: NSRect(
                            x: 6,
                            y: 3,
                            width: 18,
                            height: NSStatusItem.squareLength
                    ))
            )
        }

        bcRequest.getWeekly(
                number: "",
                progress: { progress in
                    if (progress >= 1) {
                        self.indicator?.isHidden = true
                    }
                },
                closure: { weekly in
                    if let button = self.statusItem.button {
                        button.subviews.removeAll(keepingCapacity: true)
                        button.image = BCImage.bar
                        button.action = #selector(self.togglePopover(_:))
                    }

                    let controller = ViewController.freshController()
                    self.popover.contentViewController = controller;
                    self.eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
                        if let strongSelf = self, strongSelf.popover.isShown {
                            strongSelf.closePopover(sender: event)
                        }
                    }
                    NotificationCenter.default.post(
                            name: NSNotification.Name.BCWeeklyLoaded,
                            object: weekly
                    )
                }
        );
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    @objc func togglePopover(_ sender: NSButton?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }

    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            eventMonitor?.start()
        }
    }

    func closePopover(sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }

    func getProgressIndicator(frame: NSRect) -> NSProgressIndicator {
        indicator = NSProgressIndicator(frame: frame)
        indicator?.isBezeled = true
        indicator?.style = NSProgressIndicator.Style.spinning
        indicator?.controlSize = NSControl.ControlSize.small
        indicator?.sizeToFit()
        indicator?.usesThreadedAnimation = false
        indicator?.startAnimation(self)
        indicator?.increment(by: 0.01)

        return indicator!;
    }
}


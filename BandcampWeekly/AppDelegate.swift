//
//  AppDelegate.swift
//  BandcampWeekly
//
//  Created by Kin on 12/29/17.
//  Copyright © 2017 Muo.io. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover = NSPopover()
    let bcRequest = BandcampRequest();
    var eventMonitor: EventMonitor?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("barImage"))
            button.action = #selector(togglePopover(_:))
            button.setButtonType(NSButton.ButtonType.multiLevelAccelerator)
        }
        var controller = ViewController.freshController();
        print(bcRequest.getData(closure: { bandcamp in
            controller.initData(bandcamp: bandcamp)
            self.popover.contentViewController = controller;
        }));
        popover.contentViewController = controller;
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application

    }

    @objc func togglePopover(_ sender: NSButton?) {
        print(sender?.action, NSEvent.pressedMouseButtons)
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }

    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            print("show popover")
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        eventMonitor?.start()
    }

    func closePopover(sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
}


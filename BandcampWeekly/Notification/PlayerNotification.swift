//
// Created by Kin on 2018/1/13.
// Copyright (c) 2018 Muo.io. All rights reserved.
//

import Foundation
import Cocoa

extension NSNotification.Name {
    public static let BCPlayerInit = Notification.Name("BCPlayerInit")
    public static let BCPlayerLoaded = NSNotification.Name("BCPlayerLoaded")
    public static let BCPlayerFailed = NSNotification.Name("BCPlayerFailed")
    public static let BCPlayerReady = NSNotification.Name("BCPlayerReady")
    public static let BCPlayerLoadingRange = NSNotification.Name("BCPlayerLoadingRange")
    public static let BCPlayerPlaying = NSNotification.Name("BCPlayerPlaying")
    public static let BCPlayerFinished = NSNotification.Name("BCPlayerFinished")
    public static let BCPlayerPlay = NSNotification.Name("BCPlayerPlay")
    public static let BCPlayerPlayed = NSNotification.Name("BCPlayerPlayed")
    public static let BCPlayerPause = NSNotification.Name("BCPlayerPause")
    public static let BCPlayerPaused = NSNotification.Name("BCPlayerPaused")
    public static let BCPlayerToggle = NSNotification.Name("BCPlayerToggle")
    public static let BCPlayerBuffing = NSNotification.Name("BCPlayerBuffing")
    public static let BCPlayerSeek = NSNotification.Name("BCPlayerSeek")
    public static let BCPlayerDuration = NSNotification.Name("BCPlayerDuration")
}
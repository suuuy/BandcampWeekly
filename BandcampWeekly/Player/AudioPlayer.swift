//
// Created by Kin on 2018/1/13.
// Copyright (c) 2018 Muo.io. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit
import HexColors
import SwiftDate

class AudioPlayer: NSObject {
    let notificationCenter = NotificationCenter.default
    var playerAsset: AVAsset!
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    var playing: Bool = false

    override init() {
        super.init();
        notificationCenter.addObserver(
                self,
                selector: #selector(create),
                name: NSNotification.Name.BCPlayerInit,
                object: nil
        )

        notificationCenter.addObserver(
                self,
                selector: #selector(play),
                name: NSNotification.Name.BCPlayerPlay,
                object: nil
        )

        notificationCenter.addObserver(
                self,
                selector: #selector(pause),
                name: NSNotification.Name.BCPlayerPause,
                object: nil
        )

        notificationCenter.addObserver(
                self,
                selector: #selector(seek),
                name: NSNotification.Name.BCPlayerSeek,
                object: nil
        )

        notificationCenter.addObserver(
                self,
                selector: #selector(toggle),
                name: NSNotification.Name.BCPlayerToggle,
                object: nil
        )
    }

    @objc func create(notification: NSNotification) {
        player = getPlayer(
                playerItem: getPlayerItem(
                        playerAsset: getPlayerAsset(
                                streamUrl: notification.object as! String
                        )
                )
        )
    }

    func getPlayerAsset(streamUrl: String) -> AVAsset {
        playerAsset = AVAsset(url: URL(string: streamUrl)!)
        self.notificationCenter.post(
                name: NSNotification.Name.BCPlayerDuration,
                object: CMTimeGetSeconds(playerAsset.duration)
        )
        playerAsset.loadValuesAsynchronously(forKeys: ["playable"]) {
            var error: NSError? = nil
            let status = self.playerAsset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                self.notificationCenter.post(
                        name: NSNotification.Name.BCPlayerLoaded,
                        object: nil
                )
            case .failed:
                self.notificationCenter.post(
                        name: NSNotification.Name.BCPlayerLoaded,
                        object: nil
                )
            default:
                print("")
            }
        }
        return playerAsset;
    }

    func getPlayerItem(playerAsset: AVAsset) -> AVPlayerItem {
        playerItem = AVPlayerItem(asset: playerAsset)
        playerItem.preferredForwardBufferDuration = 60 * 20;
        playerItem.preferredPeakBitRate = 1000 * 1000 * 2;
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true;

        // Register as an observer of the player item's status property
        playerItem.addObserver(
                self,
                forKeyPath: #keyPath(AVPlayerItem.status),
                options: [.new],
                context: nil
        )

        // Register as an observer of the player item's status property
        playerItem.addObserver(
                self,
                forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges),
                options: [.new],
                context: nil
        )

        return playerItem;
    }


    override func observeValue(
            forKeyPath keyPath: String?,
            of object: Any?,
            change: [NSKeyValueChangeKey: Any]?,
            context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus

            // Get the status change from the change dictionary
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            // Switch over the status
            switch status {
            case .readyToPlay:
                self.notificationCenter.post(
                        name: NSNotification.Name.BCPlayerReady,
                        object: nil
                )
            case .failed:
                self.notificationCenter.post(
                        name: NSNotification.Name.BCPlayerFailed,
                        object: nil
                )
            default:
                print("")
            }
        }

        if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
            if let timeRange = change?[.newKey] as? [CMTimeRange],
               let range = timeRange.first as? CMTimeRange {
                self.notificationCenter.post(
                        name: NSNotification.Name.BCPlayerLoadingRange,
                        object: range
                )
            }
        }
    }

    func getPlayer(playerItem: AVPlayerItem) -> AVPlayer {
        player = AVPlayer(playerItem: playerItem);
        // add time observer
        let interval = CMTime(
                seconds: 0.5,
                preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        )
        let mainQueue = DispatchQueue.main
        player.addPeriodicTimeObserver(
                forInterval: interval,
                queue: mainQueue
        ) {
            [weak self] time in
            self?.notificationCenter.post(
                    name: NSNotification.Name.BCPlayerPlaying,
                    object: CMTimeGetSeconds(time)
            )
        }

        self.player.addBoundaryTimeObserver(
                forTimes: [NSValue(time: playerItem.duration)],
                queue: mainQueue
        ) {
            self.notificationCenter.post(
                    name: NSNotification.Name.BCPlayerFinished,
                    object: nil
            )
        }


        return player;
    }

    @objc func play() {
        if playing {
            return
        }
        if !playerItem.asset.isPlayable {
            self.notificationCenter.post(
                    name: NSNotification.Name.BCPlayerBuffing,
                    object: nil
            )
        }
        player.play()
        playing = !playing
        self.notificationCenter.post(
                name: NSNotification.Name.BCPlayerPlayed,
                object: nil
        )
    }

    @objc func pause() {
        if !playing {
            return
        }
        player.pause()
        playing = !playing
        self.notificationCenter.post(
                name: NSNotification.Name.BCPlayerPaused,
                object: nil
        )
    }

    @objc func toggle() {
        if playing {
            pause()
        } else {
            play()
        }
    }

    @objc func seek(notification: NSNotification) {
        if let time = notification.object as? Double {
            pause()
            player.seek(
                    to: CMTime(
                            seconds: time,
                            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
                    ),
                    completionHandler: { success in
                        if (success) {
                            print("seek success playing to ", time)
                        } else {
                            print("seek failed playing to ", time)
                        }
                        self.play();
                    }
            )
        }
    }
}
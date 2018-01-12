//
//  ViewController.swift
//  BandcampWeekly
//
//  Created by Kin on 12/29/17.
//  Copyright © 2017 Muo.io. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit
import HexColors
import SwiftDate

class ViewController: NSViewController {


    @IBOutlet weak var bandcampLabel: NSTextFieldCell!
    @IBOutlet weak var dateLabel: NSTextFieldCell!
    @IBOutlet weak var sonyNameButton: NSButton!
    @IBOutlet weak var mainView: NSStackView!
    @IBOutlet weak var loadingView: NSStackView!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var playerView: AVPlayerView!
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var playLoading: NSProgressIndicator!
    @IBOutlet weak var loadingProgress: NSProgressIndicator!
    @IBOutlet weak var menuButton: NSPopUpButton!
    var playImage = NSImage(named: NSImage.Name("Play"))
    var pauseImage = NSImage(named: NSImage.Name("Pause"))
    var playerAsset: AVAsset!
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    var playing: Bool = false
    var playerItemContext = UnsafeMutableRawPointer.allocate(bytes: 4, alignedTo: 1)
    var totalTime: Float64!
    var bandcamp: BandcampModel!
    var weekly: WeeklyModel!
    var curAlbum: TrackModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.isHidden = true;
        loadingView.isHidden = false;
        playButton.isEnabled = false;
        playLoading.isHidden = true;
        loadingProgress.usesThreadedAnimation = true
        loadingProgress.doubleValue = 10;
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    static func freshController() -> ViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "ViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ViewController else {
            fatalError("Why cant i find ViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }

    func initData(bandcamp: BandcampModel) {
        self.bandcamp = bandcamp
        weekly = bandcamp.show
        setDateLabel()
        setAlbumLabel(
                album: (weekly.tracks.first)!
        )
        setButton();
        print("parse weekly audio steam", weekly.audioStream)
        setAudio(streamUrl: (weekly.audioStream["mp3-128"])!)
    }

    func setAlbumLabel(album: TrackModel) {
        sonyNameButton.attributedTitle = NSAttributedString(
                string: album.title + " / " + album.albumTitle,
                attributes: [
                    NSAttributedStringKey.foregroundColor: NSColor("#408ea3"),
                ]
        )
//        sonyNameButton.title = album.title + " / " + album.albumTitle
    }

    func setDateLabel() {
        bandcampLabel.textColor = NSColor(weekly.buttonColor)!
        dateLabel.title = (try weekly.publishedDate.date(
                format: .rss(alt: true)
        )?.string(custom: "yyyy-MM-dd"))!
    }

    func setButton() {
        playButton.isBordered = false //Important
        playButton.wantsLayer = true
        playButton.layer?.backgroundColor = NSColor(weekly.buttonColor)?.cgColor
        print(playButton.layer?.backgroundColor)
        print(weekly.buttonColor)
    }

    func setSliderRange(time: Float64) {
        timeSlider.minValue = 0;
        timeSlider.maxValue = time;
    }

    func setAudio(streamUrl: String) {

        print("Starting bandcamp weekly from : {} ", streamUrl)

        loadingProgress.doubleValue = 50;

        mainView.isHidden = false
        loadingView.isHidden = true;

        player = getPlayer(
                playerItem: getPlayerItem(
                        playerAsset: getPlayerAsset(
                                streamUrl: streamUrl
                        )
                )
        )
    }

    func getPlayerAsset(streamUrl: String) -> AVAsset {
        playerAsset = AVAsset(url: URL(string: streamUrl)!)
        setSliderRange(time: CMTimeGetSeconds(playerAsset.duration))
        playerAsset.loadValuesAsynchronously(forKeys: ["playable"]) {
            var error: NSError? = nil
            let status = self.playerAsset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loading:
                self.playLoading.isHidden = false;
                NSLog("loading bandcamp weekly ")
            case .loaded:
                NSLog("loaded bandcamp weekly ")
                self.playButton.isEnabled = true;
                self.playButton.image = self.playImage;
            case .cancelled:
                NSLog("load canceled bandcamp weekly ")
                self.playButton.isEnabled = false;
            case .failed:
                NSLog("load failed bandcamp weekly  ")
                self.playButton.isEnabled = false;
            default:
                self.playButton.isEnabled = true;
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
                self.playLoading.isHidden = true;
                self.playButton.image = playImage;
                    // Player item is ready to play.
            case .failed:
                print("failed to play")
                    // Player item failed. See error.
            case .unknown:
                print("unknown to play")
                    // Player item is not yet ready.
            }
        }

        if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
            if let timeRange = change?[.newKey] as? [CMTimeRange], let range = timeRange.first as? CMTimeRange {
                print("Buffer Time Start：", CMTimeGetSeconds(range.start));
                print("Buffer Time Length：", CMTimeGetSeconds(range.duration));
            }
        }
    }

    func getPlayer(playerItem: AVPlayerItem) -> AVPlayer {
        player = AVPlayer(playerItem: playerItem);
        playerView.player = player

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
            var cur = CMTimeGetSeconds(time);
            self?.timeSlider.doubleValue = cur
            self?.curAlbum = self?.weekly.find(time: cur)
            self?.setAlbumLabel(album: (self?.curAlbum)!)
            print("Current Time：", cur);
        }

        self.player.addBoundaryTimeObserver(
                forTimes: [NSValue(time: playerItem.duration)],
                queue: mainQueue
        ) {
            print("End Play");
            self.pause()
        }


        return player;
    }

    func play() {
        if playing {
            return
        }
        print(playerItem.asset.isPlayable)
        if !playerItem.asset.isPlayable {
            playButton.image = nil;
            playLoading.isHidden = false;
        }
        playLoading.isHidden = true;
        player.play()
        playing = !playing
        playButton.image = playing ? pauseImage : playImage;
    }

    func pause() {
        if !playing {
            return
        }
        player.pause()
        playing = !playing
        playButton.image = playing ? pauseImage : playImage;
    }

    @IBAction func sliderChange(_ sender: NSSlider) {
        pause()
        player.seek(
                to: CMTime(
                        seconds: sender.doubleValue,
                        preferredTimescale: CMTimeScale(NSEC_PER_SEC)
                ),
                completionHandler: { success in
                    if (success) {
                        print("seek success playing to ", sender.doubleValue)
                    } else {
                        print("seek failed playing to ", sender.doubleValue)
                    }
                    self.play();
                }
        )
    }

    @IBAction func openLink(_ sender: Any) {
        if NSWorkspace.shared.open(URL(string: curAlbum.albumUrl)!) {
            print("default browser was successfully opened")
        } else {
            print("default browser was failed opened")
        }
    }

    @IBAction func openTrack(_ sender: Any) {
        if NSWorkspace.shared.open(URL(string: curAlbum.trackUrl)!) {
            print("default browser was successfully opened")
        } else {
            print("default browser was failed opened")
        }
    }

    @IBAction func togglePlay(_ sender: Any) {
        if playing {
            pause()
        } else {
            play()
        }
        print("toggle playing to ", playing)
    }

    @IBAction func openSetting(_ sender: Any) {
    }

    @IBAction func doQuit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
}


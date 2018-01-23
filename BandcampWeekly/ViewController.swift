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

    let notificationCenter = NotificationCenter.default

    @IBOutlet weak var bandcampLabel: NSTextFieldCell!
    @IBOutlet weak var dateLabel: NSTextFieldCell!
    @IBOutlet weak var sonyNameButton: NSButton!
    @IBOutlet weak var mainView: NSStackView!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var playLoading: NSProgressIndicator!
    @IBOutlet weak var loadingProgress: NSProgressIndicator!
    @IBOutlet weak var menuButton: NSPopUpButton!
    @IBOutlet weak var trackCollectionView: NSCollectionView!
    var preferenceController: PreferenceWindowController?
    let bandcampRequest: BandcampRequest = BandcampRequest()
    var bandcamp: BandcampModel!
    var weekly: WeeklyModel!
    var curTrack: TrackModel!
    var notifications = [
        NSNotification.Name.BCPlayerLoaded,
        NSNotification.Name.BCPlayerReady,
        NSNotification.Name.BCPlayerDuration,
        NSNotification.Name.BCPlayerFailed,
        NSNotification.Name.BCPlayerLoadingRange,
        NSNotification.Name.BCPlayerPlaying,
        NSNotification.Name.BCPlayerPlayed,
        NSNotification.Name.BCPlayerPaused,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        mainView.isHidden = true
        playButton.isHidden = true
        playButton.image = BCImage.play
        timeSlider.maxValue = 0
        timeSlider.doubleValue = 0
        timeSlider.minValue = 0
        playLoading.isHidden = false
        playLoading.usesThreadedAnimation = true
        playLoading.increment(by: 0.01)
        playLoading.startAnimation(self)
        playLoading.isBezeled = true
        playLoading.style = NSProgressIndicator.Style.spinning
        playLoading.controlSize = NSControl.ControlSize.small
        playLoading.sizeToFit()


        DispatchQueue.main.async {
            self.notifications.forEach {
                name in
                self.notificationCenter.addObserver(
                        self,
                        selector: #selector(self.observerNotification),
                        name: name,
                        object: nil
                )
            }
        }
        initData()
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

    func initData() {
        weekly = bandcamp.show
        curTrack = (weekly.tracks.first)!
        setDateLabel()
        setAlbumLabel(
                album: curTrack
        )
        setButton();
        mainView.isHidden = false
        DispatchQueue.main.async {
            print("parse weekly audio steam", self.weekly.audioStream)
            self.notificationCenter.post(
                    name: NSNotification.Name.BCPlayerInit,
                    object: (self.weekly.audioStream["mp3-128"])!
            )
        }
    }

    func setAlbumLabel(album: TrackModel) {
        sonyNameButton.attributedTitle = NSAttributedString(
                string: album.title + " / " + album.albumTitle,
                attributes: [
                    NSAttributedStringKey.foregroundColor: NSColor("#408ea3"),
                ]
        )
    }

    func setDateLabel() {
        bandcampLabel.textColor = NSColor(weekly.buttonColor)
        dateLabel.title = (try weekly.publishedDate.date(
                format: .rss(alt: true)
        )?.string(custom: "yyyy-MM-dd"))!
    }

    func setButton() {
        playButton.isBordered = false //Important
        playButton.wantsLayer = true
        playButton.layer?.backgroundColor = NSColor(weekly.buttonColor)?.cgColor

        playLoading.wantsLayer = true
        playLoading.layer?.backgroundColor = NSColor(weekly.buttonColor)?.cgColor
        print(weekly.buttonColor)
    }

    @objc func observerNotification(notification: NSNotification) {

        switch notification.name {
        case NSNotification.Name.BCPlayerDuration:
            timeSlider.minValue = 0;
            timeSlider.maxValue = notification.object as! Double;
            print("Duration : ", timeSlider.maxValue)
        case NSNotification.Name.BCPlayerReady:
            self.playLoading.isHidden = true;
            self.playButton.isHidden = false;
            print("Play Ready...")
        case NSNotification.Name.BCPlayerLoaded:
            self.playButton.isEnabled = true;
            print("Play Loaded...")
        case NSNotification.Name.BCPlayerLoadingRange:
            if let range = notification.object as? CMTimeRange {
                // TODO: add buffer time show
//                print("Buffer Time From：", CMTimeGetSeconds(range.start), " range ", CMTimeGetSeconds(range.duration));
            }
        case NSNotification.Name.BCPlayerPlaying:
            if var cur = notification.object as? Double {
//                print("Current: ", cur)
                timeSlider.doubleValue = cur
                curTrack = weekly.find(time: cur)
                setAlbumLabel(album: (curTrack)!)
            }
        case NSNotification.Name.BCPlayerPlayed:
            playLoading.isHidden = true;
            playButton.image = BCImage.pause;
            print("Play Played...")
        case NSNotification.Name.BCPlayerPaused:
            playLoading.isHidden = true;
            playButton.image = BCImage.play;
            print("Play Paused...")
        case NSNotification.Name.BCPlayerFinished:
            notificationCenter.post(
                    name: NSNotification.Name.BCPlayerPause,
                    object: nil
            )
            print("Play Finished...")
        default:
            print("")
        }
    }

    @IBAction func sliderChange(_ sender: NSSlider) {
        notificationCenter.post(
                name: NSNotification.Name.BCPlayerSeek,
                object: sender.doubleValue
        )
    }

    @IBAction func openLink(_ sender: Any) {
        if NSWorkspace.shared.open(URL(string: curTrack.albumUrl)!) {
            print("default browser was successfully opened")
        } else {
            print("default browser was failed opened")
        }
    }

    @IBAction func openTrack(_ sender: Any) {
        if NSWorkspace.shared.open(URL(string: curTrack.trackUrl)!) {
            print("default browser was successfully opened")
        } else {
            print("default browser was failed opened")
        }
    }

    @IBAction func openDownload(_ sender: Any) {
        if curTrack != nil {
            self.showPreference(sender)
            DispatchQueue.main.async {
                self.notificationCenter.post(
                        name: NSNotification.Name.DownLoadingAdd,
                        object: self.curTrack
                )
            }
        }
    }

    @IBAction func togglePlay(_ sender: Any) {
        notificationCenter.post(
                name: NSNotification.Name.BCPlayerToggle,
                object: nil
        )
    }

    @IBAction func openSetting(_ sender: Any) {
    }

    @IBAction func doQuit(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }

    @IBAction func showPreference(_ sender: Any) {
        if preferenceController == nil {
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Preference"), bundle: nil)
            preferenceController = storyboard.instantiateInitialController() as? PreferenceWindowController
        }

        if preferenceController != nil {
            preferenceController?.showWindow(sender)
        }
    }

}


extension ViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.weekly.tracks.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        // 4
        let item = collectionView.makeItem(
                withIdentifier: NSUserInterfaceItemIdentifier("TrackItem"),
                for: indexPath
        )
        guard let trackItem = item as? TrackItem else {
            return item
        }

        // 5
        trackItem.model = self.weekly.tracks[indexPath.item]
        trackItem.index = indexPath
        return item
    }
}


extension ViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let item = collectionView.item(at: indexPaths.first!) as? TrackItem {
            setAlbumLabel(album: item.model!)
            self.timeSlider.doubleValue = Double((item.model?.timecode)!)
            self.notificationCenter.post(
                    name: NSNotification.Name.BCPlayerSeek,
                    object: item.model?.timecode
            )
            item.hover()
        }
    }

    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        if let item = collectionView.item(at: indexPaths.first!) as? TrackItem {
            item.normal()
        }
    }
}


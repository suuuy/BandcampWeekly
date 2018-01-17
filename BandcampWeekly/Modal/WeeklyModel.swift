//
//  WeeklyModel.swift
//  WeeklyModel
//
//  Created by Kin on 2018/1/1.
//  Copyright © 2018年 Muo.io. All rights reserved.
//

import Foundation
import SwiftyJSON

class WeeklyModel: NSObject, NSCoding {

    struct PropertyKey {
        static let title = "title"
        static let desc = "desc"
        static let showScreenMageId = "showScreenMageId"
        static let audioDuration = "audioDuration"
        static let subtitle = "subtitle"
        static let showV2ImageId = "showV2ImageId"
        static let date = "date"
        static let audioTrackId = "audioTrackId"
        static let showId = "showId"
        static let buttonColor = "buttonColor"
        static let imageCaption = "imageCaption"
        static let streamInfos = "streamInfos"
        static let tracks = "tracks"
        static let audioStream = "audioStream"
        static let publishedDate = "publishedDate"
        static let showImageId = "showImageId"
        static let audioTitle = "audioTitle"
        static let shortDesc = "shortDesc"
        static let imageUrl170 = "imageUrl170"
    }

    let title: String
    let desc: String
    let showScreenMageId: String
    let audioDuration: String
    let subtitle: String
    let showV2ImageId: String
    let date: String
    let audioTrackId: String
    let showId: String
    let buttonColor: String
    let imageCaption: String
    let streamInfos: String
    let tracks: [TrackModel]
    let audioStream: [String: String]
    let publishedDate: String
    let showImageId: String
    let audioTitle: String
    let shortDesc: String
    let imageUrl170: String

    init?(json: JSON) {
        self.title = json["title"].stringValue
        self.desc = json["desc"].stringValue
        self.showScreenMageId = json["show_screen_mage_id"].stringValue
        self.audioDuration = json["audio_duration"].stringValue
        self.subtitle = json["subtitle"].stringValue
        self.showV2ImageId = json["show_v2_image_id"].stringValue
        self.date = json["date"].stringValue
        self.audioTrackId = json["audio_track_id"].stringValue
        self.showId = json["show_id"].stringValue
        self.buttonColor = json["button_color"].stringValue
        self.imageCaption = json["image_caption"].stringValue
        self.streamInfos = json["stream_infos"].stringValue
        self.publishedDate = json["published_date"].stringValue
        self.showImageId = json["show_image_id"].stringValue
        self.audioTitle = json["audio_title"].stringValue
        self.shortDesc = json["short_desc"].stringValue

        var tracks = [TrackModel]()
        for (_, data) in json["tracks"] {
            guard let track = TrackModel(json: data) else {
                return nil
            }
            tracks.append(track)
        }
        self.tracks = tracks.sorted {
            $0.timecode > $1.timecode
        }

        var audioStream = [String: String]()
        for (key, data) in json["audio_stream"] {
            audioStream.updateValue(data.stringValue, forKey: key)
        }
        self.audioStream = audioStream;
        self.imageUrl170 = "https://f4.bcbits.com/img/00" + self.showV2ImageId + "_170"
    }

    func find(time: Double) -> TrackModel {
        return tracks.filter {
            Double($0.timecode) <= time
        }.first!
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: PropertyKey.title)
        aCoder.encode(desc, forKey: PropertyKey.desc)
        aCoder.encode(showScreenMageId, forKey: PropertyKey.showScreenMageId)
        aCoder.encode(audioDuration, forKey: PropertyKey.audioDuration)
        aCoder.encode(subtitle, forKey: PropertyKey.subtitle)
        aCoder.encode(showV2ImageId, forKey: PropertyKey.showV2ImageId)
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(audioTrackId, forKey: PropertyKey.audioTrackId)
        aCoder.encode(showId, forKey: PropertyKey.showId)
        aCoder.encode(buttonColor, forKey: PropertyKey.buttonColor)
        aCoder.encode(imageCaption, forKey: PropertyKey.imageCaption)
        aCoder.encode(streamInfos, forKey: PropertyKey.streamInfos)
        aCoder.encode(tracks, forKey: PropertyKey.tracks)
        aCoder.encode(audioStream, forKey: PropertyKey.audioStream)
        aCoder.encode(publishedDate, forKey: PropertyKey.publishedDate)
        aCoder.encode(showImageId, forKey: PropertyKey.showImageId)
        aCoder.encode(audioTitle, forKey: PropertyKey.audioTitle)
        aCoder.encode(shortDesc, forKey: PropertyKey.shortDesc)
        aCoder.encode(imageUrl170, forKey: PropertyKey.imageUrl170)
    }

    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: PropertyKey.title) as! String
        desc = aDecoder.decodeObject(forKey: PropertyKey.desc) as! String
        showScreenMageId = aDecoder.decodeObject(forKey: PropertyKey.showScreenMageId) as! String
        audioDuration = aDecoder.decodeObject(forKey: PropertyKey.audioDuration) as! String
        subtitle = aDecoder.decodeObject(forKey: PropertyKey.subtitle) as! String
        showV2ImageId = aDecoder.decodeObject(forKey: PropertyKey.showV2ImageId) as! String
        date = aDecoder.decodeObject(forKey: PropertyKey.date) as! String
        audioTrackId = aDecoder.decodeObject(forKey: PropertyKey.audioTrackId) as! String
        showId = aDecoder.decodeObject(forKey: PropertyKey.showId) as! String
        buttonColor = aDecoder.decodeObject(forKey: PropertyKey.buttonColor) as! String
        imageCaption = aDecoder.decodeObject(forKey: PropertyKey.imageCaption) as! String
        streamInfos = aDecoder.decodeObject(forKey: PropertyKey.streamInfos) as! String
        tracks = aDecoder.decodeObject(forKey: PropertyKey.tracks) as! [TrackModel]
        audioStream = aDecoder.decodeObject(forKey: PropertyKey.audioStream) as! [String: String]
        publishedDate = aDecoder.decodeObject(forKey: PropertyKey.publishedDate) as! String
        showImageId = aDecoder.decodeObject(forKey: PropertyKey.showImageId) as! String
        audioTitle = aDecoder.decodeObject(forKey: PropertyKey.audioTitle) as! String
        shortDesc = aDecoder.decodeObject(forKey: PropertyKey.shortDesc) as! String
        imageUrl170 = aDecoder.decodeObject(forKey: PropertyKey.imageUrl170) as! String
    }
}


//
//  WeeklyModel.swift
//  WeeklyModel
//
//  Created by Kin on 2018/1/1.
//  Copyright © 2018年 Muo.io. All rights reserved.
//

import Foundation
import SwiftyJSON

struct WeeklyModel {

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
}

extension WeeklyModel {
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
    }

    func find(time: Double) -> TrackModel {
        return tracks.filter {
            Double($0.timecode) <= time
        }.first!
    }
}


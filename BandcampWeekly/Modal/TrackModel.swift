//
// Created by Kin on 2018/1/2.
// Copyright (c) 2018 Muo.io. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TrackModel {
    let trackId: String
    let title: String
    let albumTitle: String
    let timecode: Int
    let albumId: String
    let bandId: String
    let label: String
    let albumUrl: String
    let trackArtId: String
    let trackUrl: String
    let bioImageId: String
    let url: String
    let artist: String
}

extension TrackModel {
    init?(json: JSON) {
        self.trackId = json["track_id"].stringValue
        self.title = json["title"].stringValue
        self.label = json["label"].stringValue
        self.albumTitle = json["album_title"].stringValue
        self.timecode = json["timecode"].intValue
        self.albumId = json["album_id"].stringValue
        self.bandId = json["band_id"].stringValue
        self.albumUrl = json["album_url"].stringValue
        self.trackUrl = json["track_url"].stringValue
        self.bioImageId = json["bio_image_id"].stringValue
        self.trackArtId = json["track_art_id"].stringValue
        self.url = json["url"].stringValue
        self.artist = json["artist"].stringValue
    }
}
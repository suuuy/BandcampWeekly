//
// Created by Kin on 2018/1/2.
// Copyright (c) 2018 Muo.io. All rights reserved.
//

import Foundation
import SwiftyJSON

class TrackModel: NSObject, NSCoding {

    struct PropertyKey {
        static let trackId = "trackId"
        static let title = "title"
        static let albumTitle = "albumTitle"
        static let timecode = "timecode"
        static let albumId = "albumId"
        static let bandId = "bandId"
        static let label = "label"
        static let albumUrl = "albumUrl"
        static let trackUrl = "trackUrl"
        static let trackArtId = "trackArtId"
        static let bioImageId = "bioImageId"
        static let url = "url"
        static let artist = "artist"
        static let artistImage = "artistImage"
        static let artistImageUrl = "artistImageUrl"
        static let trackArtImageUrl = "trackArtImageUrl"
        static let trackArtImage = "trackArtImage"
    }

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
    let artistImageUrl: String
    var artistImage: NSImage?
    let trackArtImageUrl: String
    var trackArtImage: NSImage?

    func encode(with aCoder: NSCoder) {
        aCoder.encode(trackId, forKey: PropertyKey.trackId)
        aCoder.encode(title, forKey: PropertyKey.title)
        aCoder.encode(albumTitle, forKey: PropertyKey.albumTitle)
        aCoder.encode(timecode, forKey: PropertyKey.timecode)
        aCoder.encode(albumId, forKey: PropertyKey.albumId)
        aCoder.encode(bandId, forKey: PropertyKey.bandId)
        aCoder.encode(label, forKey: PropertyKey.label)
        aCoder.encode(albumUrl, forKey: PropertyKey.albumUrl)
        aCoder.encode(trackArtId, forKey: PropertyKey.trackArtId)
        aCoder.encode(trackUrl, forKey: PropertyKey.trackUrl)
        aCoder.encode(bioImageId, forKey: PropertyKey.bioImageId)
        aCoder.encode(url, forKey: PropertyKey.url)
        aCoder.encode(artist, forKey: PropertyKey.artist)
        aCoder.encode(artistImageUrl, forKey: PropertyKey.artistImageUrl)
        aCoder.encode(artistImage, forKey: PropertyKey.artistImage)
        aCoder.encode(trackArtImageUrl, forKey: PropertyKey.trackArtImageUrl)
        aCoder.encode(trackArtImage, forKey: PropertyKey.trackArtImage)

    }

    required init?(coder aDecoder: NSCoder) {
        trackId = aDecoder.decodeObject(forKey: PropertyKey.trackId) as! String
        title = aDecoder.decodeObject(forKey: PropertyKey.title) as! String
        albumTitle = aDecoder.decodeObject(forKey: PropertyKey.albumTitle) as! String
        timecode = aDecoder.decodeInteger(forKey: PropertyKey.timecode)
        albumId = aDecoder.decodeObject(forKey: PropertyKey.albumId) as! String
        bandId = aDecoder.decodeObject(forKey: PropertyKey.bandId) as! String
        label = aDecoder.decodeObject(forKey: PropertyKey.label) as! String
        albumUrl = aDecoder.decodeObject(forKey: PropertyKey.albumUrl) as! String
        trackArtId = aDecoder.decodeObject(forKey: PropertyKey.trackArtId) as! String
        trackUrl = aDecoder.decodeObject(forKey: PropertyKey.trackUrl) as! String
        bioImageId = aDecoder.decodeObject(forKey: PropertyKey.bioImageId) as! String
        url = aDecoder.decodeObject(forKey: PropertyKey.url) as! String
        artist = aDecoder.decodeObject(forKey: PropertyKey.artist) as! String
        artistImage = aDecoder.decodeObject(forKey: PropertyKey.artistImage) as! NSImage
        artistImageUrl = aDecoder.decodeObject(forKey: PropertyKey.artistImageUrl) as! String
        trackArtImage = aDecoder.decodeObject(forKey: PropertyKey.trackArtImage) as! NSImage
        trackArtImageUrl = aDecoder.decodeObject(forKey: PropertyKey.trackArtImageUrl) as! String
    }

    init?(json: JSON) {

        self.trackId = json["track_id"].stringValue
        self.title = json["title"].stringValue
        self.albumTitle = json["album_title"].stringValue
        self.timecode = json["timecode"].intValue
        self.albumId = json["album_id"].stringValue
        self.bandId = json["band_id"].stringValue
        self.label = json["label"].stringValue
        self.albumUrl = json["album_url"].stringValue
        self.trackArtId = json["track_art_id"].stringValue
        self.trackUrl = json["track_url"].stringValue
        self.bioImageId = json["bio_image_id"].stringValue
        self.artistImageUrl = "https://f4.bcbits.com/img/00" + self.bioImageId + "_9"
        self.trackArtImageUrl = "https://f4.bcbits.com/img/a0" + self.trackArtId + "_13"
        self.url = json["url"].stringValue
        self.artist = json["artist"].stringValue
    }

    func image() {
        ImageCache.image(url: self.trackArtImageUrl) {
            image in
            self.trackArtImage = image
        }
        ImageCache.image(url: self.artistImageUrl) {
            image in
            self.artistImage = image
        }

    }
}

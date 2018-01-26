//
// Created by Kin on 1/26/18.
// Copyright (c) 2018 Muo.io. All rights reserved.
//

import Foundation
import SwiftyJSON

class HistoryModel: NSObject, NSCoding {

    struct PropertyKey {
        static let desc = "desc"
        static let buttonColor = "buttonColor"
        static let episodeNumber = "episodeNumber"
        static let imageCaption = "imageCaption"
        static let v2ImageId = "v2ImageId"
        static let imageId = "imageId"
        static let id = "id"
        static let publishedDate = "publishedDate"
        static let date = "date"
        static let screenImageId = "screenImageId"
        static let imageUrl = "imageUrl"
    }

    var desc: String
    var buttonColor: String
    var episodeNumber: String
    var imageCaption: String
    var v2ImageId: String
    var imageId: String
    var id: String
    var publishedDate: String
    var date: String
    var screenImageId: String
    var imageUrl: String

    init?(json: JSON) {
        self.desc = json["desc"].stringValue
        self.buttonColor = json["button_color"].stringValue
        self.episodeNumber = json["episode_number"].stringValue
        self.imageCaption = json["image_caption"].stringValue
        self.v2ImageId = json["v2_image_id"].stringValue
        self.imageId = json["image_id"].stringValue
        self.id = json["id"].stringValue
        self.publishedDate = json["published_date"].stringValue
        self.date = json["date"].stringValue
        self.screenImageId = json["screen_image_id"].stringValue
        self.imageUrl = "https://f4.bcbits.com/img/00" + self.imageId + "_0"
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(desc, forKey: PropertyKey.desc)
        aCoder.encode(buttonColor, forKey: PropertyKey.buttonColor)
        aCoder.encode(episodeNumber, forKey: PropertyKey.episodeNumber)
        aCoder.encode(imageCaption, forKey: PropertyKey.imageCaption)
        aCoder.encode(v2ImageId, forKey: PropertyKey.v2ImageId)
        aCoder.encode(imageId, forKey: PropertyKey.imageId)
        aCoder.encode(id, forKey: PropertyKey.id)
        aCoder.encode(publishedDate, forKey: PropertyKey.publishedDate)
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(screenImageId, forKey: PropertyKey.screenImageId)
        aCoder.encode(imageUrl, forKey: PropertyKey.imageUrl)

    }

    required init?(coder aDecoder: NSCoder) {
        desc = aDecoder.decodeObject(forKey: PropertyKey.desc) as! String
        buttonColor = aDecoder.decodeObject(forKey: PropertyKey.buttonColor) as! String
        episodeNumber = aDecoder.decodeObject(forKey: PropertyKey.episodeNumber) as! String
        imageCaption = aDecoder.decodeObject(forKey: PropertyKey.imageCaption) as! String
        v2ImageId = aDecoder.decodeObject(forKey: PropertyKey.v2ImageId) as! String
        imageId = aDecoder.decodeObject(forKey: PropertyKey.imageId) as! String
        id = aDecoder.decodeObject(forKey: PropertyKey.id) as! String
        publishedDate = aDecoder.decodeObject(forKey: PropertyKey.publishedDate) as! String
        date = aDecoder.decodeObject(forKey: PropertyKey.date) as! String
        screenImageId = aDecoder.decodeObject(forKey: PropertyKey.screenImageId) as! String
        imageUrl = aDecoder.decodeObject(forKey: PropertyKey.imageUrl) as! String
    }
}

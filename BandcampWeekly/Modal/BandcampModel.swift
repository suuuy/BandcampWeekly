//
//  BackcampModal.swift
//  BackcampModal
//
//  Created by Kin on 2018/1/1.
//  Copyright © 2018年 Muo.io. All rights reserved.
//

import Foundation
import SwiftyJSON

class BandcampModel: NSObject, NSCoding {

    struct PropertyKey {
        static let weekly = "weekly"
        static let history = "history"
    }

    var weekly: WeeklyModel
    var history = [HistoryModel]()

    func encode(with aCoder: NSCoder) {
        aCoder.encode(weekly, forKey: PropertyKey.weekly)
        aCoder.encode(history, forKey: PropertyKey.history)
    }

    required init?(coder aDecoder: NSCoder) {
        weekly = aDecoder.decodeObject(forKey: PropertyKey.weekly) as! WeeklyModel
        history = aDecoder.decodeObject(forKey: PropertyKey.history) as! [HistoryModel]
    }

    init?(json: JSON) {
        for (key, data) in json["bcw_seq"] {
            guard let history = HistoryModel(json: data) else {
                return nil
            }
            self.history.append(history)
        }

        self.history = self.history.sorted {
            Int($0.episodeNumber)! > Int($1.episodeNumber)!
        }

        self.weekly = WeeklyModel(json: json["bcw_show"])!
    }

}

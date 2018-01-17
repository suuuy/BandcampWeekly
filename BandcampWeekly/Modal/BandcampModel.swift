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

    static var DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static var ArchiveURL = DocumentsDirectory.appendingPathComponent("BandcampModel")

    struct PropertyKey {
        static let weekly = "weekly"
        static let show = "show"
    }

    var weekly = [String: WeeklyModel]()
    var show: WeeklyModel

    func encode(with aCoder: NSCoder) {
        aCoder.encode(weekly, forKey: PropertyKey.weekly)
        aCoder.encode(show, forKey: PropertyKey.show)
    }

    required init?(coder aDecoder: NSCoder) {
        weekly = aDecoder.decodeObject(forKey: PropertyKey.weekly) as! [String: WeeklyModel]
        show = aDecoder.decodeObject(forKey: PropertyKey.show) as! WeeklyModel
    }

    init?(json: JSON) {
        var m = [String: WeeklyModel]()
        for (key, data) in json["bcw_data"] {
            guard let weekly = WeeklyModel(json: data) else {
                return nil
            }
            m.updateValue(weekly, forKey: key);
        }

        self.weekly = m;
        self.show = WeeklyModel(json: json["bcw_show"])!
    }

    static func cleanArchive() {
        if FileManager.default.fileExists(atPath: BandcampModel.ArchiveURL.path) {
            do {
                try FileManager.default.removeItem(at: BandcampModel.ArchiveURL)
            } catch let error as NSError {
                print("error: \(error.localizedDescription)")
            }
        }
    }


    func archive() -> Bool {
        return NSKeyedArchiver.archiveRootObject(self, toFile: BandcampModel.ArchiveURL.path)
    }

    static func unarchived() -> BandcampModel? {
        if let unarchivedData = NSKeyedUnarchiver.unarchiveObject(withFile: BandcampModel.ArchiveURL.path) as? BandcampModel {
            return unarchivedData
        }
        return nil
    }
}

//
// Created by Kin on 2/27/18.
// Copyright (c) 2018 Muo.io. All rights reserved.
//

import Foundation

class BandcampCache {
    static var DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static var BandcampWeekly = "BandcampWeekly";

    static func getKey(_ region: String, _ number: String) -> URL {
        return DocumentsDirectory.appendingPathComponent("\(region)-\(number)")
    }

    static func cleanArchive(_ region: String, _ number: String) {
        let key = getKey(region, number)
        if FileManager.default.fileExists(atPath: key.path) {
            do {
                try FileManager.default.removeItem(at: key)
            } catch let error as NSError {
                print("error: \(error.localizedDescription)")
            }
        }
    }

    static func archive(_ number: String, weekly: BandcampModel) {
        clean(number)
        NSKeyedArchiver.archiveRootObject(weekly, toFile: getKey(BandcampWeekly, number).path)
    }

    static func unarchive(
            _ number: String,
            _ closure: @escaping (_ weekly: BandcampModel?) -> Void
    ) {
        do {
            if let weekly = NSKeyedUnarchiver.unarchiveObject(withFile: getKey(BandcampWeekly, number).path) as? BandcampModel {
                closure(weekly)
                return;
            }
            closure(nil)
        } catch {
            print("unarchive error")
            BandcampCache.clean(number)
        }
    }


    static func clean(_ number: String) {
        cleanArchive(BandcampWeekly, number)
    }

}
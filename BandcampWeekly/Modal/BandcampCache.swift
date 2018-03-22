//
// Created by Kin on 2/27/18.
// Copyright (c) 2018 Muo.io. All rights reserved.
//

import Foundation

class BandcampCache {
    static var CacheDirectory =
            FileManager().urls(
                    for: .cachesDirectory,
                    in: .userDomainMask
            ).first!
    var region: Region;

    init(region: Region) {
        self.region = region
    }

    func getKey(_ key: String) -> URL {
        let dir = BandcampCache.CacheDirectory
                .appendingPathComponent("BandcampWeekly", isDirectory: true)
                .appendingPathComponent("\(self.region)", isDirectory: true)

        if !FileManager.default.fileExists(atPath: dir.path) {
            do {
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            } catch {
                print("Create cache directory failed ")
            };
        }

        return dir.appendingPathComponent("\(key)")
    }

    func clean(_ key: String) {
        let key = getKey(key)
        if FileManager.default.fileExists(atPath: key.path) {
            do {
                try FileManager.default.removeItem(at: key)
            } catch let error as NSError {
                print("error: \(error.localizedDescription)")
            }
        }
    }

    func archive(_ key: String, obj: Any) {
        clean(key)
        NSKeyedArchiver.archiveRootObject(obj, toFile: getKey(key).path)
    }

    func unarchive(
            _ key: String
    ) -> Any? {
        do {
            if let obj = NSKeyedUnarchiver.unarchiveObject(withFile: getKey(key).path) {
                return obj;
            }
        } catch {
            print("unarchive error")
            clean(key)
        }
        return nil;
    }

    enum Region {
        case weekly, history
    }
}
//
//  BackcampModal.swift
//  BackcampModal
//
//  Created by Kin on 2018/1/1.
//  Copyright © 2018年 Muo.io. All rights reserved.
//

import Foundation
import SwiftyJSON

struct BandcampModel {

    var weekly = [String: WeeklyModel]()
    var show: WeeklyModel
}

extension BandcampModel {

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
}
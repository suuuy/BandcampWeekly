//
// Created by Kin on 1/2/18.
// Copyright (c) 2018 Muo.io. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSoup
import SwiftyJSON
import Dispatch
import SwiftDate

class BandcampRequest {

    private static let WEEKLY_PAGE = "WEEKLY_PAGE";

    let storage = UserDefaults.standard

    func getData(progress: @escaping (_: Double) -> Void, closure: @escaping (_: BandcampModel) -> Void) {

        var model = BandcampModel.unarchived()

        if nil != model {
            var date = (model?.show.date.date(format: .rss(alt: true)))! + 1.weeks
            var now = DateInRegion()
            if (now >= date) {
                print("Clean Data from local")
                BandcampModel.cleanArchive()
            }
        }

        model = BandcampModel.unarchived()

        if nil != model {
            print("Read Data from local")
            closure(model!)
            progress(1)
            return
        }

        let queue = DispatchQueue(
                label: "io.muo.bandcamp.response-queue",
                qos: .utility,
                attributes: [.concurrent]
        )

        print("Request Data from network")

        Alamofire.request("https://bandcamp.com", encoding: URLEncoding.queryString)
                .downloadProgress {
                    progressVal in
                    progress(progressVal.fractionCompleted / 2)
                }
                .responseData { response in
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            let doc: Document = try! SwiftSoup.parse(utf8Text)
                            progress(0.6)
                            let link: Element = try! doc.select("#pagedata").first()!
                            progress(0.7)
                            let blob: String = try! link.attr("data-blob");
                            progress(0.8)
                            let model = BandcampModel(json: JSON.parse(blob))!
                            print("Request Complete...", model)
                            closure(model)
                            progress(1)
                            DispatchQueue.main.async {
                                model.archive()
                            }
                        }
                    }
                }

    }
}

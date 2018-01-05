//
// Created by Kin on 1/2/18.
// Copyright (c) 2018 Muo.io. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSoup
import SwiftyJSON
import Dispatch

class BandcampRequest {

    func getData(closure: @escaping (_: BandcampModel) -> Void) {

        let queue = DispatchQueue(
                label: "io.muo.bandcamp.response-queue",
                qos: .utility,
                attributes: [.concurrent]
        )

        Alamofire
                .request("https://bandcamp.com")
                .response(
                        queue: queue,
                        completionHandler: { response in
                            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                                do {
                                    let doc: Document = try! SwiftSoup.parse(utf8Text)
                                    let link: Element = try! doc.select("#pagedata").first()!
                                    let blob: String = try! link.attr("data-blob");
                                    DispatchQueue.main.async {
                                        closure(BandcampModel(json: JSON.parse(blob))!)
                                    }
                                } catch Exception.Error(let type, let message) {
                                    print(message)
                                } catch {
                                    print("error")
                                }
                            }
                        }
                )
    }

}
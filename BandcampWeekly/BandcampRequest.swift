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
import Regex

class BandcampRequest {

    private static let WEEKLY_PAGE = "WEEKLY_PAGE";
    private static let STREAM_REGULAR = "\\\"mp3\\-128\\\":\\\"([^\\\"]+)\\\""

    let storage = UserDefaults.standard
    let musicDirectory = FileManager.default.urls(for: .musicDirectory, in: .userDomainMask).first
    var request: Request?

    func getData(
            progress: @escaping (_: Double) -> Void,
            closure: @escaping (_: BandcampModel) -> Void
    ) -> Self {

        var model = BandcampModel.unarchived()

        if nil != model {
            var date = (model?.show.date.date(format: .rss(alt: true)))! + 1.weeks
            var now = DateInRegion()
            if (now.startOfDay >= date.startOfDay) {
                print("Clean Data from local")
                BandcampModel.cleanArchive()
            }
        }

        model = BandcampModel.unarchived()

        if nil != model {
            print("Read Data from local")
            closure(model!)
            progress(1)
            return self
        }

        let queue = DispatchQueue(
                label: "io.muo.bandcamp.response-queue",
                qos: .utility,
                attributes: [.concurrent]
        )

        print("Request Data from network")

        request = Alamofire.request(
                "https://bandcamp.com",
                encoding: URLEncoding.queryString
        ).downloadProgress {
            progressVal in
            progress(progressVal.fractionCompleted / 2)
        }.responseData { response in
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
        return self
    }

    func downloadTrack(
            track: TrackModel, folder: URL?,
            image: @escaping (_: String) -> Void,
            progress: @escaping (_: Double) -> Void,
            complete: @escaping (_: String) -> Void
    ) -> Self {
        var downloadFolder = folder
        if nil == downloadFolder {
            downloadFolder = musicDirectory?.appendingPathComponent("bandcamp", isDirectory: true)
        }

        let fileURL = downloadFolder?.appendingPathComponent(
                track.artist,
                isDirectory: true
        ).appendingPathComponent(
                track.albumTitle,
                isDirectory: true
        ).appendingPathComponent(track.title + ".mp3")

        let albumImage = downloadFolder?.appendingPathComponent(
                track.artist,
                isDirectory: true
        ).appendingPathComponent(
                track.albumTitle,
                isDirectory: true
        ).appendingPathComponent(track.albumTitle + ".jpg")


        if !FileManager.default.fileExists(atPath: (albumImage?.path)!) {

            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (
                        destinationURL: albumImage!,
                        options: [.removePreviousFile, .createIntermediateDirectories]
                )
            }

            Alamofire.download(
                    track.imageUrl200,
                    to: destination
            ).downloadProgress {
                progress in
            }.response { response in
                if response.error == nil, let imagePath = response.destinationURL?.path {
                    print("downloaded album image ", track.imageUrl200, "on ", imagePath)
                    image(imagePath)
                }
            }

        } else {
            image((albumImage?.path)!)
        }

        if !FileManager.default.fileExists(atPath: (fileURL?.path)!) {

            Alamofire.request(track.trackUrl)
                    .responseData { response in
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                if let matches = self.getStreamRegular().allMatches(in: utf8Text).first {
                                    let downloadUrl: String = matches.captures.last as! String

                                    //download mp3 file

                                    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                                        return (
                                                destinationURL: fileURL!,
                                                options: [.removePreviousFile, .createIntermediateDirectories]
                                        )
                                    }

                                    self.request = Alamofire.download(downloadUrl, to: destination)
                                            .downloadProgress {
                                                progressVal in
                                                progress(progressVal.fractionCompleted)
                                            }
                                            .response { response in
                                                if response.error == nil, let mp3Path = response.destinationURL?.path {
                                                    print("downloaded track ", track.trackUrl, "on ", mp3Path)
                                                    complete(mp3Path)
                                                }
                                            }
                                }
                            }
                        }
                    }


        } else {
            complete((fileURL?.path)!)
            progress(1)
        }

        return self

    }

    func cancel() {
        if nil != request {
            request?.cancel()
        }
    }

    private func getStreamRegular() -> Regex {
        return try! Regex(string: BandcampRequest.STREAM_REGULAR)
    }
}

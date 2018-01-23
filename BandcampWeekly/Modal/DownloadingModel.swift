//
// Created by Kin on 1/18/18.
// Copyright (c) 2018 Muo.io. All rights reserved.
//

import Foundation
import Cocoa

class DownloadingModel {
    let request: BandcampRequest = BandcampRequest()
    var track: TrackModel?
    var image: String?
    var progress: Double = 0
    var fileURL: URL?
    var createdAt: Date
    var imageClosure: ((_: String) -> Void)?
    var progressClosure: ((_: Double) -> Void)?
    var completedClosure: ((_: URL) -> Void)?

    init(track: TrackModel) {
        self.track = track
        self.progress = 0
        self.createdAt = Date()
    }

    func image(imageClosure: @escaping (String) -> Void) -> DownloadingModel {
        self.imageClosure = imageClosure
        if nil != self.image {
            self.imageClosure!(self.image!)
        }
        return self
    }

    func progress(progressClosure: @escaping (Double) -> Void) -> DownloadingModel {
        self.progressClosure = progressClosure
        self.progressClosure!(self.progress)
        return self
    }

    func completed(completedClosure: @escaping (URL) -> Void) -> DownloadingModel {
        self.completedClosure = completedClosure
        if nil != self.fileURL {
            self.completedClosure!(self.fileURL!)
        }
        return self
    }

    func download() {
        DispatchQueue.main.async {
            print("Start download \(self.track?.trackId) from \(self.track?.trackUrl)")
            self.request.downloadTrack(
                    track: self.track!,
                    folder: nil,
                    image: {
                        imagePath in
                        self.image = imagePath
                        if self.imageClosure != nil {
                            self.imageClosure!(self.image!)
                        }
                    },
                    progress: {
                        progress in
                        let percent = ceil(progress * 10000) / 100
                        self.progress = percent
                        if self.progressClosure != nil {
                            self.progressClosure!(self.progress)
                        }
                    },
                    complete: {
                        fileURL in
                        self.fileURL = URL(fileURLWithPath: fileURL);
                        if self.completedClosure != nil {
                            self.completedClosure!(self.fileURL!)
                        }
                    }
            )
        }
    }

    func cancel() {
        self.request.cancel()
    }
}

extension DownloadingModel: Hashable {
    static func ==(lhs: DownloadingModel, rhs: DownloadingModel) -> Bool {
        return lhs.track!.trackId == rhs.track!.trackId
    }

    static func !=(lhs: DownloadingModel, rhs: DownloadingModel) -> Bool {
        return lhs.track!.trackId != rhs.track!.trackId
    }

    static func >(lhs: DownloadingModel, rhs: DownloadingModel) -> Bool {
        return lhs != rhs && lhs.createdAt > rhs.createdAt
    }

    var hashValue: Int {
        return self.track!.trackId.hashValue
    }
}

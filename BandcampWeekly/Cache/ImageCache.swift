//
// Created by Kin on 1/24/18.
// Copyright (c) 2018 Muo.io. All rights reserved.
//

import Foundation
import Cocoa

class ImageCache {
    private static let cache = NSCache<NSString, NSImage>()

    private init() {

    }

    static func image(
            url: String,
            _ closure: @escaping (NSImage) -> Void
    ) {
        if let cachedImage = ImageCache.cache.object(forKey: url as NSString) {
            closure(cachedImage)
        } else {
            URLSession.shared.dataTask(
                    with: URL(string: url)!,
                    completionHandler: {
                        (data, response, error) in
                        if error != nil {
                            print(error!)
                            return
                        }

                        DispatchQueue.main.async {
                            if let image = NSImage(data: data!) {
                                cache.setObject(image, forKey: url as NSString)
                                closure(image)
                            }
                        }
                    }
            ).resume()
        }
    }
}

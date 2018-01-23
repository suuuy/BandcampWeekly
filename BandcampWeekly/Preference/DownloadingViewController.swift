//
//  PreferenceViewController.swift
//  BandcampWeekly
//
//  Created by Kin on 1/18/18.
//  Copyright © 2018 Muo.io. All rights reserved.
//

import Cocoa

class DownloadingViewController: PreferenceViewController {

    @IBOutlet weak var collectionView: NSCollectionView!
    var items = [DownloadingModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.add),
                name: NSNotification.Name.DownLoadingAdd,
                object: nil
        )
    }

    override func viewWillAppear() {
        collectionView.reloadData()
    }

    @objc func add(notification: NSNotification) {
        if let track = notification.object as? TrackModel {
            let model = DownloadingModel(track: track)
            if !items.contains(model) {
                model.download()
                let indexPath = IndexPath(item: items.count, section: 0)
                items.append(model)
                collectionView.insertItems(at: [indexPath])
            }
        }
    }

    private func configureCollectionView() {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 438, height: 40)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.minimumLineSpacing = 10.0
        collectionView.collectionViewLayout = flowLayout
    }
}


extension DownloadingViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        // 4
        let item = collectionView.makeItem(
                withIdentifier: NSUserInterfaceItemIdentifier("DownloadingViewItem"),
                for: indexPath
        )
        guard let collectionViewItem = item as? DownloadingViewItem else {
            return item
        }

        // 5
        collectionViewItem.model = self.items[indexPath.item]
        collectionViewItem.index = indexPath
        collectionViewItem.delegate = self
        return item
    }


}


extension DownloadingViewController: DownloadingViewDelegate {
    func delete(item: DownloadingViewItem) {
        if let indexPath = collectionView.indexPath(for: item) {
            items.remove(at: indexPath.item)
            collectionView?.deleteItems(at: [indexPath])
        }
    }
}
//
//  ChannelsViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 2/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient

protocol ChannelsViewControllerDelegate: class {
    func channelsView(_ controller: ChannelsViewController, didSelect channelType: ChannelType)
    func channelsView(_ controller: ChannelsViewController, didSelect reservation: Reservation)
}

class ChannelsViewController: CollectionViewController<ChannelCell, ChannelsCollectionViewManager> {

    weak var delegate: ChannelsViewControllerDelegate?

    var isSearching: Bool = false

    init() {
        let collectionView = ChannelsCollectionView()
        super.init(with: collectionView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        self.collectionViewManager.allowMultipleSelection = true

        self.collectionViewManager.onSelectedItem.signal.observeValues { (selectedItem) in
            guard let item = selectedItem else { return }
            self.delegate?.channelsView(self, didSelect: item.item.channelType)
        }

        self.collectionViewManager.didSelectReservation = { [unowned self] reservation in
            self.delegate?.channelsView(self, didSelect: reservation)
        }

        self.subscribeToUpdates()
    }
}

extension ChannelsViewController: SearchBarDelegate {

    func searchBarDidBeginEditing(_ searchBar: SearchBar) {
        self.isSearching = true
    }

    func searchBarDidFinishEditing(_ searchBar: SearchBar) {
        self.isSearching = false 
        self.collectionViewManager.loadAllChannels()
    }

    func searchBar(_ searchBar: SearchBar, didUpdate text: String?) {
        let searchText = String(optional: text).lowercased()
        self.collectionViewManager.channelFilter = SearchFilter(text: searchText)
    }
}

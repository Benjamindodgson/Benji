//
//  FavoritesViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 9/8/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures

class ConnectionsViewController: CollectionViewController<ConnectionCell, ConnectionsCollectionViewManager>, Sizeable {

    init() {
        super.init(with: VerticalCollectionView())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        GetAllConnections().makeRequest()
            .observeValue { (connections) in
                let items = connections.filter { (connection) -> Bool in
                    return connection.status == .accepted
                }

                self.collectionViewManager.set(newItems: items)
        }

        self.collectionViewManager.allowMultipleSelection = true 
    }

    func getHeight(for width: CGFloat) -> CGFloat {
        return .zero
    }

    func getWidth(for height: CGFloat) -> CGFloat {
        return .zero
    }
}

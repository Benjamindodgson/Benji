//
//  TableView.swift
//  Benji
//
//  Created by Benji Dodgson on 7/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class TableView: UITableView {

    let activityIndicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.initializeViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func scrollToLastItem() {
        let lastSection = self.numberOfSections - 1
        let lastRow = self.numberOfRows(inSection: lastSection)
        let indexPath = IndexPath(row: lastRow - 1, section: lastSection)
        self.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    private func initializeViews() {
        self.addSubview(self.activityIndicator)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    
        self.activityIndicator.centerOnXAndY()
    }
}

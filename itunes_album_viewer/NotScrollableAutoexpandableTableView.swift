//
//  NotScrollableAutoexpandableTableView.swift
//  itunes_album_viewer
//
//  Created by   IvDin on 08.02.2021.
//  Copyright © 2021   IvDin. All rights reserved.
//

import UIKit

class NotScrollableAutoexpandableTableView: UITableView {
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }

    override var contentSize: CGSize {
        didSet{
            self.invalidateIntrinsicContentSize()
        }
    }

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}

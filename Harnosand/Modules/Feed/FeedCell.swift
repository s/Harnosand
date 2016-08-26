//
//  FeedCell.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 26/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import Foundation
import UIKit

protocol FeedCellProtocol{
    func configureCell(with with:Photo)
}

class FeedCell: UICollectionViewCell{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FeedCell: FeedCellProtocol{
    func configureCell(with with:Photo) {
        
    }
}
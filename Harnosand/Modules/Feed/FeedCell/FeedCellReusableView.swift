//
//  FeedCellReusableView.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 27/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import UIKit
import SnapKit

class FeedCellReusableView: UICollectionReusableView {
    private var activityIndicator: UIActivityIndicatorView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.activityIndicator?.startAnimating()
        self.addSubview(self.activityIndicator!)
        
        activityIndicator?.snp_makeConstraints(closure: { (make) in
            make.center.equalTo(self)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

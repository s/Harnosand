//
//  FeedViewController.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 25/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import UIKit

protocol FeedViewProtocol{
    var presenter: FeedPresenter? { get set }
}

class FeedViewController: UIViewController, FeedViewProtocol {
    var presenter: FeedPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = FeedPresenter(with: self)
        presenter?.loadFeed()
    }
}

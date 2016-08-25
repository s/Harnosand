//
//  FeedPresenter.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 25/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import Foundation

protocol FeedPresenterProtocol{
    weak var view: FeedViewController? { get set }
    
    func loadFeed()
}

class FeedPresenter: FeedPresenterProtocol{
    weak var view: FeedViewController?
    var feed: Feed?
    var page: Int{
        get{
            if let feed = feed{
                return feed.page
            }else{
                return 0
            }
        }
    }
    var nextPage: Int{
        get{
            return page + 1
        }
    }
    
    init(with view: FeedViewController){
        self.view = view
    }
    
    func loadFeed() {
        FlickrService.sharedService.getFeed(page: nextPage) { (result:FlickrServiceResult<Feed>) in
            switch result{
            case .Success(let feed):
                print(feed)
            case .Failure(let error):
                print(error)
            }
        }
    }
}
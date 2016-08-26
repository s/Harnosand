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
    
    func loadFeedInitially()
    func loadNextFeed()
}

class FeedPresenter{
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
    
    private func loadFeed(withPage page:Int){
        FlickrService.sharedService.getFeed(page: page) { (result:FlickrServiceResult<Feed>) in
            switch result{
            case .Success(let feed):
                self.feed = feed
                if let photos = feed.photos{
                    self.view?.loadedItems(photos)
                }else{
                    self.view?.showMessage("An error occured")
                }
            case .Failure(let error):
                print(error)
                self.view?.showMessage("An error occured.")
            }
        }
    }
}

extension FeedPresenter: FeedPresenterProtocol{
    func loadFeedInitially() {
        self.loadFeed(withPage: 0)
    }
    
    func loadNextFeed() {
        self.loadFeed(withPage: nextPage)
    }
}
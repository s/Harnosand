//
//  FeedPresenter.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 25/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import Foundation

protocol FeedDataPresenterProtocol{
    weak var view: FeedViewController? { get set }
    
    func loadFeedInitially()
    func loadNextFeed()
    
    func searchInitially(forKeyword keyword:String)
    func searchNextPage(forKeyword keyword:String)
}

class FeedDataPresenter{
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
    
    private func feedCompletionHandler(response:FlickrServiceResult<Feed>){
        switch response{
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
    
    private func loadFeed(withPage page:Int){
        FlickrService.sharedService.getFeed(page: page) { (response:FlickrServiceResult<Feed>) in
            self.feedCompletionHandler(response)
        }
    }
    
    private func search(forKeyword keyword:String, page:Int){
        FlickrService.sharedService.search(keyword: keyword, page: page) { (response:FlickrServiceResult<Feed>) in
            self.feedCompletionHandler(response)
        }
    }
}

extension FeedDataPresenter: FeedDataPresenterProtocol{
    func loadFeedInitially() {
        self.loadFeed(withPage: 1)
    }
    
    func loadNextFeed() {
        self.loadFeed(withPage: nextPage)
    }
    
    func searchInitially(forKeyword keyword:String){
        self.search(forKeyword: keyword, page: 1)
    }
    
    func searchNextPage(forKeyword keyword: String) {
        self.search(forKeyword: keyword, page: nextPage)
    }
}
//
//  FeedViewController.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 25/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import UIKit

protocol FeedViewProtocol{
    var dataPresenter: FeedDataPresenter? { get set }
    var viewPresenter: FeedViewPresenter? { get set }
    
    func showMessage(message: String)
    func loadedItems(newItems: [Photo])
    func willDisplayLastElementOfFeed()
    func searchBarTextDidChange(text: String)
    func willDisplayLastElementOfSearch(keyword:String)
    func searchCancelled()
}

//MARK: Class: FeedViewController
class FeedViewController: UIViewController, FeedViewProtocol {
    
    //MARK: FeedViewProtocol Properties
    var dataPresenter: FeedDataPresenter?
    var viewPresenter: FeedViewPresenter?
        
    //MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Photos", comment: "")
        
        self.dataPresenter = FeedDataPresenter(with: self)
        dataPresenter?.loadFeedInitially()
        
        self.viewPresenter = FeedViewPresenter(with: self)
        viewPresenter?.createElements()
    }

    //MARK: FeedViewProtocol Methods
    func showMessage(message: String) {
        self.viewPresenter?.showMessage(message)
    }
    
    func loadedItems(newItems: [Photo]) {
        self.viewPresenter?.showItems(newItems)
    }
    
    func pullToRefreshTriggered(){
        self.dataPresenter?.loadFeedInitially()
    }
    
    func willDisplayLastElementOfFeed(){
        self.dataPresenter?.loadNextFeed()
    }
    
    func searchBarTextDidChange(text: String){
        self.dataPresenter?.searchInitially(forKeyword: text)
    }
    
    func willDisplayLastElementOfSearch(keyword:String){
        self.dataPresenter?.searchNextPage(forKeyword: keyword)
    }
    
    func searchCancelled() {
        self.dataPresenter?.loadFeedInitially()
    }
}
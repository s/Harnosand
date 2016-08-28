//
//  FeedViewPresenter.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 28/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

//MARK: FeedViewPresenterProtocol
protocol FeedViewPresenterProtocol{
    weak var controller: FeedViewController? { get set }
    
    func createElements()
    func showMessage(message: String)
    func showItems(items: [Photo])
    func pullToRefreshTriggered()
    func willDisplayLastElementOfFeed()
    func searchBarTextDidChange(text:String)
    func searchCancelled()
}

//MARK: ViewState Enum
private enum ViewState{
    case ContentLoaded
    case ShowingMessage
    case ContentLoadingViaSearch
    case ContentLoadingInitially
    case ContentLoadingViaScroll
}

//MARK: FeedViewPresenterUICreationProtocol
private protocol FeedViewPresenterUICreationProtocol{
    func addActivityIndicator()
    func addMessageLabel()
    func addSearchBar()
    func addCollectionView()
    func addRefreshControl()
}

//MARK: Class: FeedViewPresenter
class FeedViewPresenter{
    
    //MARK: FeedViewPresenterProtocol Properties
    weak var controller: FeedViewController?
    
    //MARK: FeedView UI Element Properties
    private var messageLabel: UILabel? = nil
    private var searchBar: UISearchBar? = nil
    private var refreshControl: UIRefreshControl? = nil
    private var feedCollectionView: UICollectionView? = nil
    private var activityIndicator: UIActivityIndicatorView? = nil
    
    //MARK: Handler Properties
    private var collectionViewHandler: FeedCollectionViewHandler?
    private var searchBarHandler: FeedSearchBarHandler?
    
    //MARK: Other Properties
    private var areElementsCreated: Bool = false
    private var feedItems: [Photo] = []{
        didSet{
            self.collectionViewHandler?.updateDataSource(with: feedItems)
        }
    }
    private var view: UIView
    private var currentState: ViewState?{
        didSet{
            if let state = currentState{
                switch state {
                case .ContentLoaded:
                    self.activityIndicator?.hidden = true
                    self.activityIndicator?.stopAnimating()
                    self.feedCollectionView?.hidden = false
                    
                case .ShowingMessage:
                    self.messageLabel?.hidden = false
                    self.activityIndicator?.hidden = true
                    self.feedCollectionView?.hidden = true
                    
                case .ContentLoadingInitially, .ContentLoadingViaSearch:
                    self.feedCollectionView?.hidden = true
                    self.feedCollectionView?.scrollToItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
                    self.activityIndicator?.hidden = false
                    self.activityIndicator?.startAnimating()
                
                default: break
                }
            }
        }
    }

    init(with controller:FeedViewController){
        self.controller = controller
        self.view = controller.view
        self.currentState = ViewState.ContentLoadingInitially
    }
    
    @objc internal func pullToRefreshTriggered() {
        self.currentState = ViewState.ContentLoadingInitially
        self.controller?.pullToRefreshTriggered()
    }
}

extension FeedViewPresenter: FeedViewPresenterProtocol{
    func createElements() {
        if self.areElementsCreated{
            return
        }
        self.addMessageLabel()
        self.addActivityIndicator()
        
        self.createSearchBarHandler()
        self.addSearchBar()
        
        self.createCollectionViewHandler()
        self.addCollectionView()
        
        self.addRefreshControl()
        self.areElementsCreated = true
    }
    
    func showMessage(message: String) {
        guard let label = self.messageLabel else { return }
        self.currentState = ViewState.ShowingMessage
        label.text = message
    }
    
    func showItems(items: [Photo]) {
        
        if let currentState = self.currentState{
            switch currentState {
            
            case .ContentLoadingInitially, .ContentLoadingViaSearch:
                self.refreshControl?.endRefreshing()
                self.feedItems = items
                self.feedCollectionView?.reloadData()
            
            case .ContentLoadingViaScroll:
                let itemCount = self.feedItems.count
                let indexPaths: [NSIndexPath] = Array(itemCount ..< itemCount + items.count).map { (index) -> NSIndexPath in
                    return NSIndexPath(forRow: index, inSection: 0)
                }
                
                self.feedItems.appendContentsOf(items)
                self.feedCollectionView?.performBatchUpdates({
                    self.feedCollectionView?.insertItemsAtIndexPaths(indexPaths)
                }, completion: nil)
            
            default: break
            }
        }
        self.currentState = ViewState.ContentLoaded
    }
    
    func willDisplayLastElementOfFeed() {
        if ViewState.ContentLoadingViaSearch == self.currentState{
            if let searchText = self.searchBar?.text{
                self.currentState = ViewState.ContentLoadingViaScroll
                self.controller?.willDisplayLastElementOfSearch(searchText)
            }
        }else{
            self.currentState = ViewState.ContentLoadingViaScroll
            self.controller?.willDisplayLastElementOfFeed()
        }
    }
    
    func searchBarTextDidChange(text: String) {
        self.currentState = ViewState.ContentLoadingViaSearch
        self.controller?.searchBarTextDidChange(text)
    }
    
    func searchCancelled() {
        self.currentState = ViewState.ContentLoadingInitially
        self.controller?.searchCancelled()
    }
}

extension FeedViewPresenter: FeedViewPresenterUICreationProtocol{
    private func addActivityIndicator(){
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.view.addSubview(indicator)
        indicator.snp_makeConstraints { (make) in
            make.center.equalTo(self.view)
        }
        self.activityIndicator = indicator
    }
    
    private func addMessageLabel(){
        let label = UILabel()
        label.textAlignment = .Center
        label.minimumScaleFactor = 0.8
        
        self.view.addSubview(label)
        label.snp_makeConstraints { (make) in
            make.width.equalTo(self.view).inset(20)
            make.center.equalTo(self.view)
        }
        self.messageLabel = label
    }
    
    private func addSearchBar(){
        self.searchBar = UISearchBar()
        if let searchBar = self.searchBar{
            searchBar.placeholder = NSLocalizedString("Search", comment: "")
            searchBar.showsCancelButton = true
            searchBar.delegate = self.searchBarHandler
            
            self.view.addSubview(searchBar)
            searchBar.snp_makeConstraints { (make) in
                if let controller = self.controller{
                    make.top.equalTo(controller.snp_topLayoutGuideBottom)
                }
                make.left.equalTo(self.view)
                make.width.equalTo(self.view)
            }
        }
    }
    
    private func addCollectionView(){
        let collectionView = UICollectionView(frame:CGRectMake(0, 0, 0, 0), collectionViewLayout:UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.blueColor()
        
        self.view.addSubview(collectionView)
        collectionView.snp_makeConstraints { (make) in
            if let bar = searchBar{
                make.top.equalTo(bar.snp_bottom)
            }
            make.right.left.bottom.equalTo(self.view)
        }
        
        collectionView.dataSource = collectionViewHandler
        collectionView.delegate = collectionViewHandler
        
        collectionView.registerClass(FeedCell.self, forCellWithReuseIdentifier: String(FeedCell))
        collectionView.registerClass(FeedCellReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: String(FeedCellReusableView))
        
        collectionView.backgroundColor = UIColor.whiteColor()
        self.feedCollectionView = collectionView
    }
    
    private func addRefreshControl(){
        self.refreshControl = UIRefreshControl()
        if let refreshControl = self.refreshControl{
            refreshControl.tintColor = UIColor.grayColor()
            refreshControl.addTarget(self, action: #selector(FeedViewPresenter.pullToRefreshTriggered), forControlEvents: UIControlEvents.ValueChanged)
            self.feedCollectionView?.addSubview(refreshControl)
            self.feedCollectionView?.alwaysBounceVertical = true
        }
    }
    
    private func createCollectionViewHandler(){
        let collectionViewHandlerConfiguration = FeedCollectionViewHandlerConfiguration(items: [],
                                                                                        cellWidth: CGRectGetWidth(self.view.frame),
                                                                                        cellIdentifier: String(FeedCell),
                                                                                        owner: self)
        self.collectionViewHandler = FeedCollectionViewHandler(with: collectionViewHandlerConfiguration)
    }
    
    private func createSearchBarHandler(){
        self.searchBarHandler = FeedSearchBarHandler(with: self)
    }
}
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
}

//MARK: ViewState Enum
private enum ViewState{
    case ContentLoaded
    case ShowingMessage
    case ContentLoadingInitially
    case ContentLoadingViaPullToRefresh
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
                    
                case .ContentLoadingInitially, .ContentLoadingViaPullToRefresh:
                    self.activityIndicator?.hidden = false
                    self.feedCollectionView?.hidden = true
                    self.activityIndicator?.startAnimating()
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
        self.currentState = ViewState.ContentLoadingViaPullToRefresh
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
        
        if self.currentState == ViewState.ContentLoadingViaPullToRefresh{
            self.refreshControl?.endRefreshing()
            self.feedItems = items
            
        }else{
            let itemCount = self.feedItems.count
            let indexPaths: [NSIndexPath] = Array(itemCount ..< itemCount + items.count).map { (index) -> NSIndexPath in
                return NSIndexPath(forRow: index, inSection: 0)
            }
            
            self.feedItems.appendContentsOf(items)
            self.feedCollectionView?.performBatchUpdates({
                self.feedCollectionView?.insertItemsAtIndexPaths(indexPaths)
                }, completion: nil)
        }
        self.currentState = ViewState.ContentLoaded
    }
    
    func willDisplayLastElementOfFeed() {
        self.controller?.willDisplayLastElementOfFeed()
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
        let bar = UISearchBar()
        bar.tintColor = UIColor.cyanColor()
        
        self.view.addSubview(bar)
        bar.snp_makeConstraints { (make) in
            if let controller = self.controller{
                make.top.equalTo(controller.snp_topLayoutGuideBottom)
            }
            make.left.equalTo(self.view)
            make.width.equalTo(self.view)
        }
        self.searchBar = bar
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
}
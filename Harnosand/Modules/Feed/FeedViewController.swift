//
//  FeedViewController.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 25/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import UIKit
import SnapKit

enum ViewState{
    case ContentLoaded
    case ShowingMessage
    case ContentLoadingInitially
    case ContentLoadingViaPullToRefresh
}

protocol FeedViewProtocol{
    var presenter: FeedPresenter? { get set }
    
    func showMessage(message: String)
    func loadedItems(newItems: [Photo])
}

//MARK: Class: FeedViewController
class FeedViewController: UIViewController, FeedViewProtocol {
    
    //MARK: UI Element Properties
    private var messageLabel: UILabel? = nil
    private var searchBar: UISearchBar? = nil
    private var refreshControl: UIRefreshControl? = nil
    private var feedCollectionView: UICollectionView? = nil
    private var activityIndicator: UIActivityIndicatorView? = nil
    
    //MARK: FeedViewProtocol Properties
    var presenter: FeedPresenter?
    
    //MARK: Other Properties
    private var feedItems: [Photo] = []
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
    
    //MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Photos", comment: "")
        
        self.addMessageLabel()
        self.addActivityIndicator()
        self.addSearchBar()
        self.addCollectionView()
        self.addRefreshControl()
        
        self.currentState = ViewState.ContentLoadingInitially
        self.presenter = FeedPresenter(with: self)
        presenter?.loadFeedInitially()
    }
    
    //MARK: Private Helper Methods
    
    @objc private func startRefreshing(){
        self.currentState = ViewState.ContentLoadingViaPullToRefresh
        self.presenter?.loadFeedInitially()
    }
    
    //MARK: FeedViewProtocol Methods
    func showMessage(message: String) {
        guard let label = self.messageLabel else { return }
        self.currentState = ViewState.ShowingMessage
        label.text = message
    }
    
    func loadedItems(newItems: [Photo]) {
        if self.currentState == ViewState.ContentLoadingViaPullToRefresh{
            self.refreshControl?.endRefreshing()
            self.feedItems = newItems
        }else{
            let itemCount = self.feedItems.count
            let indexPaths: [NSIndexPath] = Array(itemCount ..< itemCount + newItems.count).map { (index) -> NSIndexPath in
                return NSIndexPath(forRow: index, inSection: 0)
            }
            
            self.feedItems.appendContentsOf(newItems)
            self.feedCollectionView?.performBatchUpdates({
                self.feedCollectionView?.insertItemsAtIndexPaths(indexPaths)
            }, completion: nil)
        }
        self.currentState = ViewState.ContentLoaded
    }
    
    //MARK: UI Elements Creation
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
            make.top.equalTo(self.snp_topLayoutGuideBottom)
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
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(FeedCell.self, forCellWithReuseIdentifier: String(FeedCell))
        collectionView.registerClass(FeedCellReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: String(FeedCellReusableView))

        collectionView.backgroundColor = UIColor.whiteColor()
        self.feedCollectionView = collectionView
    }
    
    private func addRefreshControl(){
        self.refreshControl = UIRefreshControl()
        if let refreshControl = self.refreshControl{
            refreshControl.tintColor = UIColor.grayColor()
            refreshControl.addTarget(self, action: #selector(FeedViewController.startRefreshing), forControlEvents: UIControlEvents.ValueChanged)
            self.feedCollectionView?.addSubview(refreshControl)
            self.feedCollectionView?.alwaysBounceVertical = true
        }
    }
}

//MARK: Extension UICollectionViewDataSource Methods
extension FeedViewController: UICollectionViewDataSource{
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(FeedCell), forIndexPath: indexPath) as! FeedCell
        let item = self.feedItems[indexPath.row]
        cell.configureCell(with: item)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feedItems.count
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader{
            return UICollectionReusableView()
        }else{
            let view: UICollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: String(FeedCellReusableView), forIndexPath: indexPath) as! FeedCellReusableView
            if indexPath.row != self.feedItems.count{
                view.hidden = true
            }
            return view
        }
    }
}

//MARK: Extension: UICollectionViewDelegate Methods
extension FeedViewController: UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.feedItems.count - 1{
            self.presenter?.loadNextFeed()
        }
    }
}

//MARK: Extension: UICollectionViewDelegateFlowLayout Methods
extension FeedViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let item = self.feedItems[indexPath.row]
        
        if let cellHeight = item.screenHeight{
            return CGSizeMake(CGRectGetWidth(self.view.frame), CGFloat(cellHeight) + 60)
        }else{
            return CGSizeMake(CGRectGetWidth(self.view.frame), 150)
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSizeMake(CGRectGetWidth(self.view.frame), 50)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 50
    }
}
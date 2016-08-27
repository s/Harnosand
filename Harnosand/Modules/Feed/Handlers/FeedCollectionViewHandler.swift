//
//  FeedCollectionViewHandler.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 28/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import Foundation
import UIKit

struct FeedCollectionViewHandlerConfiguration{
    let items: [Photo]
    let cellWidth: CGFloat
    let cellIdentifier: String
    let owner: FeedViewPresenter
}

//MARK: FeedCollectionViewHandlerProtocol
protocol FeedCollectionViewHandlerProtocol{
    func updateDataSource(with items:[Photo])
}

//MARK: Class: FeedCollectionViewHandler
final class FeedCollectionViewHandler: NSObject, FeedCollectionViewHandlerProtocol{
    private let cellWidth: CGFloat
    private let cellIdentifier: String
    
    private var items: [Photo] = []
    private weak var owner: FeedViewPresenter?
    
    init(with configuration:FeedCollectionViewHandlerConfiguration){
        self.owner = configuration.owner
        self.items = configuration.items
        self.cellWidth = configuration.cellWidth
        self.cellIdentifier = configuration.cellIdentifier
        super.init()
    }
    
    //MARK: FeedCollectionViewHandlerProtocol Methods
    func updateDataSource(with items: [Photo]) {
        self.items = items
    }
}


//MARK: Extension UICollectionViewDataSource Methods
extension FeedCollectionViewHandler: UICollectionViewDataSource{
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! FeedCell
        let item = items[indexPath.row]
        cell.configureCell(with: item)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader{
            return UICollectionReusableView()
        }else{
            let view: UICollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: String(FeedCellReusableView), forIndexPath: indexPath) as! FeedCellReusableView
            if indexPath.row != items.count{
                view.hidden = true
            }
            return view
        }
    }
}

//MARK: Extension: UICollectionViewDelegate Methods
extension FeedCollectionViewHandler: UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == items.count - 1{
            owner?.willDisplayLastElementOfFeed()
        }
    }
}

//MARK: Extension: UICollectionViewDelegateFlowLayout Methods
extension FeedCollectionViewHandler: UICollectionViewDelegateFlowLayout{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let item = items[indexPath.row]
        
        if let cellHeight = item.screenHeight{
            return CGSizeMake(self.cellWidth, CGFloat(cellHeight) + 60)
        }else{
            return CGSizeMake(self.cellWidth, 150)
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSizeMake(self.cellWidth, 50)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 50
    }
}
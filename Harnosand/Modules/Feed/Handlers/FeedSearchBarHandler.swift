//
//  FeedSearchBarHandler.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 28/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import Foundation
import UIKit

class FeedSearchBarHandler: NSObject{
    private var owner: FeedViewPresenter
    
    init(with owner:FeedViewPresenter){
        self.owner = owner
        super.init()
    }
}

extension FeedSearchBarHandler: UISearchBarDelegate{
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.owner.searchCancelled()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.owner.searchBarTextDidChange(searchText)
    }
}
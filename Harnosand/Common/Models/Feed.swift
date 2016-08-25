//
//  Feed.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 25/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import Foundation
import Unbox

struct Feed: Unboxable{
    let page: Int
    let pages: Int
    let perpage: Int?
    let total: Int?
    let photos: [Photo]?
    
    init(unboxer: Unboxer) {
        self.page = unboxer.unbox("page")
        self.pages = unboxer.unbox("pages")
        self.perpage = unboxer.unbox("perpage")
        self.total = unboxer.unbox("total")
        self.photos = unboxer.unbox("photo")
    }
}
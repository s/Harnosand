//
//  Feed.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 25/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import Foundation
import Unbox

struct Feed{
    var items:[Photo]
    var page:Int = 1
}

extension Feed:Unboxable{
    init(unboxer: Unboxer) {
        self.items = unboxer.unbox("items")
    }
}
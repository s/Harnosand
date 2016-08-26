//
//  Person.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 27/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import Foundation
import Unbox

struct Person: Unboxable{
    let identifier: String
    let nsid: String
    let iconServer: String
    let iconFarm: Int
    let username: String
    var profileImageURL: NSURL{
        get{
            return NSURL(string:"https://farm\(self.iconFarm).staticflickr.com/\(self.iconServer)/buddyicons/\(self.nsid).jpg")!
        }
    }
    
    init(unboxer: Unboxer) {
        self.identifier = unboxer.unbox("id")
        self.nsid = unboxer.unbox("nsid")
        self.iconServer = unboxer.unbox("iconserver")
        self.iconFarm = unboxer.unbox("iconfarm")
        self.username = unboxer.unbox("username._content")
    }
}
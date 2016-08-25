//
//  Photo.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 25/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import Foundation
import Unbox

struct Photo: Unboxable{
    let identifier: String
    let owner: String
    let title: String
    let secret: String
    let server: String
    let farm: Int
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    
    init(unboxer: Unboxer) {
        self.identifier = unboxer.unbox("id")
        self.owner = unboxer.unbox("owner")
        self.title = unboxer.unbox("title")
        self.secret = unboxer.unbox("secret")
        self.server = unboxer.unbox("server")
        
        self.farm = unboxer.unbox("farm")
        self.isPublic = unboxer.unbox("ispublic")
        self.isFriend = unboxer.unbox("isfriend")
        self.isFamily = unboxer.unbox("isfamily")
    }
}
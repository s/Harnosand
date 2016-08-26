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
    let identifier: String?
    let owner: String?
    let title: String?
    let dateTaken: NSDate?
    let media: String?
    let url: NSURL?
    let width: Float?
    let height: Float?
    var screenHeight: Float?{
        get{
            if let width = width, height = height{
                let screenWidth = Float(UIScreen.mainScreen().bounds.width)
                return (height * screenWidth) / width
            }else{
                return nil
            }
        }
    }
    
    init(unboxer: Unboxer) {
        self.identifier = unboxer.unbox("id")
        self.owner = unboxer.unbox("owner")
        self.title = unboxer.unbox("title")
        self.media = unboxer.unbox("media")
        
        if let url:String = unboxer.unbox("url_c"){
            self.url = NSURL(string: url)
        }else{
            self.url = nil
        }
        
        self.width = unboxer.unbox("width_c")
        self.height = unboxer.unbox("height_c")
        
        self.dateTaken = unboxer.unbox("datetaken", formatter:CachedDateFormatter.sharedInstance.formatterWith("YYYY-MM-dd HH:mm:ss"))
    }
}
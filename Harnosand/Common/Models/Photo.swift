//
//  Photo.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 25/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import Foundation
import Unbox

struct Photo{
    let title: String
    let link: NSURL
    let media: NSURL
    let description: String
    let published: NSDate
    let author: String
    let authorId: String
    let tags: String
}

extension Photo: Unboxable{
    init(unboxer: Unboxer) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ssZ"
        
        self.title = unboxer.unbox("title")
        self.link = unboxer.unbox("")
        self.media = unboxer.unbox("")
        self.description = unboxer.unbox("description")
        self.published = unboxer.unbox("published", formatter: dateFormatter)
        self.author = unboxer.unbox("author")
        self.authorId = unboxer.unbox("author_id")
        self.tags = unboxer.unbox("tags")
    }
}
//
//  FlickrService.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 25/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import Foundation
import Alamofire
import UnboxedAlamofire

enum FlickrServiceResult<T>{
    case Success(T)
    case Failure(ErrorType)
}

enum FlickrServiceEndpoint: String{
    case Feed = "flickr.photos.getRecent"
}

final class FlickrService{
    static let sharedService = FlickrService()
    static let baseURL = NSURL(string: "https://api.flickr.com/services/rest")!
    static var apiKey = ""
    
    private func flickrAPIRequest(withMethod method:Alamofire.Method, path: String, parameters:[String: AnyObject]?) -> Request{
        let url = FlickrService.baseURL.URLByAppendingPathComponent(path)
        let headers = ["Accept":"application/json", "Content-Type":"application/json"]
        var combinedParameters: [String: AnyObject] = ["api_key":FlickrService.apiKey, "format":"json", "nojsoncallback":1]
        if let parameters = parameters{
            combinedParameters.unionInPlace(parameters)
        }
        return Alamofire.request(method, url, parameters: combinedParameters, encoding: .URL, headers: headers)
    }
    
    func getFeed(page page:Int, completion:(FlickrServiceResult<Feed>)->()){
        let parameters: [String:AnyObject] = ["method":FlickrServiceEndpoint.Feed.rawValue, "perpage":10]
        let path = "/"
        self.flickrAPIRequest(withMethod:.GET, path: path, parameters: parameters).responseObject(keyPath:"photos") { (response:Response<Feed, NSError>) in
            switch(response.result){
            case .Success(let value):
                completion(FlickrServiceResult.Success(value))
            case .Failure(let error):
                completion(FlickrServiceResult.Failure(error))
            }
        }
    }
}
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

enum Result<T> {
    case Success(T)
    case Failure(ErrorType)
}

typealias feedCompletionHandlerType = (Result<Feed>) -> Void

enum FlickrServiceRouter: URLRequestConvertible{
    static let baseURL = NSURL(string: "https://api.flickr.com/services")!
    static var apiKey = ""
    
    case Feed
    case Search(String)
    
    var URL: NSURL{
        return FlickrServiceRouter.baseURL.URLByAppendingPathComponent(route.path)
    }
    
    var route: (path: String, parameters: [String: AnyObject]?) {
        switch self {
        case .Feed:
            return ("/feeds/photos_public.gne", nil)
        case .Search(let q):
            return ("/rest/", ["method":"flickr.photos.search", "api_key":FlickrServiceRouter.apiKey, "text":q])
        }
    }
    
    var method: Alamofire.Method{
        return .GET
    }
    
    var URLRequest: NSMutableURLRequest {
        var defaultParameters: [String: AnyObject] = ["format":"json", "nojsoncallback":1]
        if let parameters = route.parameters{
            defaultParameters.unionInPlace(parameters)
        }
        let httpRequest = NSMutableURLRequest(URL: URL)
        httpRequest.HTTPMethod = method.rawValue
        httpRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        return Alamofire.ParameterEncoding.JSON.encode(httpRequest, parameters: defaultParameters).0
    }
}

final class FlickrService{
    static let sharedService = FlickrService()
    
    func getFeed(completion:feedCompletionHandlerType){
        Alamofire.request(FlickrServiceRouter.Feed).responseObject{ (response: Response<Feed, NSError>) in
            switch response.result{
            case .Success(let value):
                completion(Result.Success(value))
            case .Failure(let error):
                completion(Result.Failure(error))
            }
        }
    }
}
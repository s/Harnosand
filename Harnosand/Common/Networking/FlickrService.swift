//
//  FlickrService.swift
//  Harnosand
//
//  Created by Muhammed Said Özcan on 25/08/16.
//  Copyright © 2016 Muhammed Said Özcan. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import UnboxedAlamofire

enum FlickrServiceResult<T>{
    case Success(T)
    case Failure(ErrorType)
}

private enum FlickrServiceEndpoint: String{
    case Feed = "flickr.photos.getRecent"
    case PersonInfo = "flickr.people.getInfo"
    case Search = "flickr.photos.search"
}

protocol FlickrServiceProtocol{
    func getFeed(page page:Int, completion:(FlickrServiceResult<Feed>)->())
    func getImage(url url:NSURL, completion:(FlickrServiceResult<Image>)->Void)
    func getOwner(of photo:Photo, completion:(FlickrServiceResult<Person>)->Void)
    func search(keyword q:String, page:Int, completion:(FlickrServiceResult<Feed>)->Void)
}

final class FlickrService{
    static let sharedService = FlickrService()
    static var apiKey = ""
    private static let baseURL = NSURL(string: "https://api.flickr.com/services/rest")!
    
    
    private func flickrAPIRequest(withMethod method:Alamofire.Method, endpointURL: NSURL, parameters:[String: AnyObject]?) -> Request{
        let headers = ["Accept":"application/json", "Content-Type":"application/json"]
        var combinedParameters: [String: AnyObject] = ["api_key":FlickrService.apiKey, "format":"json", "nojsoncallback":1]
        if let parameters = parameters{
            combinedParameters.unionInPlace(parameters)
        }
        return Alamofire.request(method, endpointURL, parameters: combinedParameters, encoding: .URL, headers: headers)
    }
    
    private func getEndpointURL(from path:String) -> NSURL{
        let url = FlickrService.baseURL.URLByAppendingPathComponent(path)
        return url
    }
    
    private func getFlicrkServiceResult<T>(from response:Response<T, NSError>) -> FlickrServiceResult<T>{
        switch(response.result){
        case .Success(let value):
            return FlickrServiceResult.Success(value)
        case .Failure(let error):
            return FlickrServiceResult.Failure(error)
        }
    }
}

extension FlickrService: FlickrServiceProtocol{
    func getFeed(page page:Int, completion:(FlickrServiceResult<Feed>)->()){
        let parameters: [String:AnyObject] = ["method":FlickrServiceEndpoint.Feed.rawValue,
                                              "extras":"owner_name,date_taken,media,url_c",
                                              "per_page":10,
                                              "page":page]
        
        let endpointURL = self.getEndpointURL(from: "/")
        self.flickrAPIRequest(withMethod:.GET, endpointURL: endpointURL, parameters: parameters).responseObject(keyPath:"photos") { (response:Response<Feed, NSError>) in
            completion(self.getFlicrkServiceResult(from: response))
        }
    }
    
    func getImage(url url:NSURL, completion:(FlickrServiceResult<UIImage>)->Void){
        self.flickrAPIRequest(withMethod: .GET, endpointURL: url, parameters: nil).responseImage { (response:Response<Image, NSError>) in
            completion(self.getFlicrkServiceResult(from: response))
        }
    }
    
    func getOwner(of photo:Photo, completion:(FlickrServiceResult<Person>)->Void){
        guard let owner = photo.owner else {
            print("Owner of photo is nil.")
            return
        }
        let parameters: [String: AnyObject] = ["method":FlickrServiceEndpoint.PersonInfo.rawValue,
                                               "user_id":owner]
        
        let endpointURL = self.getEndpointURL(from: "/")
        self.flickrAPIRequest(withMethod: .GET, endpointURL: endpointURL, parameters: parameters).responseObject(keyPath:"person") { (response:Response<Person, NSError>) in
            completion(self.getFlicrkServiceResult(from: response))
        }
    }
    
    func search(keyword q:String, page:Int, completion:(FlickrServiceResult<Feed>)->Void){
        let parameters: [String: AnyObject] = ["method":FlickrServiceEndpoint.Search.rawValue,
                                               "text":q,
                                               "content_type":1,
                                               "media":"photos",
                                               "extras":"owner_name,date_taken,media,url_c",
                                               "per_page":10,
                                               "page":page]
        let endpointURL = self.getEndpointURL(from: "/")
        self.flickrAPIRequest(withMethod: .GET, endpointURL: endpointURL, parameters: parameters).responseObject(keyPath:"photos"){ (response:Response<Feed, NSError>) in
            completion(self.getFlicrkServiceResult(from: response))
        }
    }
}
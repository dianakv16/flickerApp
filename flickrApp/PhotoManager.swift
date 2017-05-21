//
//  PhotoManager.swift
//  flickrApp
//
//  Created by Diana Karina Vainberg Gauna on 11/12/2016.
//  Copyright © 2016 Diana Karina Vainberg Gauna. All rights reserved.
//


import UIKit

class PhotoManager {
    // Dataset
    var photoSet = [PhotoInfo]()
    
    // Callback closure type
    typealias PhotoData = (Any?, Bool) -> ()
    
    // Completion to be called to notify controller
    func requestRecentPhotos(type : String, text: String, completion: @escaping PhotoData) {
        var url = ""
        //URL to get the most recent pictures
        if type == "recent"{
            url = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=ab804ba504d66837513a0133a386bab1&format=json&nojsoncallback=1&extras=url_m,description,tags&per_page=20"
        //URL to make a search with the word(s) in text
        } else {
            url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=ab804ba504d66837513a0133a386bab1&format=json&nojsoncallback=1&extras=url_m,description,tags&text="+text+"&per_page=20"
        }
        let reqURL = URL(string: url)!
        
        let dataTask = URLSession.shared.dataTask(with: reqURL) {
            (data, response, error) in
            
            guard error == nil else {
                print ("Error: \(error)")
                return
            }
            guard let data = data else{
                fatalError("Error was nil, but there was no data. This should never happen")

            }
            self.didFetchRecentPhotos(data: data, response: response!, error: error, completion: completion)
        }
        dataTask.resume()
    }
    
    // Callback for the URLSession
    private func didFetchRecentPhotos(data: Data?, response: URLResponse, error: Error?, completion: @escaping PhotoData) {
        
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
            guard let photos = jsonData["photos"] as? [String:Any] else {
                completion(nil,false)
                return
            }
            guard let photoList = photos["photo"] as? [Any] else {
                completion(nil,false)
                return
            }
            
            for photoInfo in photoList {
                let photo = PhotoInfo()
                
                guard let info = photoInfo as? [String:Any] else {
                    completion(nil, false)
                    return
                }
                if let id = info["id"] as? String {
                    photo.id = id
                }
                if let title = info["title"] as? String {
                    photo.title = title
                }
                if let tags = info["tags"] as? String {
                    photo.tags = tags
                }
                if let um = info["url_m"] as? String  {
                    photo.url_m = um
                }
                if let desc = info["description"] as? [String: String] {
                    if let description = desc["_content"] as String!{
                        photo.description = description
                    }
                    
                }
                
                photoSet.append(photo)
            }
            completion(photoSet, true)
            
        } catch let error {
            print("Decoding error \(error)")
        }
    }
    
    func requestImage(urlStr: String, completion: @escaping PhotoData) {
        guard let reqURL = URL(string: urlStr) as URL? else {
            completion(nil, false)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: reqURL) {
            (data, response, error) in
            
            if let _ = error {
                completion(nil, false)
                return
            }
            
            let img = UIImage(data: data!)
            completion(img, true)
        }
        dataTask.resume()
        
    }
    
}

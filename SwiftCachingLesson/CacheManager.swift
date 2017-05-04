//
//  CacheManager.swift
//  SwiftCachingLesson
//
//  Created by Ilyas on 02.05.17.
//  Copyright © 2017 ru.itisIosLab. All rights reserved.
//

import Foundation

protocol CacheDataSource {
    func delete(key: String, image: UIImage, text: String)
    func deleted(value: Any?, with key: String, text: String?)
    func added(value: Any?, with key: String, url: URL?, text: String?)
    func getCacheObject(with key:String)
    func updateCacheObject(with key:String, image: UIImage?, text:String?)
}

protocol CacheManagerProtocol {
    func setDelegate(delegate:CacheDataSource)
    func setNSCache(status: Bool)
    func add(key: String, url: URL, text: String, successBlock:@escaping(_ image:UIImage, _ text:String) -> ())
    func get(key: String) -> (String, UIImage)
    func addImageArr(imageArr: [UIImage], key: String)
    func deleteDataFromCache(key: String)
}



class CacheManager: CacheManagerProtocol {
    var delegate: CacheDataSource!
    var cashing: NSCache<AnyObject, AnyObject> = NSCache()
    
    var isNSCache: Bool!
    var task: URLSessionTask!
    var session: URLSession!
    
     func setNSCache(status: Bool) {
        isNSCache = status
    }
    
    func addImageArr(imageArr: [UIImage], key: String) {
        for (i,image) in imageArr.enumerated() {
            if isNSCache {
                self.cashing.setObject(image as AnyObject, forKey: "\(i) + \(key)" as AnyObject)
            }else{
                let manager = SDWebImageManager.shared()
                manager.imageCache?.setValue(image, forKey: "\(i) + \(key)")
            }
            
        }
    }
    
    func addImage(image: UIImage, key: String) {
        if isNSCache {
            self.cashing.setObject(image as AnyObject, forKey: key as AnyObject)
        }else{
            let manager = SDWebImageManager.shared()
            manager.imageCache?.setValue(image, forKey: key)
        }
    }
    
    func deleteDataFromCache(key: String) {
        self.cashing.removeObject(forKey: key as AnyObject)
        let manager = SDWebImageManager.shared()
        manager.imageCache?.removeImage(forKey: key, withCompletion: {
        
        })
    }

    func setDelegate(delegate: CacheDataSource) {
        self.delegate = delegate
    }
    
    func add(key: String, url: URL, text: String, successBlock:@escaping(_ image:UIImage, _ text:String) -> ()) {
        session = URLSession.shared
        if (cashing.object(forKey: key as AnyObject) != nil || SDWebImageManager.shared().imageCache?.imageFromCache(forKey: key) != nil) {
            let data = self.get(key: key)
            successBlock(data.1, data.0)
            print("Cache used")
        }else{
            session.downloadTask(with: url, completionHandler: { (lUrl, response, error) in
                
                let data:Data! = try? Data(contentsOf: url)
                DispatchQueue.main.async(execute: {
                    let image = UIImage(data: data)
                    self.cashing.setObject(text as AnyObject, forKey: "\(key)+ text" as AnyObject)
                    
                    if (self.isNSCache) {
                        self.cashing.setObject(image!, forKey: key as AnyObject)
                    }else{
                        let manager = SDWebImageManager.shared()
                         manager.imageDownloader?.downloadImage(with: url, options: .lowPriority, progress: nil, completed: { (true) in
                         })
                        //SDWebImageManager.shared().imageCache?.setValue(image, forKey: key)
                    }
                    successBlock(image!, text)
                })
            }).resume()
            
            delegate.added(value: nil, with: key, url: url, text: text)
        }
        
    }

    func get(key: String) -> (String, UIImage) {
        let text: String!
        let image: UIImage!
        
        text = cashing.object(forKey: "\(key)+ text" as AnyObject) as! String
        if (isNSCache){
            image = cashing.object(forKey: key as AnyObject) as! UIImage
        }else{
            
            image = SDWebImageManager.shared().imageCache?.imageFromCache(forKey: key)
        }
        delegate.getCacheObject(with: key)
        return (text, image)
    }
    
}
